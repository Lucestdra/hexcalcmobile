import 'package:drift/drift.dart';

part 'app_database.g.dart';

/// One completed run. Local, non-authoritative history — competitive score is
/// never sourced from here (see the product invariants).
class Runs extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Epoch milliseconds when the run finished.
  IntColumn get playedAtMs => integer()();

  /// 'normal' | 'ranked' | 'daily'.
  TextColumn get mode => text().withLength(min: 1, max: 16)();

  IntColumn get score => integer()();
  IntColumn get equations => integer()();
  IntColumn get bestCombo => integer()();
  IntColumn get levelReached => integer()();
  IntColumn get durationMs => integer()();
  TextColumn get rulesetVersion => text().withLength(min: 1, max: 32)();
  TextColumn get seed => text().withLength(min: 1, max: 128)();
}

/// Aggregate stats derived from [Runs] for the home screen.
class RunStats {
  const RunStats({
    required this.personalBest,
    required this.totalRuns,
    required this.bestCombo,
  });

  final int personalBest;
  final int totalRuns;
  final int bestCombo;

  static const RunStats empty = RunStats(
    personalBest: 0,
    totalRuns: 0,
    bestCombo: 0,
  );
}

@DriftDatabase(tables: <Type>[Runs])
class AppDatabase extends _$AppDatabase {
  /// Takes a [QueryExecutor] so this file depends only on `package:drift`. The
  /// native/on-device connection is built in `database_connection.dart` (which
  /// imports drift_flutter); tests pass `NativeDatabase.memory()`.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  Future<int> insertRun(RunsCompanion run) => into(runs).insert(run);

  Future<List<Run>> recentRuns({int limit = 10}) {
    return (select(runs)
          ..orderBy(<OrderClauseGenerator<$RunsTable>>[
            ($RunsTable t) =>
                OrderingTerm(expression: t.playedAtMs, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .get();
  }

  Stream<List<Run>> watchRecentRuns({int limit = 10}) {
    return (select(runs)
          ..orderBy(<OrderClauseGenerator<$RunsTable>>[
            ($RunsTable t) =>
                OrderingTerm(expression: t.playedAtMs, mode: OrderingMode.desc),
          ])
          ..limit(limit))
        .watch();
  }

  Future<RunStats> stats() async {
    final Expression<int> maxScore = runs.score.max();
    final Expression<int> maxCombo = runs.bestCombo.max();
    final Expression<int> count = runs.id.count();
    final JoinedSelectStatement<$RunsTable, Run> query = selectOnly(runs)
      ..addColumns(<Expression<Object>>[maxScore, maxCombo, count]);
    final TypedResult row = await query.getSingle();
    return RunStats(
      personalBest: row.read(maxScore) ?? 0,
      totalRuns: row.read(count) ?? 0,
      bestCombo: row.read(maxCombo) ?? 0,
    );
  }

  /// Emits fresh [RunStats] whenever the run table changes.
  Stream<RunStats> watchStats() {
    final Expression<int> maxScore = runs.score.max();
    final Expression<int> maxCombo = runs.bestCombo.max();
    final Expression<int> count = runs.id.count();
    final JoinedSelectStatement<$RunsTable, Run> query = selectOnly(runs)
      ..addColumns(<Expression<Object>>[maxScore, maxCombo, count]);
    return query.watchSingle().map(
      (TypedResult row) => RunStats(
        personalBest: row.read(maxScore) ?? 0,
        totalRuns: row.read(count) ?? 0,
        bestCombo: row.read(maxCombo) ?? 0,
      ),
    );
  }
}
