import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcalc/app/flavors/flavor_config.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_event.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/audio/audio_service.dart';
import 'package:hexcalc/core/crash/crash_reporter.dart';
import 'package:hexcalc/core/haptics/haptics_service.dart';
import 'package:hexcalc/core/settings/app_settings.dart';
import 'package:hexcalc/core/settings/settings_controller.dart';
import 'package:hexcalc/core/settings/settings_repository.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/run_history_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Loads rs-v1 from the synced fixtures for tests.
Ruleset loadTestRuleset() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

/// Wraps [child] in a [ProviderScope] with the full bootstrap-provider graph
/// stubbed with test-safe implementations (no audio device, in-memory DB, no-op
/// analytics/haptics). Async because SharedPreferences needs a mock. The override
/// list is inferred (Riverpod's Override type is not writable as an annotation).
Future<Widget> testScope({
  required Widget child,
  Ruleset? ruleset,
  AnalyticsService? analytics,
  AppSettings? settings,
  AppDatabase? db,
  // When set, the home-screen stream providers are backed by finite streams
  // instead of the live Drift query. Use this whenever a test mounts the home
  // screen but does not need real persistence — it avoids the drift stream-close
  // timer that flutter_test flags at teardown.
  RunStats? homeStats,
  List<RunSummary>? homeRecent,
}) async {
  // Tests create several in-memory databases; each uses its own executor so the
  // multiple-instance warning is a false positive here.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final SettingsRepository repo = SettingsRepository(prefs);
  if (settings != null) {
    await repo.save(settings);
  }

  return ProviderScope(
    overrides: [
      flavorProvider.overrideWithValue(FlavorConfig.development),
      rulesetProvider.overrideWithValue(ruleset ?? loadTestRuleset()),
      settingsRepositoryProvider.overrideWithValue(repo),
      analyticsProvider.overrideWithValue(analytics ?? const NoopAnalytics()),
      crashReporterProvider.overrideWithValue(const NoopCrashReporter()),
      audioServiceProvider.overrideWithValue(const NoopAudioService()),
      appDatabaseProvider.overrideWithValue(
        db ?? AppDatabase(NativeDatabase.memory()),
      ),
      hapticsServiceProvider.overrideWithValue(HapticsService(enabled: false)),
      if (homeStats != null)
        runStatsProvider.overrideWith(
          (ref) => Stream<RunStats>.value(homeStats),
        ),
      if (homeRecent != null)
        recentRunsProvider.overrideWith(
          (ref) => Stream<List<RunSummary>>.value(homeRecent),
        ),
    ],
    child: child,
  );
}

/// An [AnalyticsService] that records every event, for assertions in tests.
class RecordingAnalytics implements AnalyticsService {
  final List<AnalyticsEventRecord> events = <AnalyticsEventRecord>[];

  @override
  void logEvent(AnalyticsEvent event) {
    events.add(AnalyticsEventRecord(event.name, event.parameters));
  }

  @override
  Future<void> setUserProperty(String key, String value) async {}

  bool contains(String name) => events.any((e) => e.name == name);
}

class AnalyticsEventRecord {
  const AnalyticsEventRecord(this.name, this.parameters);
  final String name;
  final Map<String, Object> parameters;
}
