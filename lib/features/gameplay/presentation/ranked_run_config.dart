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
  });

  final String runId;
  final String seed;
  final String rulesetVersion;
  final String generatorVersion;
  final String challengeToken;
  final int runDurationMs;
  final String mode;

  bool get isDaily => mode == 'daily';
}
