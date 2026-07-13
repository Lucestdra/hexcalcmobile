import 'package:dio/dio.dart';
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/api/hexcalc_api.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_repository.dart';
import 'package:hexcalc/features/leaderboard/data/leaderboard_cache_store.dart';

import '../../support/fake_http_adapter.dart';

/// Weekly top-page body with one entry.
Map<String, dynamic> _weekly({String name = 'Ada', int score = 900}) =>
    <String, dynamic>{
      'weekStartUtc': '2026-07-06T00:00:00Z',
      'status': 'open',
      'entries': <Map<String, dynamic>>[
        <String, dynamic>{
          'rank': 1,
          'playerId': 'p1',
          'displayName': name,
          'score': score,
          'achievedAtUtc': '2026-07-07T10:00:00Z',
          'isCurrentPlayer': true,
        },
      ],
      'nextCursor': null,
      'asOfUtc': '2026-07-08T12:00:00Z',
    };

Map<String, dynamic> _me({int rank = 1}) => <String, dynamic>{
  'weekStartUtc': '2026-07-06T00:00:00Z',
  'status': 'open',
  'rank': rank,
  'totalPlayers': 1,
  'window': <Map<String, dynamic>>[
    <String, dynamic>{
      'rank': rank,
      'playerId': 'p1',
      'displayName': 'Ada',
      'score': 900,
      'achievedAtUtc': '2026-07-07T10:00:00Z',
      'isCurrentPlayer': true,
    },
  ],
  'asOfUtc': '2026-07-08T12:00:00Z',
};

DioException _offline() => DioException(
  requestOptions: RequestOptions(path: '/'),
  type: DioExceptionType.connectionError,
);

void main() {
  late AppDatabase db;
  late LeaderboardCacheStore cache;
  late FakeHttpAdapter fake;
  late HexcalcApi api;
  late int clock;

  const String topPath = '/api/v1/leaderboards/weekly';
  const String mePath = '/api/v1/leaderboards/weekly/me';

  LeaderboardRepository makeRepo() =>
      LeaderboardRepository(api: api, cache: cache, nowMs: () => clock);

  setUp(() async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    db = AppDatabase(NativeDatabase.memory());
    cache = LeaderboardCacheStore(db);
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
    clock = 5000;
  });

  tearDown(() async => db.close());

  void serveLive() {
    fake.on('GET', topPath, (_) => FakeResponse.json(200, _weekly()));
    fake.on('GET', mePath, (_) => FakeResponse.json(200, _me()));
  }

  const String userA = 'user-a';
  const String userB = 'user-b';

  test('a live load returns live data and refreshes the cache', () async {
    serveLive();
    final LeaderboardData data = await makeRepo().load(userA);

    expect(data.source, LeaderboardSource.live);
    expect(data.isFromCache, isFalse);
    expect(data.top.entries.single.displayName, 'Ada');
    expect(data.me.rank, 1);

    // Both keys are now cached for this user.
    expect(await cache.read(userA, kLeaderboardTopKey), isNotNull);
    expect(await cache.read(userA, kLeaderboardMeKey), isNotNull);
  });

  test('offline with a warm cache returns the cached copy', () async {
    // Warm the cache with a live load at t=5000.
    serveLive();
    await makeRepo().load(userA);

    // Go offline and advance the clock.
    fake.on('GET', topPath, (_) => throw _offline());
    fake.on('GET', mePath, (_) => throw _offline());
    clock = 9000;

    final LeaderboardData data = await makeRepo().load(userA);
    expect(data.source, LeaderboardSource.cached);
    expect(data.isFromCache, isTrue);
    expect(data.cachedAtMs, 5000); // the fetch time, not "now"
    expect(data.top.entries.single.displayName, 'Ada');
    expect(data.me.rank, 1);
  });

  test(
    'offline with no cache surfaces the offline (NetworkError) state',
    () async {
      fake.on('GET', topPath, (_) => throw _offline());
      fake.on('GET', mePath, (_) => throw _offline());

      await expectLater(makeRepo().load(userA), throwsA(isA<NetworkError>()));
    },
  );

  test('a server error propagates (never masked by stale cache)', () async {
    // Warm cache first so we prove a 5xx is NOT silently served from cache.
    serveLive();
    await makeRepo().load(userA);

    fake.on(
      'GET',
      topPath,
      (_) => FakeResponse.json(500, <String, dynamic>{'title': 'boom'}),
    );

    await expectLater(makeRepo().load(userA), throwsA(isA<ServerError>()));
  });

  test('one user never sees another user\'s cached standings offline', () async {
    // User A caches their board online...
    serveLive();
    await makeRepo().load(userA);

    // ...then user B opens the board offline. B must miss A's cache and get the
    // honest offline state, NOT A's rank/rows.
    fake.on('GET', topPath, (_) => throw _offline());
    fake.on('GET', mePath, (_) => throw _offline());

    await expectLater(makeRepo().load(userB), throwsA(isA<NetworkError>()));
  });

  test('a structurally-corrupt cached payload is treated as a miss', () async {
    // Poison the cache with a well-formed-JSON but wrong-shaped payload (as a
    // DTO shape change across an app upgrade could produce).
    await cache.write(userA, kLeaderboardTopKey, <String, dynamic>{
      'entries': 'not-a-list',
    }, 5000);
    await cache.write(userA, kLeaderboardMeKey, <String, dynamic>{
      'window': 'not-a-list',
    }, 5000);

    fake.on('GET', topPath, (_) => throw _offline());
    fake.on('GET', mePath, (_) => throw _offline());

    // The corrupt payload must not crash; it is a miss → honest offline state.
    await expectLater(makeRepo().load(userA), throwsA(isA<NetworkError>()));
  });
}
