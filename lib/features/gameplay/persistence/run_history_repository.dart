import 'package:drift/drift.dart' show Value;

import 'app_database.dart';

/// A UI-facing view of one stored run (no Drift types leak past this layer).
class RunSummary {
  const RunSummary({
    required this.playedAtMs,
    required this.mode,
    required this.score,
    required this.equations,
    required this.bestCombo,
    required this.levelReached,
    this.targetsSolved = 0,
    this.protocolVersion,
    this.mapCatalogVersion,
    this.mapId,
    this.rating,
  });

  final int playedAtMs;
  final String mode;
  final int score;
  final int equations;
  final int bestCombo;
  final int levelReached;
  final int targetsSolved;
  final String? protocolVersion;
  final String? mapCatalogVersion;
  final String? mapId;
  final int? rating;
}

/// The only gateway between the app and the run-history [AppDatabase]. Widgets,
/// controllers, and Flame never touch Drift directly (per the working agreement).
class RunHistoryRepository {
  RunHistoryRepository(this._db);

  final AppDatabase _db;

  Future<void> recordRun({
    required int playedAtMs,
    required String mode,
    required int score,
    required int equations,
    required int bestCombo,
    required int levelReached,
    required int durationMs,
    required String rulesetVersion,
    required String seed,
    String? protocolVersion,
    String? mapCatalogVersion,
    String? mapId,
    int targetsSolved = 0,
    int? rating,
  }) {
    return _db.insertRun(
      RunsCompanion.insert(
        playedAtMs: playedAtMs,
        mode: mode,
        score: score,
        equations: equations,
        bestCombo: bestCombo,
        levelReached: levelReached,
        durationMs: durationMs,
        rulesetVersion: rulesetVersion,
        seed: seed,
        protocolVersion: Value<String?>(protocolVersion),
        mapCatalogVersion: Value<String?>(mapCatalogVersion),
        mapId: Value<String?>(mapId),
        targetsSolved: Value<int>(targetsSolved),
        rating: Value<int?>(rating),
      ),
    );
  }

  Stream<RunStats> watchStats() => _db.watchStats();

  Stream<List<RunSummary>> watchRecentRuns({int limit = 10}) {
    return _db
        .watchRecentRuns(limit: limit)
        .map((List<Run> rows) => rows.map(_toSummary).toList(growable: false));
  }

  Future<RunStats> stats() => _db.stats();

  Future<List<RunSummary>> recentRuns({int limit = 10}) async {
    final List<Run> rows = await _db.recentRuns(limit: limit);
    return rows.map(_toSummary).toList(growable: false);
  }

  Future<void> close() => _db.close();

  static RunSummary _toSummary(Run r) => RunSummary(
    playedAtMs: r.playedAtMs,
    mode: r.mode,
    score: r.score,
    equations: r.equations,
    bestCombo: r.bestCombo,
    levelReached: r.levelReached,
    targetsSolved: r.targetsSolved,
    protocolVersion: r.protocolVersion,
    mapCatalogVersion: r.mapCatalogVersion,
    mapId: r.mapId,
    rating: r.rating,
  );
}
