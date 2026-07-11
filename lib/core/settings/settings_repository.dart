import 'package:shared_preferences/shared_preferences.dart';

import 'app_settings.dart';

/// Persists [AppSettings] in [SharedPreferences]. Non-sensitive preference data
/// only — never tokens or PII (those belong in secure storage).
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const String _kMusic = 'settings.musicVolume';
  static const String _kSfx = 'settings.sfxVolume';
  static const String _kHaptics = 'settings.hapticsEnabled';
  static const String _kReducedMotion = 'settings.reducedMotion';
  static const String _kNeon = 'settings.neonIntensity';
  static const String _kParticles = 'settings.particleIntensity';

  AppSettings load() {
    const AppSettings d = AppSettings.defaults;
    return AppSettings(
      musicVolume: _clamp01(_prefs.getDouble(_kMusic) ?? d.musicVolume),
      sfxVolume: _clamp01(_prefs.getDouble(_kSfx) ?? d.sfxVolume),
      hapticsEnabled: _prefs.getBool(_kHaptics) ?? d.hapticsEnabled,
      reducedMotion: _prefs.getBool(_kReducedMotion) ?? d.reducedMotion,
      neonIntensity: _clamp01(_prefs.getDouble(_kNeon) ?? d.neonIntensity),
      particleIntensity: _clamp01(
        _prefs.getDouble(_kParticles) ?? d.particleIntensity,
      ),
    );
  }

  Future<void> save(AppSettings s) async {
    await _prefs.setDouble(_kMusic, s.musicVolume);
    await _prefs.setDouble(_kSfx, s.sfxVolume);
    await _prefs.setBool(_kHaptics, s.hapticsEnabled);
    await _prefs.setBool(_kReducedMotion, s.reducedMotion);
    await _prefs.setDouble(_kNeon, s.neonIntensity);
    await _prefs.setDouble(_kParticles, s.particleIntensity);
  }

  static double _clamp01(double v) => v.clamp(0.0, 1.0);
}
