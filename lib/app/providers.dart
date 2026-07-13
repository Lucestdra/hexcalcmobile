import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/analytics/analytics_service.dart';
import '../core/audio/audio_service.dart';
import '../core/auth/auth_session.dart';
import '../core/crash/crash_reporter.dart';
import '../core/haptics/haptics_service.dart';
import '../core/push/push_service.dart';
import '../core/remote_config/remote_config.dart';
import '../core/sync/outbox_sync_engine.dart';
import '../features/gameplay/domain/domain.dart';
import '../features/gameplay/persistence/app_database.dart';
import '../features/gameplay/persistence/run_history_repository.dart';
import '../features/gameplay/persistence/sync_store.dart';
import 'flavors/flavor_config.dart';

/// The active build flavor. Overridden at bootstrap by each flavor entrypoint.
final flavorProvider = Provider<FlavorConfig>((ref) {
  throw UnimplementedError('flavorProvider must be overridden at bootstrap');
});

/// The active gameplay ruleset, loaded from the bundled canonical JSON at
/// bootstrap and injected here. Overridden in bootstrap.
final rulesetProvider = Provider<Ruleset>((ref) {
  throw UnimplementedError('rulesetProvider must be overridden at bootstrap');
});

/// Analytics/crash seams — overridden at bootstrap with debug or no-op impls
/// depending on the flavor. Real SDKs are wired in a later phase.
final analyticsProvider = Provider<AnalyticsService>((ref) {
  throw UnimplementedError('analyticsProvider must be overridden at bootstrap');
});

final crashReporterProvider = Provider<CrashReporter>((ref) {
  throw UnimplementedError(
    'crashReporterProvider must be overridden at bootstrap',
  );
});

/// Audio — overridden with a flame_audio impl in the app, a no-op in tests.
final audioServiceProvider = Provider<AudioService>((ref) {
  throw UnimplementedError(
    'audioServiceProvider must be overridden at bootstrap',
  );
});

/// The on-device database — overridden at bootstrap with the opened instance.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden at bootstrap',
  );
});

/// Run-history gateway, built on the injected [appDatabaseProvider].
final runHistoryRepositoryProvider = Provider<RunHistoryRepository>((ref) {
  return RunHistoryRepository(ref.watch(appDatabaseProvider));
});

/// Live personal best / totals for the home screen.
final runStatsProvider = StreamProvider<RunStats>((ref) {
  return ref.watch(runHistoryRepositoryProvider).watchStats();
});

/// The most recent runs for the home screen history list.
final recentRunsProvider = StreamProvider<List<RunSummary>>((ref) {
  return ref.watch(runHistoryRepositoryProvider).watchRecentRuns(limit: 5);
});

/// Haptics — a single stable instance; its `enabled` flag is synced from
/// settings by the gameplay session.
final hapticsServiceProvider = Provider<HapticsService>((ref) {
  return HapticsService();
});

/// Seams that need no per-flavor wiring in the MVP: safe compiled defaults.
final remoteConfigProvider = Provider<RemoteConfig>((ref) {
  return const DefaultRemoteConfig();
});

final pushServiceProvider = Provider<PushService>((ref) {
  return const NoopPushService();
});

/// The offline outbox + ranked-run gateway, built on the injected database.
final syncStoreProvider = Provider<SyncStore>((ref) {
  return SyncStore(ref.watch(appDatabaseProvider));
});

/// The outbox drain engine (pure logic; the periodic timer + connectivity
/// subscription live in the sync controller). Depends on the authenticated API.
final outboxSyncEngineProvider = Provider<OutboxSyncEngine>((ref) {
  return OutboxSyncEngine(
    store: ref.watch(syncStoreProvider),
    api: ref.watch(hexcalcApiProvider),
    connectivity: ref.watch(connectivityMonitorProvider),
  );
});

/// Watches a ranked run's verification status for the ranked-result screen.
final rankedRunViewProvider = StreamProvider.family<RankedRunView?, String>((
  ref,
  String runId,
) {
  return ref.watch(syncStoreProvider).watchRankedRun(runId);
});
