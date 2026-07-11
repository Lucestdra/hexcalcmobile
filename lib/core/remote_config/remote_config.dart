/// The remote-config seam. Real providers (Firebase Remote Config) are wired
/// later; for now [DefaultRemoteConfig] returns compiled-in defaults so feature
/// code can already read flags/values through a stable typed surface.
///
/// Defaults are intentionally conservative — an unreachable remote source must
/// never unlock risky behaviour.
abstract interface class RemoteConfig {
  bool getBool(RemoteFlag flag);
  int getInt(RemoteFlag flag);
  double getDouble(RemoteFlag flag);
  Future<void> refresh();
}

/// The closed set of remote-config keys, each with a typed default.
enum RemoteFlag {
  dailyChallengeEnabled(boolDefault: false),
  leaderboardEnabled(boolDefault: false),
  maxParticleCount(intDefault: 120),
  scoreTravelSeconds(doubleDefault: 0.6);

  const RemoteFlag({
    this.boolDefault = false,
    this.intDefault = 0,
    this.doubleDefault = 0,
  });

  final bool boolDefault;
  final int intDefault;
  final double doubleDefault;
}

class DefaultRemoteConfig implements RemoteConfig {
  const DefaultRemoteConfig();

  @override
  bool getBool(RemoteFlag flag) => flag.boolDefault;

  @override
  int getInt(RemoteFlag flag) => flag.intDefault;

  @override
  double getDouble(RemoteFlag flag) => flag.doubleDefault;

  @override
  Future<void> refresh() async {}
}
