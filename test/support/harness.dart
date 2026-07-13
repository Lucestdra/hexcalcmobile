import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hexcalc/app/flavors/flavor_config.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_event.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/audio/audio_service.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/crash/crash_reporter.dart';
import 'package:hexcalc/core/haptics/haptics_service.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/core/settings/app_settings.dart';
import 'package:hexcalc/core/settings/settings_controller.dart';
import 'package:hexcalc/core/settings/settings_repository.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/map_progress_repository.dart';
import 'package:hexcalc/features/gameplay/persistence/run_history_repository.dart';
import 'package:hexcalc/features/onboarding/application/onboarding_controller.dart';
import 'package:hexcalc/features/onboarding/data/onboarding_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fake_http_adapter.dart';

/// Loads rs-v1 from the synced fixtures for tests.
Ruleset loadTestRuleset() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

RulesetV2 loadTestRulesetV2() => RulesetV2.fromJson(
  jsonDecode(File('assets/gameplay/rs-v2.json').readAsStringSync())
      as Map<String, dynamic>,
);

MapCatalogV1 loadTestMapCatalogV1() => MapCatalogV1.fromJson(
  jsonDecode(File('assets/gameplay/maps-v1.json').readAsStringSync())
      as Map<String, dynamic>,
);

ModeCatalogV1 loadTestModeCatalogV1() => ModeCatalogV1.fromJson(
  jsonDecode(File('assets/gameplay/modes-v1.json').readAsStringSync())
      as Map<String, dynamic>,
);

GameplayCatalogHashesV2 loadTestGameplayCatalogHashesV2() {
  final String maps = File('assets/gameplay/maps-v1.json').readAsStringSync();
  final String modes = File('assets/gameplay/modes-v1.json').readAsStringSync();
  return GameplayCatalogHashesV2(
    mapCatalogHash: sha256.convert(utf8.encode(maps)).toString(),
    modeCatalogHash: sha256.convert(utf8.encode(modes)).toString(),
  );
}

/// Wraps [child] in a [ProviderScope] with the full bootstrap-provider graph
/// stubbed with test-safe implementations (no audio device, in-memory DB, no-op
/// analytics/haptics). Async because SharedPreferences needs a mock. The override
/// list is inferred (Riverpod's Override type is not writable as an annotation).
Future<Widget> testScope({
  required Widget child,
  Ruleset? ruleset,
  RulesetV2? rulesetV2,
  MapCatalogV1? mapCatalogV1,
  ModeCatalogV1? modeCatalogV1,
  AnalyticsService? analytics,
  AppSettings? settings,
  AppDatabase? db,
  // When set, the home-screen stream providers are backed by finite streams
  // instead of the live Drift query. Use this whenever a test mounts the home
  // screen but does not need real persistence — it avoids the drift stream-close
  // timer that flutter_test flags at teardown.
  RunStats? homeStats,
  List<RunSummary>? homeRecent,
  Map<String, MapProgress>? mapProgress,
  // When set, overrides the onboarding store (e.g. InMemoryOnboardingStore(seen: false)
  // to surface the first-launch overlay). Unset → the default "already seen" store.
  OnboardingStore? onboardingStore,
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
      rulesetV2Provider.overrideWithValue(rulesetV2 ?? loadTestRulesetV2()),
      mapCatalogV1Provider.overrideWithValue(
        mapCatalogV1 ?? loadTestMapCatalogV1(),
      ),
      modeCatalogV1Provider.overrideWithValue(
        modeCatalogV1 ?? loadTestModeCatalogV1(),
      ),
      gameplayCatalogHashesV2Provider.overrideWithValue(
        loadTestGameplayCatalogHashesV2(),
      ),
      settingsRepositoryProvider.overrideWithValue(repo),
      analyticsProvider.overrideWithValue(analytics ?? const NoopAnalytics()),
      crashReporterProvider.overrideWithValue(const NoopCrashReporter()),
      audioServiceProvider.overrideWithValue(const NoopAudioService()),
      appDatabaseProvider.overrideWithValue(
        db ?? AppDatabase(NativeDatabase.memory()),
      ),
      hapticsServiceProvider.overrideWithValue(HapticsService(enabled: false)),
      // Auth/networking: boot with an in-memory token store and a fake HTTP client
      // (guest bootstrap succeeds instantly), so the non-blocking bootstrap runs
      // but no real network or secure-storage platform channel is touched.
      apiBaseUrlProvider.overrideWithValue('http://test.local'),
      tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
      apiClientProvider.overrideWith(
        (ref) => ApiClient(
          baseUrl: ref.read(apiBaseUrlProvider),
          tokenStore: ref.read(tokenStoreProvider),
          dioBuilder: fakeDioBuilder(_bootstrapFake()),
        ),
      ),
      // App-level tests don't exercise the auth lifecycle (it is unit-tested):
      // stub the session as a ready guest so app boot runs no async network work.
      authSessionProvider.overrideWith(_StubAuthSession.new),
      if (homeStats != null)
        runStatsProvider.overrideWith(
          (ref) => Stream<RunStats>.value(homeStats),
        ),
      if (homeRecent != null)
        recentRunsProvider.overrideWith(
          (ref) => Stream<List<RunSummary>>.value(homeRecent),
        ),
      if (mapProgress != null)
        mapProgressProvider.overrideWith(
          (ref, String catalogVersion) =>
              Stream<Map<String, MapProgress>>.value(mapProgress),
        ),
      if (onboardingStore != null)
        onboardingStoreProvider.overrideWithValue(onboardingStore),
    ],
    child: child,
  );
}

/// A session that is already a ready guest and does no async work — keeps
/// app-level widget tests free of the real bootstrap's network lifecycle.
class _StubAuthSession extends AuthSessionNotifier {
  @override
  AuthState build() =>
      const AuthState(kind: AuthKind.guest, userId: 'guest-test');
}

/// A fake HTTP client whose only route is a successful guest sign-in, so the app's
/// non-blocking bootstrap resolves immediately in widget tests.
FakeHttpAdapter _bootstrapFake() {
  final FakeHttpAdapter fake = FakeHttpAdapter();
  fake.on(
    'POST',
    '/api/v1/auth/guest',
    (_) => FakeResponse.json(200, <String, dynamic>{
      'accessToken': 'guest.access',
      'refreshToken': 'guest.refresh',
      'tokenType': 'Bearer',
      'expiresInSeconds': 900,
      'userId': 'guest-test',
    }),
  );
  return fake;
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
