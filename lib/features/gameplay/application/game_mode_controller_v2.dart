import '../domain/domain.dart';
import 'game_session_config.dart';

/// Narrow mode-policy seam around the shared swipe/evaluate/refill engine.
abstract interface class GameModeControllerV2 {
  V2GameMode get mode;
  int? get durationMs;
  int? get targetQuota;
  bool get allowsManualFinish;

  bool completesAfterSolve(int targetsSolved);
  int? rating({required int targetsSolved, required int score});
}

class GameModeControllerFactoryV2 {
  GameModeControllerFactoryV2._();

  static GameModeControllerV2 create({
    required GameSessionConfig config,
    required MapDefinitionV2 map,
    ModeCatalogV1? catalog,
  }) {
    final GameModeDefinitionV2 definition = catalog == null
        ? ModeCatalogV1.definition(config.mode.wireName)
        : catalog.mode(config.mode.wireName);
    final int? duration = config.durationMs ?? definition.durationFor(map);
    return switch (config.mode) {
      V2GameMode.timeAttack => TimeAttackModeControllerV2(
        durationMs: duration!,
      ),
      V2GameMode.ranked => RankedModeControllerV2(durationMs: duration!),
      V2GameMode.level => LevelModeControllerV2(map.levelGoal),
      V2GameMode.endless => const EndlessModeControllerV2(),
      V2GameMode.daily => DailyModeControllerV2(durationMs: duration!),
    };
  }
}

abstract class _TimedModeControllerV2 implements GameModeControllerV2 {
  const _TimedModeControllerV2(this.durationMs);

  @override
  final int durationMs;
  @override
  int? get targetQuota => null;
  @override
  bool get allowsManualFinish => false;
  @override
  bool completesAfterSolve(int targetsSolved) => false;
  @override
  int? rating({required int targetsSolved, required int score}) => null;
}

class TimeAttackModeControllerV2 extends _TimedModeControllerV2 {
  const TimeAttackModeControllerV2({required int durationMs})
    : super(durationMs);

  @override
  V2GameMode get mode => V2GameMode.timeAttack;
}

class RankedModeControllerV2 extends _TimedModeControllerV2 {
  const RankedModeControllerV2({required int durationMs}) : super(durationMs);

  @override
  V2GameMode get mode => V2GameMode.ranked;
}

class DailyModeControllerV2 extends _TimedModeControllerV2 {
  const DailyModeControllerV2({required int durationMs}) : super(durationMs);

  @override
  V2GameMode get mode => V2GameMode.daily;
}

class LevelModeControllerV2 implements GameModeControllerV2 {
  const LevelModeControllerV2(this.goal);

  final LevelGoalV2 goal;

  @override
  V2GameMode get mode => V2GameMode.level;
  @override
  int get durationMs => goal.durationMs;
  @override
  int get targetQuota => goal.targetQuota;
  @override
  bool get allowsManualFinish => false;
  @override
  bool completesAfterSolve(int targetsSolved) =>
      targetsSolved >= goal.targetQuota;
  @override
  int rating({required int targetsSolved, required int score}) =>
      LevelRatingV2.calculate(
        goal: goal,
        targetsSolved: targetsSolved,
        score: score,
      );
}

class EndlessModeControllerV2 implements GameModeControllerV2 {
  const EndlessModeControllerV2();

  @override
  V2GameMode get mode => V2GameMode.endless;
  @override
  int? get durationMs => null;
  @override
  int? get targetQuota => null;
  @override
  bool get allowsManualFinish => true;
  @override
  bool completesAfterSolve(int targetsSolved) => false;
  @override
  int? rating({required int targetsSolved, required int score}) => null;
}
