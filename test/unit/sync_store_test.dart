import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/sync_store.dart';

void main() {
  late AppDatabase db;
  late SyncStore store;

  setUp(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    store = SyncStore(db);
  });

  tearDown(() async => db.close());

  Future<int> enqueueNormal({required String key, required int nowMs}) {
    return store.enqueue(
      operationType: kOpNormalResult,
      payloadVersion: 1,
      payload: <String, dynamic>{'x': 1},
      idempotencyKey: key,
      nowMs: nowMs,
    );
  }

  test('dueItems excludes items whose backoff has not elapsed', () async {
    final int a = await enqueueNormal(key: 'a', nowMs: 1000);
    await store.reschedule(
      localId: a,
      attemptCount: 1,
      nextAttemptAt: 10000,
      lastErrorCode: 'server_error',
    );
    await enqueueNormal(key: 'b', nowMs: 1000); // due now (null nextAttemptAt)

    expect(
      (await store.dueItems(5000)).map((OutboxItem i) => i.idempotencyKey),
      <String>['b'],
    );
    // Once time passes the backoff, both are due (oldest first).
    expect(
      (await store.dueItems(20000)).map((OutboxItem i) => i.idempotencyKey),
      <String>['a', 'b'],
    );
  });

  test('a failed item is never due again', () async {
    final int a = await enqueueNormal(key: 'a', nowMs: 1000);
    await store.failItem(localId: a, failureCode: 'game.invalid_challenge');

    expect(await store.dueItems(9999999), isEmpty);
    final OutboxItem item = (await store.allItems()).single;
    expect(item.status, kOutboxFailed);
    expect(item.lastErrorCode, 'game.invalid_challenge');
  });

  test('recordPendingRankedRun is idempotent for a duplicate runId', () async {
    await store.recordPendingRankedRun(
      runId: 'run-1',
      mode: 'ranked',
      clientScore: 100,
      nowMs: 1000,
    );
    // A duplicate (e.g. a resumed enqueue) must not overwrite or throw.
    await store.recordPendingRankedRun(
      runId: 'run-1',
      mode: 'ranked',
      clientScore: 999,
      nowMs: 2000,
    );

    final RankedRunView? run = await store.watchRankedRun('run-1').first;
    expect(run!.clientScore, 100); // first write wins; ignored on conflict
    expect(run.status, kRankedPending);
  });

  test(
    'completeRankedSubmit is transactional: run updated and item removed',
    () async {
      final int local = await store.enqueue(
        operationType: kOpRankedSubmit,
        payloadVersion: 1,
        payload: <String, dynamic>{'runId': 'run-1'},
        idempotencyKey: 'k',
        nowMs: 1000,
      );
      await store.recordPendingRankedRun(
        runId: 'run-1',
        mode: 'ranked',
        clientScore: 100,
        nowMs: 1000,
      );

      await store.completeRankedSubmit(
        localId: local,
        runId: 'run-1',
        status: kRankedVerified,
        verifiedScore: 123,
        nowMs: 3000,
      );

      expect(await store.allItems(), isEmpty);
      final RankedRunView run = (await store.watchRankedRun('run-1').first)!;
      expect(run.status, kRankedVerified);
      expect(run.verifiedScore, 123);
    },
  );
}
