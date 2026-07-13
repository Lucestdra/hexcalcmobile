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

/// A durable outbox item for a server operation that must survive app kill and be
/// retried with backoff (ranked submit, normal-result sync). Shape per the working
/// agreement's Offline Outbox Rules. [status] is `pending` | `failed`.
@DataClassName('OutboxItemRow')
class Outbox extends Table {
  IntColumn get localId => integer().autoIncrement()();
  TextColumn get operationType => text().withLength(min: 1, max: 64)();
  IntColumn get payloadVersion => integer()();

  /// The JSON request body (already mapped), stored as text.
  TextColumn get payload => text()();
  TextColumn get idempotencyKey => text().withLength(min: 1, max: 128)();

  /// Epoch ms the item was enqueued.
  IntColumn get createdAt => integer()();
  IntColumn get attemptCount => integer().withDefault(const Constant<int>(0))();

  /// Epoch ms before which the item should not be retried (backoff); null = due now.
  IntColumn get nextAttemptAt => integer().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get status => text().withLength(min: 1, max: 24)();
}

/// A local record of a ranked run's verification status, kept so a rejected/failed
/// run stays visible to the player after its outbox item is compacted. [status] is
/// `pending` | `verified` | `rejected` | `failed`.
@DataClassName('RankedRunRow')
class RankedRuns extends Table {
  TextColumn get runId => text().withLength(min: 1, max: 64)();
  TextColumn get mode => text().withLength(min: 1, max: 16)();
  TextColumn get status => text().withLength(min: 1, max: 16)();
  IntColumn get clientScore => integer()();
  IntColumn get verifiedScore => integer().nullable()();
  TextColumn get rejectionReason => text().nullable()();
  TextColumn get failureCode => text().nullable()();
  IntColumn get createdAtMs => integer()();
  IntColumn get updatedAtMs => integer()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{runId};
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

@DriftDatabase(tables: <Type>[Runs, Outbox, RankedRuns])
class AppDatabase extends _$AppDatabase {
  /// Takes a [QueryExecutor] so this file depends only on `package:drift`. The
  /// native/on-device connection is built in `database_connection.dart` (which
  /// imports drift_flutter); tests pass `NativeDatabase.memory()`.
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (Migrator m) => m.createAll(),
    onUpgrade: (Migrator m, int from, int to) async {
      if (from < 2) {
        await m.createTable(outbox);
        await m.createTable(rankedRuns);
      }
    },
  );

  Future<int> insertRun(RunsCompanion run) => into(runs).insert(run);

  // ── Outbox ────────────────────────────────────────────────────────────────

  Future<int> insertOutbox(OutboxCompanion item) => into(outbox).insert(item);

  /// Pending items whose backoff has elapsed, oldest first.
  Future<List<OutboxItemRow>> outboxDue(int nowMs) {
    return (select(outbox)
          ..where(
            ($OutboxTable t) =>
                t.status.equals('pending') &
                (t.nextAttemptAt.isNull() |
                    t.nextAttemptAt.isSmallerOrEqualValue(nowMs)),
          )
          ..orderBy(<OrderClauseGenerator<$OutboxTable>>[
            ($OutboxTable t) => OrderingTerm(expression: t.createdAt),
          ]))
        .get();
  }

  Future<List<OutboxItemRow>> allOutbox() => select(outbox).get();

  Future<int> rescheduleOutbox({
    required int localId,
    required int attemptCount,
    required int nextAttemptAt,
    String? lastErrorCode,
  }) {
    return (update(
      outbox,
    )..where(($OutboxTable t) => t.localId.equals(localId))).write(
      OutboxCompanion(
        attemptCount: Value<int>(attemptCount),
        nextAttemptAt: Value<int?>(nextAttemptAt),
        lastErrorCode: Value<String?>(lastErrorCode),
      ),
    );
  }

  Future<int> markOutboxFailed({required int localId, String? lastErrorCode}) {
    return (update(
      outbox,
    )..where(($OutboxTable t) => t.localId.equals(localId))).write(
      OutboxCompanion(
        status: const Value<String>('failed'),
        lastErrorCode: Value<String?>(lastErrorCode),
      ),
    );
  }

  Future<int> deleteOutbox(int localId) => (delete(
    outbox,
  )..where(($OutboxTable t) => t.localId.equals(localId))).go();

  Stream<int> watchPendingOutboxCount() {
    final Expression<int> count = outbox.localId.count();
    final JoinedSelectStatement<$OutboxTable, OutboxItemRow> q =
        selectOnly(outbox)
          ..addColumns(<Expression<Object>>[count])
          ..where(outbox.status.equals('pending'));
    return q.watchSingle().map((TypedResult r) => r.read(count) ?? 0);
  }

  // ── Ranked runs ─────────────────────────────────────────────────────────────

  Future<int> insertRankedRunIfAbsent(RankedRunsCompanion row) =>
      into(rankedRuns).insert(row, mode: InsertMode.insertOrIgnore);

  Future<int> updateRankedRun({
    required String runId,
    required String status,
    int? verifiedScore,
    String? rejectionReason,
    String? failureCode,
    required int updatedAtMs,
  }) {
    return (update(
      rankedRuns,
    )..where(($RankedRunsTable t) => t.runId.equals(runId))).write(
      RankedRunsCompanion(
        status: Value<String>(status),
        verifiedScore: Value<int?>(verifiedScore),
        rejectionReason: Value<String?>(rejectionReason),
        failureCode: Value<String?>(failureCode),
        updatedAtMs: Value<int>(updatedAtMs),
      ),
    );
  }

  Stream<RankedRunRow?> watchRankedRun(String runId) {
    return (select(rankedRuns)
          ..where(($RankedRunsTable t) => t.runId.equals(runId)))
        .watchSingleOrNull();
  }

  Future<RankedRunRow?> rankedRun(String runId) {
    return (select(
      rankedRuns,
    )..where(($RankedRunsTable t) => t.runId.equals(runId))).getSingleOrNull();
  }

  Stream<List<RankedRunRow>> watchRecentRankedRuns({int limit = 20}) {
    return (select(rankedRuns)
          ..orderBy(<OrderClauseGenerator<$RankedRunsTable>>[
            ($RankedRunsTable t) => OrderingTerm(
              expression: t.createdAtMs,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(limit))
        .watch();
  }

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
