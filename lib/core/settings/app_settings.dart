/// Immutable player settings covering audio, haptics, and accessibility.
///
/// Every effect in the game reads from this single source of truth — there is no
/// second place where "reduced motion" or "SFX volume" is decided.
class AppSettings {
  const AppSettings({
    this.musicVolume = 0.6,
    this.sfxVolume = 0.8,
    this.hapticsEnabled = true,
    this.reducedMotion = false,
    this.neonIntensity = 1.0,
    this.particleIntensity = 1.0,
  });

  /// Background music level, 0..1.
  final double musicVolume;

  /// Sound-effects level, 0..1 (kept separate from music per the a11y checklist).
  final double sfxVolume;

  /// When false, no haptic feedback is produced anywhere.
  final bool hapticsEnabled;

  /// When true: no shake, minimal/zero particles, fades instead of travel.
  final bool reducedMotion;

  /// Glow/brightness of neon accents, 0..1 (1 = full intensity).
  final double neonIntensity;

  /// Particle density multiplier, 0..1 (0 = none, 1 = full caps).
  final double particleIntensity;

  static const AppSettings defaults = AppSettings();

  AppSettings copyWith({
    double? musicVolume,
    double? sfxVolume,
    bool? hapticsEnabled,
    bool? reducedMotion,
    double? neonIntensity,
    double? particleIntensity,
  }) {
    return AppSettings(
      musicVolume: musicVolume ?? this.musicVolume,
      sfxVolume: sfxVolume ?? this.sfxVolume,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      neonIntensity: neonIntensity ?? this.neonIntensity,
      particleIntensity: particleIntensity ?? this.particleIntensity,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.musicVolume == musicVolume &&
      other.sfxVolume == sfxVolume &&
      other.hapticsEnabled == hapticsEnabled &&
      other.reducedMotion == reducedMotion &&
      other.neonIntensity == neonIntensity &&
      other.particleIntensity == particleIntensity;

  @override
  int get hashCode => Object.hash(
    musicVolume,
    sfxVolume,
    hapticsEnabled,
    reducedMotion,
    neonIntensity,
    particleIntensity,
  );
}
