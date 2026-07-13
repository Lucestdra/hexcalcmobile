import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

/// Cross-platform proof for the ranked event log: a Dart twin of the backend
/// `RankedRunVerifier` regenerates every board, validates each equation path,
/// digests the log into `RunEvent`s, and replays it — and must reproduce the exact
/// verdict (verified/rejected, authoritative score, reject reason, anomaly flags)
/// recorded in the shared `event-log/v1` golden fixtures. Because those expected
/// scores come from the same `ReplayEngine` that produces `replay/rs-v1`, this
/// guarantees the client maps + scores a run identically to the server.
void main() {
  final Ruleset rs1 = Ruleset.fromJson(
    jsonDecode(
          File('${fixturesDir().path}/rulesets/rs-v1.json').readAsStringSync(),
        )
        as Map<String, dynamic>,
  );

  final Map<String, dynamic> root =
      jsonDecode(
            File(
              '${fixturesDir().path}/event-log/v1/scenarios.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  for (final dynamic caseDyn in root['cases'] as List<dynamic>) {
    final Map<String, dynamic> c = caseDyn as Map<String, dynamic>;
    final String id = c['id'] as String;
    final Map<String, dynamic> eventLog = c['eventLog'] as Map<String, dynamic>;
    final Map<String, dynamic> exp = c['expected'] as Map<String, dynamic>;

    test('event log $id reproduces the golden verdict', () {
      final _Verdict v = _verify(
        rs1,
        c['seed'] as String,
        c['generatorVersion'] as String,
        eventLog,
      );

      expect(v.accepted ? 'verified' : 'rejected', exp['outcome'], reason: id);
      expect(v.rejectionReason, exp['rejectionReason'] as String?);
      expect(
        v.anomalyFlags,
        (exp['anomalyFlags'] as List<dynamic>).cast<String>(),
      );
      if (v.accepted) {
        expect(v.verifiedScore, exp['verifiedScore'] as int, reason: id);
      }
    });
  }
}

// Kept in sync with the backend RankedRunVerifier constants.
const int _durationToleranceMs = 2000;
const int _minEquationGapMs = 120;
const int _minMeanEquationGapMs = 200;

class _Verdict {
  const _Verdict.accept(this.verifiedScore, this.anomalyFlags)
    : accepted = true,
      rejectionReason = null;
  const _Verdict.reject(this.rejectionReason)
    : accepted = false,
      verifiedScore = 0,
      anomalyFlags = const <String>[];

  final bool accepted;
  final int verifiedScore;
  final String? rejectionReason;
  final List<String> anomalyFlags;
}

_Verdict _verify(
  Ruleset ruleset,
  String seed,
  String generatorVersion,
  Map<String, dynamic> eventLog,
) {
  if (generatorVersion != BoardGeneratorV1.generatorVersion) {
    return const _Verdict.reject('unsupported_generator');
  }

  final List<Map<String, dynamic>> events =
      (eventLog['events'] as List<dynamic>).cast<Map<String, dynamic>>();

  // Timing gate over the whole stream.
  int maxTMs = 0;
  int? prevTMs;
  for (final Map<String, dynamic> e in events) {
    final int tMs = e['tMs'] as int;
    if (prevTMs != null && tMs < prevTMs) {
      return const _Verdict.reject('non_monotonic');
    }
    prevTMs = tMs;
    if (tMs > maxTMs) {
      maxTMs = tMs;
    }
  }
  if (maxTMs > ruleset.run.durationMs + _durationToleranceMs) {
    return const _Verdict.reject('duration_exceeded');
  }

  final Map<int, _BoardLookup> boards = <int, _BoardLookup>{};
  final List<RunEvent> runEvents = <RunEvent>[];
  final List<int> equationTimes = <int>[];
  int level = 0;
  int equationsThisLevel = 0;

  for (final Map<String, dynamic> e in events) {
    if (e['type'] != 'equation') {
      continue; // pause/resume: audit only
    }
    final int declaredLevel = e['levelIndex'] as int;
    if (declaredLevel != level) {
      return const _Verdict.reject('level_mismatch');
    }

    final _BoardLookup board = boards.putIfAbsent(
      level,
      () => _BoardLookup(
        BoardGeneratorV1.generate(seed, ruleset.rulesetVersion, level),
      ),
    );

    final List<AxialCoordinate> path = (e['path'] as List<dynamic>)
        .map(
          (dynamic p) => AxialCoordinate(
            (p as Map<String, dynamic>)['q'] as int,
            p['r'] as int,
          ),
        )
        .toList();

    if (path.length > BoardGeneratorV1.maxPathCells) {
      return const _Verdict.reject('path_too_long');
    }
    final PathValidationResult pv = PathValidator.validate(path);
    if (!pv.isValid) {
      return _Verdict.reject(switch (pv.errorCode) {
        PathErrorCodes.pathEmpty => 'empty_path',
        PathErrorCodes.notAdjacent => 'non_adjacent_path',
        PathErrorCodes.repeatedCell => 'repeated_cell',
        _ => 'non_adjacent_path',
      });
    }

    final List<Token> tokens = <Token>[];
    for (final AxialCoordinate coord in path) {
      final BoardCell? cell = board.cells[coord];
      if (cell == null) {
        return const _Verdict.reject('cell_not_on_board');
      }
      tokens.add(cell.toToken());
    }

    final EquationResult eval = EquationEvaluator.evaluate(tokens);
    if (eval.status == EquationStatus.grammarError) {
      return const _Verdict.reject('malformed_equation');
    }

    final bool correct = eval.status == EquationStatus.valid;
    final bool matchedTarget = correct && eval.leftHandValue == board.target;
    final List<Operator> operators = tokens
        .takeWhile((Token t) => t.kind != TokenKind.equals)
        .where((Token t) => t.kind == TokenKind.operator)
        .map((Token t) => t.operatorValue!)
        .toList();

    runEvents.add(
      RunEvent(
        tMs: e['tMs'] as int,
        correct: correct,
        matchedTarget: matchedTarget,
        operators: operators,
      ),
    );
    equationTimes.add(e['tMs'] as int);

    if (correct) {
      equationsThisLevel++;
      final int required =
          ruleset.level.equationsToComplete +
          ruleset.level.growthPerLevel * level;
      if (equationsThisLevel >= required) {
        level++;
        equationsThisLevel = 0;
      }
    }
  }

  final List<String> flags = <String>[];
  if (_implausiblyFast(equationTimes)) {
    flags.add('implausibly_fast');
  }

  final int score = ReplayEngine.replay(
    ruleset,
    runEvents,
  ).finalState.totalScore;
  final int? clientTotal = eventLog['clientTotalScore'] as int?;
  if (clientTotal != null && clientTotal != score) {
    flags.add('score_mismatch');
  }

  return _Verdict.accept(score, flags);
}

bool _implausiblyFast(List<int> times) {
  if (times.length < 2) {
    return false;
  }
  int minGap = 1 << 62;
  for (int i = 1; i < times.length; i++) {
    final int gap = times[i] - times[i - 1];
    if (gap < minGap) {
      minGap = gap;
    }
  }
  if (minGap < _minEquationGapMs) {
    return true;
  }
  final int meanGap = (times.last - times.first) ~/ (times.length - 1);
  return meanGap < _minMeanEquationGapMs;
}

class _BoardLookup {
  _BoardLookup(Board board)
    : target = board.target,
      cells = <AxialCoordinate, BoardCell>{
        for (final BoardCell c in board.cells) c.coord: c,
      };

  final int target;
  final Map<AxialCoordinate, BoardCell> cells;
}
