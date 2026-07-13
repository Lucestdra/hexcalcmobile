/// Integer-only scoring, combo, and Fever policy for `rs-v2`.
library;

import '../expression.dart';

class RulesetV2 {
  const RulesetV2({
    required this.rulesetVersion,
    required this.combo,
    required this.fever,
    required this.scoring,
  });

  factory RulesetV2.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> combo = json['combo'] as Map<String, dynamic>;
    final Map<String, dynamic> fever = json['fever'] as Map<String, dynamic>;
    final Map<String, dynamic> scoring =
        json['scoring'] as Map<String, dynamic>;
    final Map<String, dynamic> operatorBonus =
        scoring['operatorDifficultyBonus'] as Map<String, dynamic>;
    return RulesetV2(
      rulesetVersion: json['rulesetVersion'] as String,
      combo: ComboRulesV2(windowMs: combo['windowMs'] as int),
      fever: FeverRulesV2(
        threshold: fever['threshold'] as int,
        durationMs: fever['durationMs'] as int,
        multiplierPercent: fever['multiplierPercent'] as int,
        wrongEnergyPenalty: fever['wrongEnergyPenalty'] as int,
      ),
      scoring: ScoringRulesV2(
        baseChainScore: scoring['baseChainScore'] as int,
        lengthBonusPerAdditionalOperator:
            scoring['lengthBonusPerAdditionalOperator'] as int,
        operatorBonusAdd: operatorBonus['add'] as int,
        operatorBonusSubtract: operatorBonus['subtract'] as int,
        operatorBonusMultiply: operatorBonus['multiply'] as int,
        operatorBonusDivide: operatorBonus['divide'] as int,
        speedBonusMax: scoring['speedBonusMax'] as int,
        speedBonusWindowMs: scoring['speedBonusWindowMs'] as int,
        comboBasePercent: scoring['comboBasePercent'] as int,
        comboStepPercent: scoring['comboStepPercent'] as int,
        comboMaxPercent: scoring['comboMaxPercent'] as int,
      ),
    );
  }

  final String rulesetVersion;
  final ComboRulesV2 combo;
  final FeverRulesV2 fever;
  final ScoringRulesV2 scoring;
}

class ComboRulesV2 {
  const ComboRulesV2({required this.windowMs});
  final int windowMs;
}

class FeverRulesV2 {
  const FeverRulesV2({
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

class ScoringRulesV2 {
  const ScoringRulesV2({
    required this.baseChainScore,
    required this.lengthBonusPerAdditionalOperator,
    required this.operatorBonusAdd,
    required this.operatorBonusSubtract,
    required this.operatorBonusMultiply,
    required this.operatorBonusDivide,
    required this.speedBonusMax,
    required this.speedBonusWindowMs,
    required this.comboBasePercent,
    required this.comboStepPercent,
    required this.comboMaxPercent,
  });

  final int baseChainScore;
  final int lengthBonusPerAdditionalOperator;
  final int operatorBonusAdd;
  final int operatorBonusSubtract;
  final int operatorBonusMultiply;
  final int operatorBonusDivide;
  final int speedBonusMax;
  final int speedBonusWindowMs;
  final int comboBasePercent;
  final int comboStepPercent;
  final int comboMaxPercent;

  int operatorBonus(Operator operator) => switch (operator) {
    Operator.add => operatorBonusAdd,
    Operator.subtract => operatorBonusSubtract,
    Operator.multiply => operatorBonusMultiply,
    Operator.divide => operatorBonusDivide,
  };
}

class ScoreStateV2 {
  const ScoreStateV2({
    this.totalScore = 0,
    this.comboCount = 0,
    this.feverEnergy = 0,
    this.feverActive = false,
    this.feverEndsAtMs = 0,
    this.lastAcceptedAtMs,
    this.targetsSolved = 0,
  });

  final int totalScore;
  final int comboCount;
  final int feverEnergy;
  final bool feverActive;
  final int feverEndsAtMs;
  final int? lastAcceptedAtMs;
  final int targetsSolved;
}

class ScoreEventV2 {
  ScoreEventV2({
    required this.tMs,
    required this.accepted,
    required Iterable<Operator> operators,
  }) : operators = List<Operator>.unmodifiable(operators);

  final int tMs;
  final bool accepted;
  final List<Operator> operators;
}

class ScoreUpdateV2 {
  const ScoreUpdateV2({required this.state, required this.awardedScore});
  final ScoreStateV2 state;
  final int awardedScore;
}

typedef ScoreTransitionV2 = ScoreUpdateV2;

class ScoreReplayResultV2 {
  ScoreReplayResultV2({
    required this.finalState,
    required Iterable<int> runningTotals,
  }) : runningTotals = List<int>.unmodifiable(runningTotals);

  final ScoreStateV2 finalState;
  final List<int> runningTotals;
}

class ScoringV2 {
  ScoringV2._();

  static ScoreUpdateV2 accepted({
    required RulesetV2 ruleset,
    required ScoreStateV2 state,
    required int tMs,
    required List<Operator> operators,
  }) {
    if (tMs < 0) {
      throw ArgumentError.value(tMs, 'tMs', 'Event time cannot be negative');
    }
    if (operators.isEmpty || operators.length > 3) {
      throw ArgumentError.value(
        operators,
        'operators',
        'An accepted chain must contain one to three operators',
      );
    }
    final _ExpiredFeverV2 expired = _expireFever(ruleset, state, tMs);
    final int? previous = state.lastAcceptedAtMs;
    final int comboCount =
        previous != null && tMs - previous <= ruleset.combo.windowMs
        ? expired.comboCount + 1
        : 1;
    final int gapMs = previous == null
        ? ruleset.scoring.speedBonusWindowMs
        : tMs - previous;
    final int raw =
        ruleset.scoring.baseChainScore +
        ruleset.scoring.lengthBonusPerAdditionalOperator *
            (operators.length > 1 ? operators.length - 1 : 0) +
        operators.fold<int>(
          0,
          (int total, Operator operator) =>
              total + ruleset.scoring.operatorBonus(operator),
        ) +
        _speedBonus(ruleset.scoring, gapMs);
    final int rawComboPercent =
        ruleset.scoring.comboBasePercent +
        ruleset.scoring.comboStepPercent * (comboCount - 1);
    final int comboPercent = rawComboPercent < ruleset.scoring.comboMaxPercent
        ? rawComboPercent
        : ruleset.scoring.comboMaxPercent;
    final int feverPercent = expired.feverActive
        ? ruleset.fever.multiplierPercent
        : 100;
    final int awarded = raw * comboPercent * feverPercent ~/ 10000;

    int feverEnergy = expired.feverEnergy;
    bool feverActive = expired.feverActive;
    int feverEndsAtMs = expired.feverEndsAtMs;
    if (!feverActive) {
      feverEnergy++;
      if (feverEnergy >= ruleset.fever.threshold) {
        feverActive = true;
        feverEndsAtMs = tMs + ruleset.fever.durationMs;
        feverEnergy = 0;
      }
    }

    return ScoreUpdateV2(
      state: ScoreStateV2(
        totalScore: state.totalScore + awarded,
        comboCount: comboCount,
        feverEnergy: feverEnergy,
        feverActive: feverActive,
        feverEndsAtMs: feverEndsAtMs,
        lastAcceptedAtMs: tMs,
        targetsSolved: state.targetsSolved + 1,
      ),
      awardedScore: awarded,
    );
  }

  /// Applies a wrong complete chain. Incomplete rewinds must not call this.
  static ScoreUpdateV2 rejected({
    required RulesetV2 ruleset,
    required ScoreStateV2 state,
    required int tMs,
  }) {
    if (tMs < 0) {
      throw ArgumentError.value(tMs, 'tMs', 'Event time cannot be negative');
    }
    final _ExpiredFeverV2 expired = _expireFever(ruleset, state, tMs);
    final int feverEnergy = expired.feverActive
        ? expired.feverEnergy
        : (expired.feverEnergy - ruleset.fever.wrongEnergyPenalty).clamp(
            0,
            expired.feverEnergy,
          );
    return ScoreUpdateV2(
      state: ScoreStateV2(
        totalScore: state.totalScore,
        feverEnergy: feverEnergy,
        feverActive: expired.feverActive,
        feverEndsAtMs: expired.feverEndsAtMs,
        lastAcceptedAtMs: state.lastAcceptedAtMs,
        targetsSolved: state.targetsSolved,
      ),
      awardedScore: 0,
    );
  }

  static int _speedBonus(ScoringRulesV2 scoring, int gapMs) {
    if (gapMs >= scoring.speedBonusWindowMs) {
      return 0;
    }
    return scoring.speedBonusMax *
        (scoring.speedBonusWindowMs - gapMs) ~/
        scoring.speedBonusWindowMs;
  }

  static ScoreTransitionV2 apply({
    required RulesetV2 ruleset,
    required ScoreStateV2 state,
    required ScoreEventV2 event,
  }) => event.accepted
      ? accepted(
          ruleset: ruleset,
          state: state,
          tMs: event.tMs,
          operators: event.operators,
        )
      : rejected(ruleset: ruleset, state: state, tMs: event.tMs);

  static ScoreReplayResultV2 replay({
    required RulesetV2 ruleset,
    required List<ScoreEventV2> events,
  }) {
    ScoreStateV2 state = const ScoreStateV2();
    int previousTMs = -1;
    final List<int> runningTotals = <int>[];
    for (final ScoreEventV2 event in events) {
      if (event.tMs < previousTMs) {
        throw ArgumentError('Score event times must be non-decreasing');
      }
      state = apply(ruleset: ruleset, state: state, event: event).state;
      runningTotals.add(state.totalScore);
      previousTMs = event.tMs;
    }
    return ScoreReplayResultV2(finalState: state, runningTotals: runningTotals);
  }

  static _ExpiredFeverV2 _expireFever(
    RulesetV2 ruleset,
    ScoreStateV2 state,
    int tMs,
  ) {
    if (state.feverActive && tMs >= state.feverEndsAtMs) {
      return _ExpiredFeverV2(
        comboCount: state.comboCount,
        feverEnergy: 0,
        feverActive: false,
        feverEndsAtMs: state.feverEndsAtMs,
      );
    }
    return _ExpiredFeverV2(
      comboCount: state.comboCount,
      feverEnergy: state.feverEnergy,
      feverActive: state.feverActive,
      feverEndsAtMs: state.feverEndsAtMs,
    );
  }
}

class _ExpiredFeverV2 {
  const _ExpiredFeverV2({
    required this.comboCount,
    required this.feverEnergy,
    required this.feverActive,
    required this.feverEndsAtMs,
  });

  final int comboCount;
  final int feverEnergy;
  final bool feverActive;
  final int feverEndsAtMs;
}
