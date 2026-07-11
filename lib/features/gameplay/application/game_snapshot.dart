import 'game_phase.dart';

/// An immutable, HUD-facing snapshot of the run. Bridged from the controller to
/// Flutter only on meaningful changes — never per frame.
class GameSnapshot {
  const GameSnapshot({
    required this.phase,
    required this.score,
    required this.timeRemainingMs,
    required this.comboCount,
    required this.feverActive,
    required this.feverEnergy,
    required this.feverThreshold,
    required this.level,
    required this.equationsThisLevel,
    required this.equationsRequiredThisLevel,
    required this.target,
    required this.pathLength,
    required this.lastEquationCorrect,
    required this.equationsSolved,
    required this.bestCombo,
  });

  final GamePhase phase;
  final int score;
  final int timeRemainingMs;
  final int comboCount;
  final bool feverActive;
  final int feverEnergy;
  final int feverThreshold;
  final int level;
  final int equationsThisLevel;
  final int equationsRequiredThisLevel;
  final int target;
  final int pathLength;

  /// null before any equation; true/false after a correct/wrong one.
  final bool? lastEquationCorrect;

  final int equationsSolved;
  final int bestCombo;

  int get timeRemainingSeconds => (timeRemainingMs / 1000).ceil();

  bool get finished => phase == GamePhase.finished;

  static const GameSnapshot empty = GameSnapshot(
    phase: GamePhase.idle,
    score: 0,
    timeRemainingMs: 60000,
    comboCount: 0,
    feverActive: false,
    feverEnergy: 0,
    feverThreshold: 8,
    level: 0,
    equationsThisLevel: 0,
    equationsRequiredThisLevel: 5,
    target: 0,
    pathLength: 0,
    lastEquationCorrect: null,
    equationsSolved: 0,
    bestCombo: 0,
  );
}
