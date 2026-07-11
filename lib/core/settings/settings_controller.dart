import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_settings.dart';
import 'settings_repository.dart';

/// Holds the live [AppSettings] and writes every change through to the
/// repository. Immutable state; no `BuildContext`.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(settingsRepositoryProvider).load();

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  void _update(AppSettings next) {
    if (next == state) {
      return;
    }
    state = next;
    // Fire-and-forget persistence: the in-memory state is already authoritative.
    unawaited(_repo.save(next));
  }

  void setMusicVolume(double v) =>
      _update(state.copyWith(musicVolume: _clamp01(v)));
  void setSfxVolume(double v) =>
      _update(state.copyWith(sfxVolume: _clamp01(v)));
  void setHapticsEnabled(bool v) => _update(state.copyWith(hapticsEnabled: v));
  void setReducedMotion(bool v) => _update(state.copyWith(reducedMotion: v));
  void setNeonIntensity(double v) =>
      _update(state.copyWith(neonIntensity: _clamp01(v)));
  void setParticleIntensity(double v) =>
      _update(state.copyWith(particleIntensity: _clamp01(v)));

  static double _clamp01(double v) => v.clamp(0.0, 1.0);
}

/// Overridden at bootstrap with a concrete [SettingsRepository] backed by a
/// resolved [SharedPreferences] instance.
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  throw UnimplementedError(
    'settingsRepositoryProvider must be overridden at bootstrap',
  );
});

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);
