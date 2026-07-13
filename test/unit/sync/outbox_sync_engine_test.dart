import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/api/hexcalc_api.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/core/networking/connectivity_monitor.dart';
import 'package:hexcalc/core/sync/outbox_sync_engine.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/sync_store.dart';

import '../../support/fake_http_adapter.dart';

/// A connectivity monitor whose online flag the test controls.
class _FakeConnectivity implements ConnectivityMonitor {
  bool online = true;

  @override
  Stream<bool> get onOnline => const Stream<bool>.empty();

  @override
  Future<bool> isOnline() async => online;
}

void main() {
  late AppDatabase db;
  late SyncStore store;
  late FakeHttpAdapter fake;
  late HexcalcApi api;
  late _FakeConnectivity connectivity;
  late int clock;
  late double randomValue;

  OutboxSyncEngine makeEngine() => OutboxSyncEngine(
    store: store,
    api: api,
    connectivity: connectivity,
    nowMs: () => clock,
    nextRandom: () => randomValue,
  );

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    store = SyncStore(db);
    fake = FakeHttpAdapter();
    final InMemoryTokenStore tokens = InMemoryTokenStore();
    await tokens.write(
      const AuthTokenSet(accessToken: 'a', refreshToken: 'r', userId: 'u'),
    );
    api = HexcalcApi(
      ApiClient(
        baseUrl: 'http://test.local',
        tokenStore: tokens,
        dioBuilder: fakeDioBuilder(fake),
      ),
    );
    connectivity = _FakeConnectivity();
    clock = 1000;
    randomValue = 0.5;
  });

  tearDown(() async => db.close());

  Future<void> queueRanked({
    String runId = 'run-1',
    int clientScore = 105,
    String key = 'idem-1',
    Object? eventLog,
  }) async {
    await store.enqueueRankedSubmit(
      runId: runId,
      mode: 'ranked',
      clientScore: clientScore,
      payloadVersion: 1,
      payload: <String, dynamic>{
        'runId': runId,
        'challengeToken': 'token-$runId',
        'eventLog':
            eventLog ??
            <String, dynamic>{
              'payloadVersion': 1,
              'clientTotalScore': clientScore,
              'events': <dynamic>[],
            },
      },
      idempotencyKey: key,
      nowMs: clock,
    );
  }

  group('backoffFor', () {
    test('stays within [cap/2, cap] and grows then caps', () {
      // The engine's rng reads the mutable `randomValue`, so evaluate all of one
      // engine's calls before changing it.
      randomValue = 0.0;
      final OutboxSyncEngine low = makeEngine();
      expect(low.backoffFor(1).inMilliseconds, 1000); // cap 2000 -> floor
      expect(low.backoffFor(2).inMilliseconds, 2000); // cap 4000 -> floor
      expect(low.backoffFor(3).inMilliseconds, 4000); // cap 8000 -> floor
      // Capped at the maximum regardless of attempt.
      expect(
        low.backoffFor(40).inMilliseconds,
        OutboxSyncEngine.maxBackoffMs ~/ 2,
      );

      randomValue = 1.0;
      final OutboxSyncEngine high = makeEngine();
      expect(high.backoffFor(1).inMilliseconds, 2000); // cap 2000
      expect(high.backoffFor(2).inMilliseconds, 4000); // cap 4000
      expect(high.backoffFor(40).inMilliseconds, OutboxSyncEngine.maxBackoffMs);
    });
  });

  test('a verified submit records the score and compacts the outbox', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/run-1/submit',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'clientScore': 105,
        'anomalyFlags': <String>[],
      }),
    );
    await queueRanked();

    await makeEngine().drain();

    final RankedRunView? run = await store.watchRankedRun('run-1').first;
    expect(run!.status, kRankedVerified);
    expect(run.verifiedScore, 105);
    expect(await store.allItems(), isEmpty); // compacted on ack
  });

  test('a rejected submit is recorded but never shown as verified', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/run-1/submit',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'rejected',
        'verifiedScore': null,
        'clientScore': 105,
        'anomalyFlags': <String>[],
        'rejectionReason': 'non_adjacent_path',
      }),
    );
    await queueRanked();

    await makeEngine().drain();

    final RankedRunView? run = await store.watchRankedRun('run-1').first;
    expect(run!.status, kRankedRejected);
    expect(run.rejectionReason, 'non_adjacent_path');
    expect(run.verifiedScore, isNull);
    expect(await store.allItems(), isEmpty);
  });

  test(
    'a permanent 4xx is terminal: failed, kept visible, not retried',
    () async {
      fake.on(
        'POST',
        '/api/v1/game-runs/run-1/submit',
        (_) => FakeResponse.json(409, <String, dynamic>{
          'code': 'game.run_already_submitted',
          'detail': 'This run has already been submitted.',
          'status': 409,
        }),
      );
      await queueRanked();

      await makeEngine().drain();

      final RankedRunView? run = await store.watchRankedRun('run-1').first;
      expect(run!.status, kRankedFailed);
      expect(run.failureCode, 'game.run_already_submitted');
      // The item is kept (status failed) but no longer due for retry.
      final List<OutboxItem> items = await store.allItems();
      expect(items.single.status, kOutboxFailed);
      expect(await store.dueItems(clock + 10_000_000), isEmpty);
    },
  );

  test('a transient 5xx backs off and retries, then succeeds', () async {
    int calls = 0;
    fake.on('POST', '/api/v1/game-runs/run-1/submit', (_) {
      calls++;
      if (calls == 1) {
        return FakeResponse.json(503, <String, dynamic>{'status': 503});
      }
      return FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'clientScore': 105,
        'anomalyFlags': <String>[],
      });
    });
    await queueRanked();

    await makeEngine().drain(); // 5xx -> reschedule
    final List<OutboxItem> items = await store.allItems();
    expect(items.single.status, kOutboxPending);
    expect(items.single.attemptCount, 1);
    expect(items.single.nextAttemptAt, greaterThan(clock));
    expect((await store.watchRankedRun('run-1').first)!.status, kRankedPending);

    // Not yet due — a drain now is a no-op.
    await makeEngine().drain();
    expect(await store.allItems(), hasLength(1));

    // Advance past the backoff — now it drains and verifies.
    clock = items.single.nextAttemptAt! + 1;
    await makeEngine().drain();
    expect(
      (await store.watchRankedRun('run-1').first)!.status,
      kRankedVerified,
    );
    expect(await store.allItems(), isEmpty);
  });

  test('offline pauses the drain — no request is made', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/run-1/submit',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'anomalyFlags': <String>[],
      }),
    );
    await queueRanked();
    connectivity.online = false;

    await makeEngine().drain();

    expect(fake.callsTo('POST', '/api/v1/game-runs/run-1/submit'), 0);
    expect(await store.allItems(), hasLength(1)); // untouched
    expect((await store.watchRankedRun('run-1').first)!.status, kRankedPending);
  });

  test('concurrent drains are single-flight (one network call)', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/run-1/submit',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'anomalyFlags': <String>[],
      }),
    );
    await queueRanked();
    final OutboxSyncEngine engine = makeEngine();

    await Future.wait<void>(<Future<void>>[engine.drain(), engine.drain()]);

    expect(fake.callsTo('POST', '/api/v1/game-runs/run-1/submit'), 1);
  });

  test('a queued submit survives a restart (new engine, same store)', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/run-1/submit',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'anomalyFlags': <String>[],
      }),
    );
    await queueRanked();

    // Simulate app kill before the first drain: a brand-new engine over the same
    // persisted store must still pick up and complete the queued submission.
    final OutboxSyncEngine afterRestart = makeEngine();
    await afterRestart.drain();

    expect(
      (await store.watchRankedRun('run-1').first)!.status,
      kRankedVerified,
    );
    expect(await store.allItems(), isEmpty);
  });

  test('submit carries the item Idempotency-Key header', () async {
    String? seenKey;
    fake.on('POST', '/api/v1/game-runs/run-1/submit', (options) {
      seenKey = options.headers['Idempotency-Key'] as String?;
      return FakeResponse.json(200, <String, dynamic>{
        'runId': 'run-1',
        'mode': 'ranked',
        'status': 'verified',
        'verifiedScore': 105,
        'anomalyFlags': <String>[],
      });
    });
    await queueRanked(key: 'idem-XYZ');

    await makeEngine().drain();

    expect(seenKey, 'idem-XYZ');
  });

  test('a normal-result sync is deleted on ack', () async {
    fake.on(
      'POST',
      '/api/v1/game-runs/normal-results',
      (_) => FakeResponse.json(200, <String, dynamic>{'status': 'recorded'}),
    );
    await store.enqueue(
      operationType: kOpNormalResult,
      payloadVersion: 1,
      payload: <String, dynamic>{
        'rulesetVersion': 'rs-v1',
        'generatorVersion': 'gen-v1',
        'seed': 'seed-1',
        'clientScore': 42,
        'playedAtUtc': '2026-01-01T00:00:00.000Z',
      },
      idempotencyKey: 'n-1',
      nowMs: clock,
    );

    await makeEngine().drain();

    expect(fake.callsTo('POST', '/api/v1/game-runs/normal-results'), 1);
    expect(await store.allItems(), isEmpty);
  });

  test(
    'a non-verdict 200 (issued/missing status) is retried, not rejected',
    () async {
      // The submit endpoint accepts but does not decide (e.g. a bare ack). The run
      // must NOT be recorded as rejected — it stays pending and is retried.
      fake.on(
        'POST',
        '/api/v1/game-runs/run-1/submit',
        (_) => FakeResponse.json(200, <String, dynamic>{
          'runId': 'run-1',
          'mode': 'ranked',
        }), // status defaults to 'issued'
      );
      await queueRanked();

      await makeEngine().drain();

      expect(
        (await store.watchRankedRun('run-1').first)!.status,
        kRankedPending,
      );
      final OutboxItem item = (await store.allItems()).single;
      expect(item.status, kOutboxPending);
      expect(item.attemptCount, 1); // rescheduled for another try
    },
  );

  test(
    'a malformed payload fails terminally and does not block the queue',
    () async {
      // A legacy/corrupt item whose eventLog is not a Map: dispatching it throws a
      // non-AppError. It must be failed terminally, and a following good item must
      // still drain in the same pass (no poison head-of-line block).
      await queueRanked(
        runId: 'run-bad',
        key: 'k-bad',
        eventLog: <int>[1, 2, 3],
      );
      await queueRanked(runId: 'run-good', key: 'k-good');
      fake.on(
        'POST',
        '/api/v1/game-runs/run-good/submit',
        (_) => FakeResponse.json(200, <String, dynamic>{
          'runId': 'run-good',
          'mode': 'ranked',
          'status': 'verified',
          'verifiedScore': 200,
          'anomalyFlags': <String>[],
        }),
      );

      await makeEngine().drain();

      expect(
        (await store.watchRankedRun('run-bad').first)!.status,
        kRankedFailed,
      );
      expect(
        (await store.watchRankedRun('run-good').first)!.status,
        kRankedVerified,
      );
    },
  );

  test(
    'enqueueRankedSubmit writes the run row and the outbox item atomically',
    () async {
      await queueRanked();

      expect(
        (await store.watchRankedRun('run-1').first)!.status,
        kRankedPending,
      );
      final OutboxItem item = (await store.allItems()).single;
      expect(item.operationType, kOpRankedSubmit);
      expect(item.idempotencyKey, 'idem-1');
    },
  );
}
