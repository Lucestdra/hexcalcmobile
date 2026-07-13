import 'dart:convert';

import 'app_database.dart';

/// Outbox operation types.
const String kOpRankedSubmit = 'ranked_submit';
const String kOpNormalResult = 'normal_result';

/// Outbox item status values.
const String kOutboxPending = 'pending';
const String kOutboxFailed = 'failed';

/// Ranked-run status values (surfaced to the UI).
const String kRankedPending = 'pending';
const String kRankedVerified = 'verified';
const String kRankedRejected = 'rejected';
const String kRankedFailed = 'failed';

/// A UI/engine-facing view of one outbox item (no Drift types leak past here).
class OutboxItem {
  const OutboxItem({
    required this.localId,
    required this.operationType,
    required this.payloadVersion,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    required this.attemptCount,
    required this.nextAttemptAt,
    required this.lastErrorCode,
    required this.status,
  });

  final int localId;
  final String operationType;
  final int payloadVersion;
  final Map<String, dynamic> payload;
  final String idempotencyKey;
  final int createdAt;
  final int attemptCount;
  final int? nextAttemptAt;
  final String? lastErrorCode;
  final String status;
}

/// A UI-facing view of a ranked run's verification status.
class RankedRunView {
  const RankedRunView({
    required this.runId,
    required this.mode,
    required this.status,
    required this.clientScore,
    required this.verifiedScore,
    required this.rejectionReason,
    required this.failureCode,
    required this.createdAtMs,
    required this.updatedAtMs,
  });

  final String runId;
  final String mode;
  final String status;
  final int clientScore;
  final int? verifiedScore;
  final String? rejectionReason;
  final String? failureCode;
  final int createdAtMs;
  final int updatedAtMs;
}

/// The only gateway between the sync engine / ranked UI and the outbox +
/// ranked-run Drift tables. Owns the transactional reconciliation so a submit's
/// result and its outbox compaction commit atomically.
class SyncStore {
  SyncStore(this._db);

  final AppDatabase _db;

  /// Persists an operation to the outbox. Returns the new item's localId.
  Future<int> enqueue({
    required String operationType,
    required int payloadVersion,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    required int nowMs,
  }) {
    return _db.insertOutbox(
      OutboxCompanion.insert(
        operationType: operationType,
        payloadVersion: payloadVersion,
        payload: jsonEncode(payload),
        idempotencyKey: idempotencyKey,
        createdAt: nowMs,
        status: kOutboxPending,
      ),
    );
  }

  /// Records a ranked run as pending (idempotent — a duplicate runId is ignored).
  Future<void> recordPendingRankedRun({
    required String runId,
    required String mode,
    required int clientScore,
    required int nowMs,
  }) {
    return _db.insertRankedRunIfAbsent(
      RankedRunsCompanion.insert(
        runId: runId,
        mode: mode,
        status: kRankedPending,
        clientScore: clientScore,
        createdAtMs: nowMs,
        updatedAtMs: nowMs,
      ),
    );
  }

  /// Atomically records the ranked run as pending AND queues its submit in one
  /// transaction, so a durable `pending` row can never exist without its backing
  /// outbox item (which would strand the run in a permanent "verifying" state). If
  /// the transaction fails, neither is written and the caller can fall back.
  Future<void> enqueueRankedSubmit({
    required String runId,
    required String mode,
    required int clientScore,
    required int payloadVersion,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    required int nowMs,
  }) {
    return _db.transaction(() async {
      await _db.insertRankedRunIfAbsent(
        RankedRunsCompanion.insert(
          runId: runId,
          mode: mode,
          status: kRankedPending,
          clientScore: clientScore,
          createdAtMs: nowMs,
          updatedAtMs: nowMs,
        ),
      );
      await _db.insertOutbox(
        OutboxCompanion.insert(
          operationType: kOpRankedSubmit,
          payloadVersion: payloadVersion,
          payload: jsonEncode(payload),
          idempotencyKey: idempotencyKey,
          createdAt: nowMs,
          status: kOutboxPending,
        ),
      );
    });
  }

  Future<List<OutboxItem>> dueItems(int nowMs) async =>
      (await _db.outboxDue(nowMs)).map(_toItem).toList(growable: false);

  Future<List<OutboxItem>> allItems() async =>
      (await _db.allOutbox()).map(_toItem).toList(growable: false);

  Future<void> reschedule({
    required int localId,
    required int attemptCount,
    required int nextAttemptAt,
    String? lastErrorCode,
  }) {
    return _db.rescheduleOutbox(
      localId: localId,
      attemptCount: attemptCount,
      nextAttemptAt: nextAttemptAt,
      lastErrorCode: lastErrorCode,
    );
  }

  /// A ranked submit succeeded (verified or rejected): record the outcome and
  /// remove the outbox item in one transaction.
  Future<void> completeRankedSubmit({
    required int localId,
    required String runId,
    required String status,
    int? verifiedScore,
    String? rejectionReason,
    required int nowMs,
  }) {
    return _db.transaction(() async {
      await _db.updateRankedRun(
        runId: runId,
        status: status,
        verifiedScore: verifiedScore,
        rejectionReason: rejectionReason,
        updatedAtMs: nowMs,
      );
      await _db.deleteOutbox(localId);
    });
  }

  /// A ranked submit failed permanently: mark the run failed (kept visible) and
  /// the outbox item failed (not retried), transactionally.
  Future<void> failRankedSubmit({
    required int localId,
    required String runId,
    required String failureCode,
    required int nowMs,
  }) {
    return _db.transaction(() async {
      await _db.updateRankedRun(
        runId: runId,
        status: kRankedFailed,
        failureCode: failureCode,
        updatedAtMs: nowMs,
      );
      await _db.markOutboxFailed(localId: localId, lastErrorCode: failureCode);
    });
  }

  Future<void> completeItem(int localId) => _db.deleteOutbox(localId);

  Future<void> failItem({required int localId, String? failureCode}) =>
      _db.markOutboxFailed(localId: localId, lastErrorCode: failureCode);

  Stream<RankedRunView?> watchRankedRun(String runId) => _db
      .watchRankedRun(runId)
      .map((RankedRunRow? r) => r == null ? null : _toRanked(r));

  Stream<List<RankedRunView>> watchRecentRankedRuns({int limit = 20}) => _db
      .watchRecentRankedRuns(limit: limit)
      .map(
        (List<RankedRunRow> rows) =>
            rows.map(_toRanked).toList(growable: false),
      );

  Stream<int> watchPendingCount() => _db.watchPendingOutboxCount();

  static OutboxItem _toItem(OutboxItemRow r) => OutboxItem(
    localId: r.localId,
    operationType: r.operationType,
    payloadVersion: r.payloadVersion,
    payload: jsonDecode(r.payload) as Map<String, dynamic>,
    idempotencyKey: r.idempotencyKey,
    createdAt: r.createdAt,
    attemptCount: r.attemptCount,
    nextAttemptAt: r.nextAttemptAt,
    lastErrorCode: r.lastErrorCode,
    status: r.status,
  );

  static RankedRunView _toRanked(RankedRunRow r) => RankedRunView(
    runId: r.runId,
    mode: r.mode,
    status: r.status,
    clientScore: r.clientScore,
    verifiedScore: r.verifiedScore,
    rejectionReason: r.rejectionReason,
    failureCode: r.failureCode,
    createdAtMs: r.createdAtMs,
    updatedAtMs: r.updatedAtMs,
  );
}
