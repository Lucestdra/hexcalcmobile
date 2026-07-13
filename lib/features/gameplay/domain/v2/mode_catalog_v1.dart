/// Shared rule policies for the five `modes-v1` game modes.
library;

import 'map_catalog_v1.dart';

class GameModeIdsV1 {
  GameModeIdsV1._();

  static const String timeAttack = 'timeAttack';
  static const String ranked = 'ranked';
  static const String level = 'level';
  static const String endless = 'endless';
  static const String daily = 'daily';
}

class GameModeDefinitionV2 {
  const GameModeDefinitionV2({
    required this.id,
    this.order = 0,
    this.name = '',
    required this.defaultDurationMs,
    required this.usesMapLevelGoal,
    this.fixedTargetQuota,
    required this.continuousRefill,
    required this.manualFinish,
    required this.competitive,
    required this.leaderboardEligible,
    required this.oneAttemptPerUtcDay,
    required this.awardsLevelRating,
    this.mapSelection = '',
  });

  final String id;
  final int order;
  final String name;
  final int? defaultDurationMs;
  final bool usesMapLevelGoal;
  final int? fixedTargetQuota;
  final bool continuousRefill;
  final bool manualFinish;
  final bool competitive;
  final bool leaderboardEligible;
  final bool oneAttemptPerUtcDay;
  final bool awardsLevelRating;
  final String mapSelection;

  int? durationFor(MapDefinitionV2 map) =>
      usesMapLevelGoal ? map.levelGoal.durationMs : defaultDurationMs;

  int? targetQuotaFor(MapDefinitionV2 map) =>
      usesMapLevelGoal ? map.levelGoal.targetQuota : fixedTargetQuota;
}

class ModeCatalogV1 {
  ModeCatalogV1._({required this.version, required this.modes})
    : modesById = Map<String, GameModeDefinitionV2>.unmodifiable(
        <String, GameModeDefinitionV2>{
          for (final GameModeDefinitionV2 mode in modes) mode.id: mode,
        },
      );

  factory ModeCatalogV1.fromJson(Map<String, dynamic> json) {
    final dynamic version = json['catalogVersion'];
    final dynamic rawModes = json['modes'];
    if (version is! String || rawModes is! List<dynamic>) {
      throw const FormatException(
        'Mode catalog requires catalogVersion and modes',
      );
    }
    final List<GameModeDefinitionV2> modes = <GameModeDefinitionV2>[];
    for (int index = 0; index < rawModes.length; index++) {
      final dynamic raw = rawModes[index];
      if (raw is! Map<String, dynamic>) {
        throw FormatException('modes[$index] must be an object');
      }
      T requiredValue<T>(String key) {
        final dynamic value = raw[key];
        if (value is! T) {
          throw FormatException('modes[$index].$key has the wrong type');
        }
        return value;
      }

      final bool requiresServer = requiredValue<bool>(
        'requiresServerChallenge',
      );
      final dynamic duration = raw['durationMs'];
      final dynamic quota = raw['targetQuota'];
      final dynamic attemptLimit = raw['attemptLimit'];
      if (duration != null && duration is! int ||
          quota != null && quota is! int ||
          attemptLimit != null && attemptLimit is! int) {
        throw FormatException('modes[$index] has invalid nullable integers');
      }
      modes.add(
        GameModeDefinitionV2(
          id: requiredValue<String>('id'),
          order: requiredValue<int>('order'),
          name: requiredValue<String>('name'),
          defaultDurationMs: duration as int?,
          usesMapLevelGoal: requiredValue<bool>('usesMapLevelGoal'),
          fixedTargetQuota: quota as int?,
          continuousRefill: requiredValue<bool>('refillAfterSolve'),
          manualFinish: requiredValue<bool>('manualFinish'),
          competitive: requiresServer,
          leaderboardEligible: requiredValue<bool>('leaderboardEligible'),
          oneAttemptPerUtcDay: attemptLimit == 1,
          awardsLevelRating: requiredValue<bool>('performanceRating'),
          mapSelection: requiredValue<String>('mapSelection'),
        ),
      );
    }
    modes.sort(
      (GameModeDefinitionV2 a, GameModeDefinitionV2 b) =>
          a.order.compareTo(b.order),
    );
    return ModeCatalogV1._(
      version: version,
      modes: List<GameModeDefinitionV2>.unmodifiable(modes),
    );
  }

  static const String catalogVersion = 'modes-v1';

  final String version;
  final List<GameModeDefinitionV2> modes;
  final Map<String, GameModeDefinitionV2> modesById;

  static const List<GameModeDefinitionV2> definitions = <GameModeDefinitionV2>[
    GameModeDefinitionV2(
      id: GameModeIdsV1.timeAttack,
      defaultDurationMs: 60000,
      usesMapLevelGoal: false,
      continuousRefill: true,
      manualFinish: false,
      competitive: false,
      leaderboardEligible: false,
      oneAttemptPerUtcDay: false,
      awardsLevelRating: false,
    ),
    GameModeDefinitionV2(
      id: GameModeIdsV1.ranked,
      defaultDurationMs: 60000,
      usesMapLevelGoal: false,
      continuousRefill: true,
      manualFinish: false,
      competitive: true,
      leaderboardEligible: true,
      oneAttemptPerUtcDay: false,
      awardsLevelRating: false,
    ),
    GameModeDefinitionV2(
      id: GameModeIdsV1.level,
      defaultDurationMs: null,
      usesMapLevelGoal: true,
      continuousRefill: true,
      manualFinish: false,
      competitive: false,
      leaderboardEligible: false,
      oneAttemptPerUtcDay: false,
      awardsLevelRating: true,
    ),
    GameModeDefinitionV2(
      id: GameModeIdsV1.endless,
      defaultDurationMs: null,
      usesMapLevelGoal: false,
      continuousRefill: true,
      manualFinish: true,
      competitive: false,
      leaderboardEligible: false,
      oneAttemptPerUtcDay: false,
      awardsLevelRating: false,
    ),
    GameModeDefinitionV2(
      id: GameModeIdsV1.daily,
      defaultDurationMs: 60000,
      usesMapLevelGoal: false,
      continuousRefill: true,
      manualFinish: false,
      competitive: true,
      leaderboardEligible: false,
      oneAttemptPerUtcDay: true,
      awardsLevelRating: false,
    ),
  ];

  static GameModeDefinitionV2 definition(String id) => definitions.firstWhere(
    (GameModeDefinitionV2 definition) => definition.id == id,
    orElse: () => throw ArgumentError.value(id, 'id', 'Unknown game mode'),
  );

  GameModeDefinitionV2 mode(String id) {
    final GameModeDefinitionV2? result = modesById[id];
    if (result == null) {
      throw ArgumentError.value(id, 'id', 'Unknown game mode');
    }
    return result;
  }
}

class LevelRatingV2 {
  LevelRatingV2._();

  static int calculate({
    required LevelGoalV2 goal,
    required int targetsSolved,
    required int score,
  }) {
    if (targetsSolved < goal.targetQuota) {
      return 0;
    }
    int stars = 0;
    for (final int threshold in goal.starScoreThresholds) {
      if (score >= threshold) {
        stars++;
      }
    }
    return stars.clamp(0, 3);
  }
}
