import 'game_phase.dart';
import 'game_session_config.dart';

/// Immutable Flutter-facing state for target-swipe sessions. A null remaining
/// time is the deliberate Endless representation, never a sentinel duration.
class GameSnapshotV2 {
  const GameSnapshotV2({
    required this.phase,
    required this.mode,
    required this.mapId,
    required this.mapName,
    required this.score,
    required this.timeRemainingMs,
    required this.comboCount,
    required this.feverActive,
    required this.feverEnergy,
    required this.feverThreshold,
    required this.target,
    required this.expression,
    required this.pathLength,
    required this.boardRevision,
    required this.targetsSolved,
    required this.targetQuota,
    required this.bestCombo,
    required this.rating,
    required this.levelCompleted,
    required this.lastChainCorrect,
  });

  final GamePhase phase;
  final V2GameMode mode;
  final String mapId;
  final String mapName;
  final int score;
  final int? timeRemainingMs;
  final int comboCount;
  final bool feverActive;
  final int feverEnergy;
  final int feverThreshold;
  final int target;
  final String expression;
  final int pathLength;
  final int boardRevision;
  final int targetsSolved;
  final int? targetQuota;
  final int bestCombo;
  final int? rating;
  final bool levelCompleted;
  final bool? lastChainCorrect;

  int? get timeRemainingSeconds =>
      timeRemainingMs == null ? null : (timeRemainingMs! / 1000).ceil();

  bool get finished => phase == GamePhase.finished;
  bool get hasTimer => timeRemainingMs != null;
}
