import 'package:drift/drift.dart' show Value;

import 'app_database.dart';

/// UI/domain-facing progress value; Drift rows stay inside this repository.
class MapProgress {
  const MapProgress({
    required this.catalogVersion,
    required this.mapId,
    required this.bestRating,
    required this.bestScore,
    required this.attempts,
    this.completedAtMs,
  });

  final String catalogVersion;
  final String mapId;
  final int bestRating;
  final int bestScore;
  final int attempts;
  final int? completedAtMs;
}

/// Offline-first Level progress. A completed attempt never lowers a player's
/// previous rating or score, while every attempt increments the attempt count.
class MapProgressRepository {
  MapProgressRepository(this._db);

  final AppDatabase _db;

  Stream<Map<String, MapProgress>> watchCatalog(String catalogVersion) {
    return _db
        .watchMapProgress(catalogVersion)
        .map(
          (List<MapProgressRow> rows) => <String, MapProgress>{
            for (final MapProgressRow row in rows) row.mapId: _toProgress(row),
          },
        );
  }

  Future<MapProgress?> get(String catalogVersion, String mapId) async {
    final MapProgressRow? row = await _db.mapProgress(catalogVersion, mapId);
    return row == null ? null : _toProgress(row);
  }

  Future<void> recordAttempt({
    required String catalogVersion,
    required String mapId,
    required int score,
    required int rating,
    required int playedAtMs,
  }) {
    if (rating < 0 || rating > 3) {
      throw ArgumentError.value(rating, 'rating', 'must be between 0 and 3');
    }
    return _db.transaction(() async {
      final MapProgressRow? previous = await _db.mapProgress(
        catalogVersion,
        mapId,
      );
      final int bestRating = previous == null
          ? rating
          : (rating > previous.bestRating ? rating : previous.bestRating);
      final int bestScore = previous == null
          ? score
          : (score > previous.bestScore ? score : previous.bestScore);
      final int? completedAt = rating > 0
          ? (previous?.completedAtMs ?? playedAtMs)
          : previous?.completedAtMs;
      await _db.upsertMapProgress(
        MapProgressEntriesCompanion.insert(
          catalogVersion: catalogVersion,
          mapId: mapId,
          bestRating: Value<int>(bestRating),
          bestScore: Value<int>(bestScore),
          attempts: Value<int>((previous?.attempts ?? 0) + 1),
          completedAtMs: Value<int?>(completedAt),
        ),
      );
    });
  }

  static MapProgress _toProgress(MapProgressRow row) => MapProgress(
    catalogVersion: row.catalogVersion,
    mapId: row.mapId,
    bestRating: row.bestRating,
    bestScore: row.bestScore,
    attempts: row.attempts,
    completedAtMs: row.completedAtMs,
  );
}
