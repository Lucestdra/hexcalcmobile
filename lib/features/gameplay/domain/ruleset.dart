/// Versioned gameplay tuning — Dart twin of the C# Ruleset.
/// See the backend spec docs/gameplay/scoring-and-replay.md. Integer-only;
/// percents are 100-based (100 == x1.0).
library;

import 'expression.dart';

class Ruleset {
  const Ruleset({
    required this.rulesetVersion,
    required this.run,
    required this.level,
    required this.combo,
    required this.fever,
    required this.scoring,
  });

  final String rulesetVersion;
  final RunConfig run;
  final LevelConfig level;
  final ComboConfig combo;
  final FeverConfig fever;
  final ScoringConfig scoring;

  static Ruleset fromJson(Map<String, dynamic> j) {
    final run = j['run'] as Map<String, dynamic>;
    final level = j['level'] as Map<String, dynamic>;
    final combo = j['combo'] as Map<String, dynamic>;
    final fever = j['fever'] as Map<String, dynamic>;
    final scoring = j['scoring'] as Map<String, dynamic>;
    final opBonus = scoring['operatorDifficultyBonus'] as Map<String, dynamic>;

    return Ruleset(
      rulesetVersion: j['rulesetVersion'] as String,
      run: RunConfig(durationMs: run['durationMs'] as int),
      level: LevelConfig(
        equationsToComplete: level['equationsToComplete'] as int,
        growthPerLevel: level['growthPerLevel'] as int,
      ),
      combo: ComboConfig(windowMs: combo['windowMs'] as int),
      fever: FeverConfig(
        threshold: fever['threshold'] as int,
        durationMs: fever['durationMs'] as int,
        multiplierPercent: fever['multiplierPercent'] as int,
        wrongEnergyPenalty: fever['wrongEnergyPenalty'] as int,
      ),
      scoring: ScoringConfig(
        baseEquationScore: scoring['baseEquationScore'] as int,
        lengthBonusPerUnit: scoring['lengthBonusPerUnit'] as int,
        operatorBonusAdd: opBonus['add'] as int,
        operatorBonusSubtract: opBonus['subtract'] as int,
        operatorBonusMultiply: opBonus['multiply'] as int,
        operatorBonusDivide: opBonus['divide'] as int,
        speedBonusMax: scoring['speedBonusMax'] as int,
        speedBonusWindowMs: scoring['speedBonusWindowMs'] as int,
        targetMatchPercent: scoring['targetMatchPercent'] as int,
        comboBasePercent: scoring['comboBasePercent'] as int,
        comboStepPercent: scoring['comboStepPercent'] as int,
        comboMaxPercent: scoring['comboMaxPercent'] as int,
      ),
    );
  }
}

class RunConfig {
  const RunConfig({required this.durationMs});
  final int durationMs;
}

class LevelConfig {
  const LevelConfig({
    required this.equationsToComplete,
    required this.growthPerLevel,
  });
  final int equationsToComplete;
  final int growthPerLevel;
}

class ComboConfig {
  const ComboConfig({required this.windowMs});
  final int windowMs;
}

class FeverConfig {
  const FeverConfig({
    required this.threshold,
    required this.durationMs,
    required this.multiplierPercent,
    required this.wrongEnergyPenalty,
  });
  final int threshold;
  final int durationMs;
  final int multiplierPercent;
  final int wrongEnergyPenalty;
}

class ScoringConfig {
  const ScoringConfig({
    required this.baseEquationScore,
    required this.lengthBonusPerUnit,
    required this.operatorBonusAdd,
    required this.operatorBonusSubtract,
    required this.operatorBonusMultiply,
    required this.operatorBonusDivide,
    required this.speedBonusMax,
    required this.speedBonusWindowMs,
    required this.targetMatchPercent,
    required this.comboBasePercent,
    required this.comboStepPercent,
    required this.comboMaxPercent,
  });

  final int baseEquationScore;
  final int lengthBonusPerUnit;
  final int operatorBonusAdd;
  final int operatorBonusSubtract;
  final int operatorBonusMultiply;
  final int operatorBonusDivide;
  final int speedBonusMax;
  final int speedBonusWindowMs;
  final int targetMatchPercent;
  final int comboBasePercent;
  final int comboStepPercent;
  final int comboMaxPercent;

  int operatorBonus(Operator op) {
    switch (op) {
      case Operator.add:
        return operatorBonusAdd;
      case Operator.subtract:
        return operatorBonusSubtract;
      case Operator.multiply:
        return operatorBonusMultiply;
      case Operator.divide:
        return operatorBonusDivide;
    }
  }
}
