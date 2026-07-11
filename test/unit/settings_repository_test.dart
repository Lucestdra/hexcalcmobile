import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/settings/app_settings.dart';
import 'package:hexcalc/core/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<SettingsRepository> freshRepo([
    Map<String, Object> seed = const {},
  ]) async {
    SharedPreferences.setMockInitialValues(seed);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return SettingsRepository(prefs);
  }

  test('load returns defaults when nothing is stored', () async {
    final SettingsRepository repo = await freshRepo();
    expect(repo.load(), AppSettings.defaults);
  });

  test('save then load round-trips every field', () async {
    final SettingsRepository repo = await freshRepo();
    const AppSettings custom = AppSettings(
      musicVolume: 0.25,
      sfxVolume: 0.1,
      hapticsEnabled: false,
      reducedMotion: true,
      neonIntensity: 0.5,
      particleIntensity: 0.0,
    );
    await repo.save(custom);
    expect(repo.load(), custom);
  });

  test('out-of-range stored volumes are clamped on load', () async {
    final SettingsRepository repo = await freshRepo(<String, Object>{
      'settings.musicVolume': 5.0,
      'settings.neonIntensity': -2.0,
    });
    final AppSettings loaded = repo.load();
    expect(loaded.musicVolume, 1.0);
    expect(loaded.neonIntensity, 0.0);
  });
}
