/// Stable wire identifiers for the target-swipe v2 mode policies.
enum V2GameMode { timeAttack, ranked, level, endless, daily }

extension V2GameModeX on V2GameMode {
  String get wireName => switch (this) {
    V2GameMode.timeAttack => 'timeAttack',
    V2GameMode.ranked => 'ranked',
    V2GameMode.level => 'level',
    V2GameMode.endless => 'endless',
    V2GameMode.daily => 'daily',
  };

  bool get competitive => this == V2GameMode.ranked || this == V2GameMode.daily;
  bool get timed => this != V2GameMode.endless;
}

/// Every deterministic input that selects a gameplay implementation. Ranked and
/// Daily tokens bind these same identifiers on the backend.
class GameplayProtocolRef {
  const GameplayProtocolRef({
    required this.protocolVersion,
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.mapCatalogVersion,
    required this.modeCatalogVersion,
    required this.payloadVersion,
  });

  final String protocolVersion;
  final String rulesetVersion;
  final String generatorVersion;
  final String mapCatalogVersion;
  final String modeCatalogVersion;
  final int payloadVersion;

  static const GameplayProtocolRef targetSwipeV2 = GameplayProtocolRef(
    protocolVersion: 'target-swipe-v2',
    rulesetVersion: 'rs-v2',
    generatorVersion: 'gen-v2',
    mapCatalogVersion: 'maps-v1',
    modeCatalogVersion: 'modes-v1',
    payloadVersion: 2,
  );
}

class CompetitiveRunEnvelope {
  const CompetitiveRunEnvelope({
    required this.runId,
    required this.challengeToken,
  });

  final String runId;
  final String challengeToken;
}

class GameplayCatalogHashesV2 {
  const GameplayCatalogHashesV2({
    required this.mapCatalogHash,
    required this.modeCatalogHash,
  });

  final String mapCatalogHash;
  final String modeCatalogHash;
}

/// Typed route/session input. The controller resolves [mapId] through the bundled
/// catalog; a null map ID means the deterministic selector chooses an eligible
/// map from [seed] for Time Attack/Ranked.
class GameSessionConfig {
  const GameSessionConfig({
    required this.protocol,
    required this.mode,
    required this.seed,
    this.mapId,
    this.durationMs,
    this.competitiveRun,
  });

  final GameplayProtocolRef protocol;
  final V2GameMode mode;
  final String seed;
  final String? mapId;
  final int? durationMs;
  final CompetitiveRunEnvelope? competitiveRun;

  bool get isCompetitive => competitiveRun != null;
}
