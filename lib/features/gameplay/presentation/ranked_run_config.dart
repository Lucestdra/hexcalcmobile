/// The server-issued context a ranked run is played and submitted against. Passed
/// from the ranked entry screen into gameplay as a route `extra`.
class RankedRunConfig {
  const RankedRunConfig({
    required this.runId,
    required this.seed,
    required this.rulesetVersion,
    required this.generatorVersion,
    required this.challengeToken,
    required this.runDurationMs,
  });

  final String runId;
  final String seed;
  final String rulesetVersion;
  final String generatorVersion;
  final String challengeToken;
  final int runDurationMs;
}
