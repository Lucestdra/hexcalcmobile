import 'dart:convert';

import '../../gameplay/persistence/app_database.dart';

/// Logical cache keys for the two weekly reads (scoped per user, see [_key]).
const String kLeaderboardTopKey = 'weekly_top';
const String kLeaderboardMeKey = 'weekly_me';

/// A cached response body plus when it was fetched (freshness stamp).
class CachedLeaderboard {
  const CachedLeaderboard(this.json, this.fetchedAtMs);

  final Map<String, dynamic> json;
  final int fetchedAtMs;
}

/// The only gateway between the leaderboard repository and the [LeaderboardCache]
/// Drift table — no Drift types leak past here (per the working agreement). Stores
/// the last successful weekly reads so the screen can show saved standings offline.
///
/// Rows are scoped by [userId] so one account's cached standings (its rank, its
/// "YOU"-tagged row) can never be served to a different account that later uses
/// the same device — a fresh identity simply misses the cache and shows the
/// honest offline/live state instead.
class LeaderboardCacheStore {
  LeaderboardCacheStore(this._db);

  final AppDatabase _db;

  static String _key(String userId, String logicalKey) => '$logicalKey:$userId';

  Future<void> write(
    String userId,
    String logicalKey,
    Map<String, dynamic> json,
    int fetchedAtMs,
  ) {
    return _db.upsertLeaderboardCache(
      LeaderboardCacheCompanion.insert(
        cacheKey: _key(userId, logicalKey),
        payload: jsonEncode(json),
        fetchedAtMs: fetchedAtMs,
      ),
    );
  }

  /// Reads a cached value for [userId], or null on a miss or corrupt payload
  /// (treated as a miss so the caller falls back to live/offline rather than
  /// crashing).
  Future<CachedLeaderboard?> read(String userId, String logicalKey) async {
    final LeaderboardCacheRow? row = await _db.leaderboardCacheEntry(
      _key(userId, logicalKey),
    );
    if (row == null) {
      return null;
    }
    try {
      final Object? decoded = jsonDecode(row.payload);
      if (decoded is Map<String, dynamic>) {
        return CachedLeaderboard(decoded, row.fetchedAtMs);
      }
      return null;
    } on FormatException {
      return null;
    }
  }
}
