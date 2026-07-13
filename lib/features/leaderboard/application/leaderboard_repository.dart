import '../../../core/api/dtos.dart';
import '../../../core/api/hexcalc_api.dart';
import '../../../core/errors/app_error.dart';
import '../data/leaderboard_cache_store.dart';

/// Where a loaded leaderboard came from — drives the freshness banner.
enum LeaderboardSource { live, cached }

/// The weekly leaderboard the screen renders: the top page and the player's own
/// ±5 window, with provenance. When [source] is [LeaderboardSource.cached] the
/// data was served from the Drift cache after a failed live fetch, and
/// [cachedAtMs] says when it was last fetched.
class LeaderboardData {
  const LeaderboardData({
    required this.top,
    required this.me,
    required this.source,
    this.cachedAtMs,
  });

  final WeeklyLeaderboardResponse top;
  final MyWeeklyRankResponse me;
  final LeaderboardSource source;
  final int? cachedAtMs;

  bool get isFromCache => source == LeaderboardSource.cached;

  /// True when nobody has a verified standing yet (drives the empty state).
  bool get isEmpty => top.entries.isEmpty && me.rank == null;
}

/// Loads the weekly leaderboard with an offline-tolerant, cache-backed strategy:
/// fetch live and refresh the cache on success; on a connectivity failure fall
/// back to the last cached copy (shown with a freshness stamp), and only report
/// "offline" when there is nothing cached. Non-connectivity errors (5xx, 401, …)
/// propagate so the screen can show a recoverable error rather than silently
/// masking a real failure behind stale data.
class LeaderboardRepository {
  LeaderboardRepository({
    required HexcalcApi api,
    required LeaderboardCacheStore cache,
    int Function()? nowMs,
  }) : _api = api,
       _cache = cache,
       _nowMs = nowMs ?? _systemNowMs;

  final HexcalcApi _api;
  final LeaderboardCacheStore _cache;
  final int Function() _nowMs;

  /// The top page is requested at the full top-100 size the board displays.
  static const int topPageSize = 100;

  static int _systemNowMs() => DateTime.now().millisecondsSinceEpoch;

  /// Loads the board for [userId] (the active session's user, used to scope the
  /// cache). Returns live data (and refreshes the cache) on success; returns
  /// cached data on a connectivity failure when a cache exists; throws
  /// [NetworkError] when offline with no cache, and rethrows any other [AppError].
  Future<LeaderboardData> load(String userId) async {
    try {
      // Sequential (not parallel) so a typed [AppError] propagates cleanly rather
      // than being wrapped in a ParallelWaitError.
      final WeeklyLeaderboardResponse top = await _api.getWeeklyLeaderboard(
        limit: topPageSize,
      );
      final MyWeeklyRankResponse me = await _api.getMyWeeklyRank();

      final int now = _nowMs();
      await _cache.write(userId, kLeaderboardTopKey, top.toJson(), now);
      await _cache.write(userId, kLeaderboardMeKey, me.toJson(), now);

      return LeaderboardData(top: top, me: me, source: LeaderboardSource.live);
    } on NetworkError {
      final LeaderboardData? cached = await _readCache(userId);
      if (cached != null) {
        return cached;
      }
      rethrow; // offline with no cache → the screen shows the offline state
    }
  }

  Future<LeaderboardData?> _readCache(String userId) async {
    final CachedLeaderboard? top = await _cache.read(
      userId,
      kLeaderboardTopKey,
    );
    final CachedLeaderboard? me = await _cache.read(userId, kLeaderboardMeKey);
    if (top == null || me == null) {
      return null;
    }
    try {
      return LeaderboardData(
        top: WeeklyLeaderboardResponse.fromJson(top.json),
        me: MyWeeklyRankResponse.fromJson(me.json),
        source: LeaderboardSource.cached,
        // The older of the two stamps is the honest "as of" for the pair.
        cachedAtMs: top.fetchedAtMs < me.fetchedAtMs
            ? top.fetchedAtMs
            : me.fetchedAtMs,
      );
    } catch (_) {
      // A structurally-corrupt payload (e.g. a shape change across an app
      // upgrade) throws a TypeError inside fromJson — not a FormatException, so
      // the cache store's decode guard doesn't catch it. Treat it as a miss so
      // the caller shows the honest offline state rather than a spurious error.
      return null;
    }
  }
}
