import '../../../core/settings/app_settings.dart';

/// The subset of [AppSettings] the Flame surface needs, resolved once and pushed
/// into the board game. Keeps the game decoupled from Riverpod/settings types.
class GameFeel {
  const GameFeel({
    this.reducedMotion = false,
    this.particleIntensity = 1.0,
    this.neonIntensity = 1.0,
  });

  final bool reducedMotion;
  final double particleIntensity;
  final double neonIntensity;

  factory GameFeel.fromSettings(AppSettings s) => GameFeel(
    reducedMotion: s.reducedMotion,
    particleIntensity: s.particleIntensity,
    neonIntensity: s.neonIntensity,
  );

  static const GameFeel standard = GameFeel();
}
