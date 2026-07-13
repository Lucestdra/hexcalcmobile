import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics_event.dart';
import '../core/analytics/analytics_service.dart';
import '../core/audio/flame_audio_service.dart';
import '../core/auth/auth_session.dart';
import '../core/auth/token_store.dart';
import '../core/crash/crash_reporter.dart';
import '../core/networking/connectivity_monitor.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../core/settings/settings_repository.dart';
import '../features/gameplay/application/game_session_config.dart';
import '../features/gameplay/domain/domain.dart';
import '../features/gameplay/persistence/database_connection.dart';
import '../features/onboarding/application/onboarding_controller.dart';
import '../features/onboarding/data/onboarding_store.dart';
import 'app.dart';
import 'flavors/flavor_config.dart';
import 'providers.dart';

/// Single shared bootstrap for every flavor. Assembles the typed configuration,
/// resolves platform singletons (prefs, database, ruleset asset), chooses the
/// analytics/crash implementations for the flavor, and starts the app inside a
/// guarded zone so uncaught async errors reach the crash reporter.
Future<void> bootstrap(FlavorConfig config) async {
  final CrashReporter crash = config.useDebugAnalytics
      ? const DebugCrashReporter()
      : const NoopCrashReporter();

  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
        DeviceOrientation.portraitUp,
      ]);

      // Route framework errors into the crash reporter (still shown in debug).
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        unawaited(crash.recordError(details.exception, details.stack));
      };

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final SettingsRepository settingsRepo = SettingsRepository(prefs);
      final AppSettings settings = settingsRepo.load();

      final String rulesetJson = await rootBundle.loadString(
        'assets/gameplay/rs-v1.json',
      );
      final Ruleset ruleset = Ruleset.fromJson(
        jsonDecode(rulesetJson) as Map<String, dynamic>,
      );
      final String rulesetV2Json = await rootBundle.loadString(
        'assets/gameplay/rs-v2.json',
      );
      final RulesetV2 rulesetV2 = RulesetV2.fromJson(
        jsonDecode(rulesetV2Json) as Map<String, dynamic>,
      );
      final String mapCatalogJson = await rootBundle.loadString(
        'assets/gameplay/maps-v1.json',
      );
      final MapCatalogV1 mapCatalog = MapCatalogV1.fromJson(
        jsonDecode(mapCatalogJson) as Map<String, dynamic>,
      );
      final String modeCatalogJson = await rootBundle.loadString(
        'assets/gameplay/modes-v1.json',
      );
      final ModeCatalogV1 modeCatalog = ModeCatalogV1.fromJson(
        jsonDecode(modeCatalogJson) as Map<String, dynamic>,
      );
      final GameplayCatalogHashesV2 catalogHashes = GameplayCatalogHashesV2(
        mapCatalogHash: sha256.convert(utf8.encode(mapCatalogJson)).toString(),
        modeCatalogHash: sha256
            .convert(utf8.encode(modeCatalogJson))
            .toString(),
      );

      final FlameAudioService audio = FlameAudioService()
        ..applySettings(settings);
      unawaited(audio.preload());

      final AnalyticsService analytics = config.useDebugAnalytics
          ? const DebugAnalytics()
          : const NoopAnalytics();

      analytics.logEvent(AnalyticsEvent.appOpened());

      runApp(
        ProviderScope(
          overrides: [
            flavorProvider.overrideWithValue(config),
            rulesetProvider.overrideWithValue(ruleset),
            rulesetV2Provider.overrideWithValue(rulesetV2),
            mapCatalogV1Provider.overrideWithValue(mapCatalog),
            modeCatalogV1Provider.overrideWithValue(modeCatalog),
            gameplayCatalogHashesV2Provider.overrideWithValue(catalogHashes),
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            onboardingStoreProvider.overrideWithValue(
              PrefsOnboardingStore(prefs),
            ),
            analyticsProvider.overrideWithValue(analytics),
            crashReporterProvider.overrideWithValue(crash),
            audioServiceProvider.overrideWithValue(audio),
            appDatabaseProvider.overrideWithValue(openAppDatabase()),
            // Networking + auth (Phase 7): base URL from the flavor, tokens in
            // secure storage, real connectivity signal for the guest retry.
            apiBaseUrlProvider.overrideWithValue(config.apiBaseUrl),
            tokenStoreProvider.overrideWithValue(SecureTokenStore()),
            connectivityMonitorProvider.overrideWithValue(
              ConnectivityPlusMonitor(),
            ),
          ],
          child: const HexCalcApp(),
        ),
      );
    },
    (Object error, StackTrace stack) {
      unawaited(crash.recordError(error, stack, fatal: true));
    },
  );
}
