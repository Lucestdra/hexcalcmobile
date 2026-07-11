import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/analytics/analytics_event.dart';
import '../core/analytics/analytics_service.dart';
import '../core/audio/flame_audio_service.dart';
import '../core/crash/crash_reporter.dart';
import '../core/settings/app_settings.dart';
import '../core/settings/settings_controller.dart';
import '../core/settings/settings_repository.dart';
import '../features/gameplay/domain/domain.dart';
import '../features/gameplay/persistence/database_connection.dart';
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
            settingsRepositoryProvider.overrideWithValue(settingsRepo),
            analyticsProvider.overrideWithValue(analytics),
            crashReporterProvider.overrideWithValue(crash),
            audioServiceProvider.overrideWithValue(audio),
            appDatabaseProvider.overrideWithValue(openAppDatabase()),
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
