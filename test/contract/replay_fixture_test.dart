import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

/// Replays every replay/rs-v1 scenario with the Dart engine and asserts it
/// matches the backend-computed golden totals and state — the scoring/Fever
/// parity proof.
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
              '${fixturesDir().path}/replay/rs-v1/scenarios.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  for (final dynamic caseDyn in root['cases'] as List<dynamic>) {
    final Map<String, dynamic> c = caseDyn as Map<String, dynamic>;
    final String id = c['id'] as String;

    test('replay $id matches golden', () {
      final List<RunEvent> events = (c['events'] as List<dynamic>).map((
        dynamic e,
      ) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        return RunEvent(
          tMs: m['tMs'] as int,
          correct: m['correct'] as bool,
          matchedTarget: m['matchedTarget'] as bool,
          operators: (m['operators'] as List<dynamic>)
              .map((dynamic o) => parseOperator(o as String))
              .toList(),
        );
      }).toList();

      final ReplayOutcome o = ReplayEngine.replay(rs1, events);
      final Map<String, dynamic> exp = c['expected'] as Map<String, dynamic>;

      expect(
        o.finalState.totalScore,
        exp['totalScore'],
        reason: c['description'] as String,
      );
      expect(o.finalState.comboCount, exp['comboCount']);
      expect(o.finalState.consecutiveCorrect, exp['consecutiveCorrect']);
      expect(o.finalState.feverEnergy, exp['feverEnergy']);
      expect(o.finalState.feverActive, exp['feverActive']);
      expect(o.finalState.level, exp['level']);
      expect(o.finalState.equationsThisLevel, exp['equationsThisLevel']);

      final List<int> expRunning = (exp['runningTotals'] as List<dynamic>)
          .map((dynamic t) => t as int)
          .toList();
      expect(o.runningTotals, expRunning);
    });
  }
}
