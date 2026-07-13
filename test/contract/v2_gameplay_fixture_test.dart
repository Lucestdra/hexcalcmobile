import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

void main() {
  late MapCatalogV1 maps;
  late RulesetV2 ruleset;
  setUpAll(() {
    maps = MapCatalogV1.fromJson(_fixture('catalogs/maps-v1.json'));
    ruleset = RulesetV2.fromJson(_fixture('rulesets/rs-v2.json'));
  });

  test('target-swipe evaluator matches shared v2 fixtures', () {
    final Map<String, dynamic> fixture = _fixture('evaluator/v2/cases.json');
    expect(fixture['protocolVersion'], BoardGeneratorV2.protocolId);
    expect(fixture['maximumCells'], ExpressionEvaluatorV2.maxCells);

    for (final dynamic rawCase in fixture['cases'] as List<dynamic>) {
      final Map<String, dynamic> testCase = rawCase as Map<String, dynamic>;
      final List<Token> tokens = (testCase['tokens'] as List<dynamic>)
          .map((dynamic raw) => _token(raw as Map<String, dynamic>))
          .toList();
      final ExpressionResultV2 actual = ExpressionEvaluatorV2.evaluate(tokens);
      final Map<String, dynamic> expected =
          testCase['expected'] as Map<String, dynamic>;
      expect(
        _expressionStatus(actual.status),
        expected['status'],
        reason: testCase['id'] as String,
      );
      expect(actual.errorCode, expected['errorCode']);
      expect(actual.value, expected['value']);
    }
  });

  test('initial board, exact targets, and two refills match backend bytes', () {
    final Map<String, dynamic> boardFixture = _fixture(
      'boards/gen-v2/open-hex.json',
    );
    final Map<String, dynamic> targetFixture = _fixture(
      'targets/v1/open-hex.json',
    );
    final String seed = boardFixture['seed'] as String;
    final MapDefinitionV2 map = maps.map(boardFixture['mapId'] as String);
    BoardStateV2 board = BoardGeneratorV2.generate(seed: seed, map: map);
    final List<dynamic> expectedBoards =
        boardFixture['boards'] as List<dynamic>;
    final List<dynamic> expectedRevisions =
        targetFixture['revisions'] as List<dynamic>;

    for (int revision = 0; revision < expectedBoards.length; revision++) {
      final Map<String, dynamic> expectedBoard =
          expectedBoards[revision] as Map<String, dynamic>;
      final Map<String, dynamic> expectedTargets =
          expectedRevisions[revision] as Map<String, dynamic>;
      final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyze(
        board,
      );

      expect(board.revision, expectedBoard['revision']);
      expect(board.target, expectedBoard['target']);
      expect(
        board.tiles.map(_tileJson).toList(),
        expectedBoard['tiles'],
        reason: 'revision $revision tiles',
      );
      final int expressionCount = candidates.fold<int>(
        0,
        (int total, TargetCandidateV2 candidate) =>
            total + candidate.solutionCount,
      );
      expect(expressionCount, expectedBoard['expressionCount']);
      expect(candidates.length, expectedBoard['targetCount']);
      expect(
        candidates.map(_candidateJson).toList(),
        expectedTargets['candidates'],
      );
      expect(expectedTargets['selectedTarget'], board.target);
      expect(expectedTargets['expressionCount'], expressionCount);
      expect(expectedTargets['targetCount'], candidates.length);

      final Map<String, dynamic> transition =
          expectedBoard['transition'] as Map<String, dynamic>;
      expect(board.lastTransition.fromRevision, transition['fromRevision']);
      expect(board.lastTransition.toRevision, transition['toRevision']);
      expect(board.lastTransition.attemptsUsed, transition['attemptsUsed']);
      expect(
        board.lastTransition.changedCoordinates.map(_coordinateJson).toList(),
        transition['changedCoordinates'],
      );
      expect(_transitionKind(board.lastTransition.kind), transition['kind']);

      if (revision + 1 < expectedBoards.length) {
        final TargetCandidateV2 selected = candidates.singleWhere(
          (TargetCandidateV2 candidate) => candidate.result == board.target,
        );
        final ChainReleaseResultV2 release = BoardEngineV2.release(
          state: board,
          path: selected.canonicalHintPath,
          map: map,
        );
        expect(release.status, ChainReleaseStatusV2.accepted);
        board = release.board;
      }
    }
  });

  test('score and board replay match shared rs-v2 fixture', () {
    final Map<String, dynamic> fixture = _fixture(
      'replay/rs-v2/target-swipe.json',
    );
    final MapDefinitionV2 map = maps.map(fixture['mapId'] as String);
    BoardStateV2 board = BoardGeneratorV2.generate(
      seed: fixture['seed'] as String,
      map: map,
    );
    ScoreStateV2 score = const ScoreStateV2();

    for (final dynamic rawEvent in fixture['events'] as List<dynamic>) {
      final Map<String, dynamic> event = rawEvent as Map<String, dynamic>;
      final Map<String, dynamic> expected =
          event['expected'] as Map<String, dynamic>;
      final List<AxialCoordinate> path = (event['path'] as List<dynamic>)
          .map((dynamic raw) => _coordinate(raw as Map<String, dynamic>))
          .toList();
      expect(board.revision, event['boardRevision']);
      expect(board.target, event['targetBefore']);
      final List<Operator> operators = <Operator>[
        for (final AxialCoordinate coordinate in path)
          if (board.tileAt(coordinate) case final BoardTileV2 tile
              when tile.kind == BoardTileKindV2.operator)
            tile.operator!,
      ];
      final ChainReleaseResultV2 release = BoardEngineV2.release(
        state: board,
        path: path,
        map: map,
      );
      final int tMs = event['tMs'] as int;
      final ScoreTransitionV2 scoreTransition = release.consumed
          ? ScoringV2.accepted(
              ruleset: ruleset,
              state: score,
              tMs: tMs,
              operators: operators,
            )
          : ScoringV2.rejected(ruleset: ruleset, state: score, tMs: tMs);
      score = scoreTransition.state;
      board = release.board;

      expect(_releaseStatus(release.status), expected['status']);
      expect(release.expression?.value, expected['value']);
      expect(scoreTransition.awardedScore, expected['awardedScore']);
      expect(score.totalScore, expected['runningTotal']);
      expect(board.revision, expected['nextBoardRevision']);
      expect(board.target, expected['nextTarget']);
    }

    final Map<String, dynamic> expected =
        fixture['expected'] as Map<String, dynamic>;
    expect(score.totalScore, expected['totalScore']);
    expect(score.comboCount, expected['comboCount']);
    expect(score.feverEnergy, expected['feverEnergy']);
    expect(score.feverActive, expected['feverActive']);
    expect(score.targetsSolved, expected['targetsSolved']);
    expect(board.revision, expected['finalBoardRevision']);
    expect(board.target, expected['finalTarget']);
  });
}

Map<String, dynamic> _fixture(String relativePath) =>
    jsonDecode(File('test/contract/fixtures/$relativePath').readAsStringSync())
        as Map<String, dynamic>;

Token _token(Map<String, dynamic> json) => switch (json['kind']) {
  'number' => Token.number(json['value'] as int),
  'operator' => Token.op(_operator(json['operator'] as String)),
  'equals' => Token.equals,
  _ => throw FormatException('Unknown token kind ${json['kind']}'),
};

Operator _operator(String value) => switch (value) {
  'add' => Operator.add,
  'subtract' => Operator.subtract,
  'multiply' => Operator.multiply,
  'divide' => Operator.divide,
  _ => throw FormatException('Unknown operator $value'),
};

String _operatorName(Operator value) => switch (value) {
  Operator.add => 'add',
  Operator.subtract => 'subtract',
  Operator.multiply => 'multiply',
  Operator.divide => 'divide',
};

AxialCoordinate _coordinate(Map<String, dynamic> json) =>
    AxialCoordinate(json['q'] as int, json['r'] as int);

Map<String, dynamic> _coordinateJson(AxialCoordinate coordinate) =>
    <String, dynamic>{'q': coordinate.q, 'r': coordinate.r};

Map<String, dynamic> _tileJson(BoardTileV2 tile) => <String, dynamic>{
  'kind': tile.kind == BoardTileKindV2.number ? 'number' : 'operator',
  if (tile.kind == BoardTileKindV2.number) 'value': tile.number,
  if (tile.kind == BoardTileKindV2.operator)
    'operator': _operatorName(tile.operator!),
  'q': tile.coordinate.q,
  'r': tile.coordinate.r,
};

Map<String, dynamic> _candidateJson(TargetCandidateV2 candidate) =>
    <String, dynamic>{
      'canonicalHintPath': candidate.canonicalHintPath
          .map(_coordinateJson)
          .toList(),
      'difficulty': candidate.difficulty,
      'result': candidate.result,
      'shortestChainCells': candidate.shortestChainLength,
      'solutionCount': candidate.solutionCount,
    };

String _expressionStatus(ExpressionStatusV2 status) => switch (status) {
  ExpressionStatusV2.valid => 'valid',
  ExpressionStatusV2.grammarError => 'grammarError',
  ExpressionStatusV2.arithmeticError => 'arithmeticError',
};

String _transitionKind(BoardTransitionKindV2 kind) => switch (kind) {
  BoardTransitionKindV2.initial => 'initialGeneration',
  BoardTransitionKindV2.acceptedRefill => 'refill',
  BoardTransitionKindV2.repairedRefill => 'deterministicRepair',
};

String _releaseStatus(ChainReleaseStatusV2 status) => switch (status) {
  ChainReleaseStatusV2.accepted => 'accepted',
  ChainReleaseStatusV2.incomplete => 'incomplete',
  ChainReleaseStatusV2.invalidChain => 'invalidChain',
  ChainReleaseStatusV2.arithmeticRejected => 'arithmeticRejected',
  ChainReleaseStatusV2.targetMismatch => 'targetMismatch',
};
