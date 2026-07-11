import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/settings/app_settings.dart';
import 'package:hexcalc/core/settings/settings_controller.dart';
import 'package:hexcalc/core/settings/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<ProviderContainer> container() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final SettingsRepository repo = SettingsRepository(prefs);
    final ProviderContainer c = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('initial state is the persisted (default) settings', () async {
    final ProviderContainer c = await container();
    expect(c.read(settingsProvider), AppSettings.defaults);
  });

  test('updates change state and persist through the repository', () async {
    final ProviderContainer c = await container();
    c.read(settingsProvider.notifier).setReducedMotion(true);
    c.read(settingsProvider.notifier).setSfxVolume(0.3);

    expect(c.read(settingsProvider).reducedMotion, isTrue);
    expect(c.read(settingsProvider).sfxVolume, 0.3);

    // Let the fire-and-forget saves flush, then confirm they persisted.
    await Future<void>.delayed(Duration.zero);
    final AppSettings reloaded = c.read(settingsRepositoryProvider).load();
    expect(reloaded.reducedMotion, isTrue);
    expect(reloaded.sfxVolume, 0.3);
  });
}
