/// Scoring/combo/Fever replay — Dart twin of the C# ReplayEngine.
/// Integer-only, deterministic. See the backend spec
/// docs/gameplay/scoring-and-replay.md §5.
library;

import 'expression.dart';
import 'ruleset.dart';

class RunEvent {
  const RunEvent({
    required this.tMs,
    required this.correct,
    required this.matchedTarget,
    required this.operators,
  });

  final int tMs;
  final bool correct;
  final bool matchedTarget;
  final List<Operator> operators;
}

class ReplayResult {
  const ReplayResult({
    required this.totalScore,
    required this.comboCount,
    required this.consecutiveCorrect,
    required this.feverEnergy,
    required this.feverActive,
    required this.level,
    required this.equationsThisLevel,
  });

  final int totalScore;
  final int comboCount;
  final int consecutiveCorrect;
  final int feverEnergy;
  final bool feverActive;
  final int level;
  final int equationsThisLevel;
}

class ReplayOutcome {
  const ReplayOutcome(this.finalState, this.runningTotals);
  final ReplayResult finalState;
  final List<int> runningTotals;
}

class ReplayEngine {
  ReplayEngine._();

  static ReplayOutcome replay(Ruleset ruleset, List<RunEvent> events) {
    final ScoringConfig s = ruleset.scoring;

    int totalScore = 0;
    int comboCount = 0;
    int consecutiveCorrect = 0;
    int feverEnergy = 0;
    bool feverActive = false;
    int feverEndsAtMs = 0;
    bool hasLastCorrect = false;
    int lastCorrectTMs = 0;
    int level = 0;
    int equationsThisLevel = 0;

    final List<int> runningTotals = <int>[];

    for (final RunEvent e in events) {
      // Step A — expire Fever.
      if (feverActive && e.tMs >= feverEndsAtMs) {
        feverActive = false;
        feverEnergy = 0;
      }

      if (e.correct) {
        // 1. Combo.
        final int? prev = hasLastCorrect ? lastCorrectTMs : null;
        if (prev != null && e.tMs - prev <= ruleset.combo.windowMs) {
          comboCount++;
        } else {
          comboCount = 1;
        }
        lastCorrectTMs = e.tMs;
        hasLastCorrect = true;

        // 2. Speed gap.
        final int gapMs = prev != null ? e.tMs - prev : s.speedBonusWindowMs;

        // 3. Raw score.
        final int lengthUnits = e.operators.length - 1 > 0
            ? e.operators.length - 1
            : 0;
        final int raw =
            s.baseEquationScore +
            s.lengthBonusPerUnit * lengthUnits +
            _sumOperatorBonus(s, e.operators) +
            _speedBonus(s, gapMs);

        // 4. Multipliers (percent, 100-based).
        final int targetPct = e.matchedTarget ? s.targetMatchPercent : 100;
        final int rawComboPct =
            s.comboBasePercent + s.comboStepPercent * (comboCount - 1);
        final int comboPct = rawComboPct < s.comboMaxPercent
            ? rawComboPct
            : s.comboMaxPercent;
        final int feverPct = feverActive
            ? ruleset.fever.multiplierPercent
            : 100;

        // 5. Final score — single truncating division, applied last.
        final int finalScore = raw * targetPct * comboPct * feverPct ~/ 1000000;
        totalScore += finalScore;

        // 6. Level progress.
        consecutiveCorrect++;
        equationsThisLevel++;
        final int required =
            ruleset.level.equationsToComplete +
            ruleset.level.growthPerLevel * level;
        if (equationsThisLevel >= required) {
          level++;
          equationsThisLevel = 0;
        }

        // 7. Fever ignition (only when Fever is not already active).
        if (!feverActive) {
          feverEnergy++;
          if (feverEnergy >= ruleset.fever.threshold) {
            feverActive = true;
            feverEndsAtMs = e.tMs + ruleset.fever.durationMs;
            feverEnergy = 0;
          }
        }
      } else {
        comboCount = 0;
        consecutiveCorrect = 0;
        if (!feverActive) {
          final int drained = feverEnergy - ruleset.fever.wrongEnergyPenalty;
          feverEnergy = drained > 0 ? drained : 0;
        }
      }

      runningTotals.add(totalScore);
    }

    final ReplayResult finalState = ReplayResult(
      totalScore: totalScore,
      comboCount: comboCount,
      consecutiveCorrect: consecutiveCorrect,
      feverEnergy: feverEnergy,
      feverActive: feverActive,
      level: level,
      equationsThisLevel: equationsThisLevel,
    );
    return ReplayOutcome(finalState, runningTotals);
  }

  static int _sumOperatorBonus(ScoringConfig s, List<Operator> operators) {
    int sum = 0;
    for (final Operator op in operators) {
      sum += s.operatorBonus(op);
    }
    return sum;
  }

  static int _speedBonus(ScoringConfig s, int gapMs) {
    if (gapMs >= s.speedBonusWindowMs) {
      return 0;
    }
    return s.speedBonusMax *
        (s.speedBonusWindowMs - gapMs) ~/
        s.speedBonusWindowMs;
  }
}
