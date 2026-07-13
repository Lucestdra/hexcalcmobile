/// The server-issued context a run is played and submitted against. Passed from
/// the ranked / daily entry screen into gameplay as a route `extra`. Ranked and
/// daily share this one signed-challenge pipeline; [mode] (`ranked` | `daily`)
/// only tags the local record and the verification screen — the submit itself is
/// identical (the server already knows the run's mode from issuance).
class RankedRunConfig {
  const RankedRunConfig({
    required this.runId,
    required this.seed,
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.challengeToken,
    required this.runDurationMs,
    this.mode = 'ranked',
    this.protocolVersion = 'equation-v1',
    this.payloadVersion = 1,
    this.mapCatalogVersion,
    this.mapId,
    this.modeCatalogVersion,
    this.modeId,
  });

  final String runId;
  final String seed;
  final String rulesetVersion;
  final String generatorVersion;
  final String challengeToken;
  final int runDurationMs;
  final String mode;
  final String protocolVersion;
  final int payloadVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final String? modeCatalogVersion;
  final String? modeId;

  bool get isDaily => mode == 'daily';
  bool get isTargetSwipeV2 => protocolVersion == 'target-swipe-v2';
}
