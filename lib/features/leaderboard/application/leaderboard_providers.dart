import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/api/dtos.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/errors/app_error.dart';
import '../../gameplay/persistence/sync_store.dart';
import '../data/leaderboard_cache_store.dart';
import 'leaderboard_repository.dart';

/// Drift-backed cache gateway for the weekly reads.
final leaderboardCacheStoreProvider = Provider<LeaderboardCacheStore>((ref) {
  return LeaderboardCacheStore(ref.watch(appDatabaseProvider));
});

/// The offline-tolerant weekly leaderboard repository.
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(
    api: ref.watch(hexcalcApiProvider),
    cache: ref.watch(leaderboardCacheStoreProvider),
  );
});

/// The weekly leaderboard for the screen. Auto-disposed so re-entering the screen
/// re-fetches; retry is `ref.invalidate(weeklyLeaderboardProvider)`. A thrown
/// [NetworkError] (offline, no cache) surfaces as the offline state; any other
/// [AppError] surfaces as a recoverable error. The active user id is watched and
/// passed through so the cache is scoped per account (an identity change re-runs
/// this and never serves the previous user's cached standings).
final weeklyLeaderboardProvider = FutureProvider.autoDispose<LeaderboardData>((
  ref,
) {
  final String userId =
      ref.watch(authSessionProvider.select((AuthState s) => s.userId)) ??
      'anon';
  return ref.watch(leaderboardRepositoryProvider).load(userId);
});

/// Count of the player's ranked runs still awaiting a verdict, so the board can
/// mark "not yet counted" runs distinctly (an unverified run is never shown as a
/// confirmed rank).
final pendingRankedCountProvider = StreamProvider.autoDispose<int>((ref) {
  return ref
      .watch(syncStoreProvider)
      .watchRecentRankedRuns()
      .map(
        (List<RankedRunView> runs) =>
            runs.where((RankedRunView r) => r.status == kRankedPending).length,
      );
});

/// A best-effort weekly-rank teaser for the home screen. Returns null on any
/// failure (offline, error, or no verified run yet) so it never blocks or errors
/// the home screen — the teaser is decorative, not load-bearing.
final weeklyRankTeaserProvider = FutureProvider.autoDispose<int?>((ref) async {
  final (AuthKind kind, String? _) = ref.watch(
    authSessionProvider.select((AuthState s) => (s.kind, s.userId)),
  );
  if (kind == AuthKind.none) {
    return null;
  }
  try {
    final MyWeeklyRankResponse me = await ref
        .watch(hexcalcApiProvider)
        .getMyWeeklyRank();
    return me.rank;
  } on AppError {
    return null;
  }
});
