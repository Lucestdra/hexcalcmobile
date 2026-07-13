import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'v2_test_support.dart';

void main() {
  late RulesetV2 ruleset;
  setUpAll(() {
    ruleset = RulesetV2.fromJson(
      jsonDecode(File('assets/gameplay/rs-v2.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('rs-v2 parses canonical scoring values', () {
    expect(ruleset.rulesetVersion, 'rs-v2');
    expect(ruleset.scoring.baseChainScore, 100);
    expect(ruleset.scoring.lengthBonusPerAdditionalOperator, 20);
    expect(ruleset.scoring.operatorBonus(Operator.divide), 15);
    expect(ruleset.fever.threshold, 8);
  });

  test('accepted scoring applies speed, combo and one final truncation', () {
    final ScoreUpdateV2 first = ScoringV2.accepted(
      ruleset: ruleset,
      state: const ScoreStateV2(),
      tMs: 0,
      operators: const <Operator>[Operator.add],
    );
    expect(first.awardedScore, 100);
    expect(first.state.comboCount, 1);

    final ScoreUpdateV2 second = ScoringV2.accepted(
      ruleset: ruleset,
      state: first.state,
      tMs: 1000,
      operators: const <Operator>[Operator.multiply, Operator.subtract],
    );
    // raw = 100 + 20 + 10 + 5 + 33 speed = 168; combo is 110%.
    expect(second.awardedScore, 184);
    expect(second.state.totalScore, 284);
    expect(second.state.comboCount, 2);
  });

  test(
    'wrong complete chain resets combo and drains non-active Fever energy',
    () {
      final ScoreUpdateV2 rejected = ScoringV2.rejected(
        ruleset: ruleset,
        state: const ScoreStateV2(
          totalScore: 500,
          comboCount: 4,
          feverEnergy: 6,
          lastAcceptedAtMs: 1000,
        ),
        tMs: 2000,
      );
      expect(rejected.awardedScore, 0);
      expect(rejected.state.totalScore, 500);
      expect(rejected.state.comboCount, 0);
      expect(rejected.state.feverEnergy, 2);
    },
  );

  test('mode catalog separates timers and competitive policies', () {
    final MapDefinitionV2 map = simpleMap();
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.timeAttack).durationFor(map),
      60000,
    );
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.endless).durationFor(map),
      isNull,
    );
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.level).targetQuotaFor(map),
      map.levelGoal.targetQuota,
    );
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.ranked).leaderboardEligible,
      isTrue,
    );
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.daily).leaderboardEligible,
      isFalse,
    );
    expect(
      ModeCatalogV1.definition(GameModeIdsV1.daily).oneAttemptPerUtcDay,
      isTrue,
    );
  });

  test('modes-v1 asset parses into the same five stable policies', () {
    final ModeCatalogV1 catalog = ModeCatalogV1.fromJson(
      jsonDecode(File('assets/gameplay/modes-v1.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    expect(catalog.version, ModeCatalogV1.catalogVersion);
    expect(catalog.modes.map((GameModeDefinitionV2 mode) => mode.id), <String>[
      GameModeIdsV1.timeAttack,
      GameModeIdsV1.ranked,
      GameModeIdsV1.level,
      GameModeIdsV1.endless,
      GameModeIdsV1.daily,
    ]);
    expect(catalog.mode(GameModeIdsV1.endless).manualFinish, isTrue);
  });

  test('level ratings require quota and use three explicit thresholds', () {
    final LevelGoalV2 goal = LevelGoalV2(
      durationMs: 60000,
      targetQuota: 6,
      starScoreThresholds: const <int>[600, 900, 1350],
    );
    expect(
      LevelRatingV2.calculate(goal: goal, targetsSolved: 5, score: 9999),
      0,
    );
    expect(
      LevelRatingV2.calculate(goal: goal, targetsSolved: 6, score: 899),
      1,
    );
    expect(
      LevelRatingV2.calculate(goal: goal, targetsSolved: 6, score: 1350),
      3,
    );
  });
}
