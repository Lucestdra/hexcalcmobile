import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/api/dtos.dart';
import 'package:hexcalc/core/api/hexcalc_api.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/core/networking/api_client.dart';

import '../../support/fake_http_adapter.dart';

class _Harness {
  _Harness(this.client, this.api, this.fake, this.store);

  final ApiClient client;
  final HexcalcApi api;
  final FakeHttpAdapter fake;
  final InMemoryTokenStore store;

  static Future<_Harness> create() async {
    final store = InMemoryTokenStore();
    await store.write(
      const AuthTokenSet(accessToken: 'old', refreshToken: 'r1', userId: 'u'),
    );
    final fake = FakeHttpAdapter();
    final client = ApiClient(
      baseUrl: 'http://test.local',
      tokenStore: store,
      dioBuilder: fakeDioBuilder(fake),
    );
    return _Harness(client, HexcalcApi(client), fake, store);
  }
}

void main() {
  const Map<String, dynamic> profileJson = <String, dynamic>{
    'id': 'u',
    'displayName': 'Player',
    'locale': 'en',
    'status': 'Active',
    'createdAtUtc': '2026-01-01T00:00:00Z',
  };
  const Map<String, dynamic> refreshedJson = <String, dynamic>{
    'accessToken': 'access-1',
    'refreshToken': 'refresh-1',
    'tokenType': 'Bearer',
    'expiresInSeconds': 900,
    'userId': 'u',
  };

  test(
    'N concurrent 401s trigger exactly one refresh, then all requests succeed',
    () async {
      final _Harness h = await _Harness.create();
      // A stale token 401s; only the refreshed token is accepted.
      h.fake.on('GET', '/api/v1/players/me', (options) {
        return options.headers['Authorization'] == 'Bearer access-1'
            ? FakeResponse.json(200, profileJson)
            : FakeResponse.json(401, <String, dynamic>{
                'status': 401,
                'code': 'auth.expired',
              });
      });
      h.fake.on(
        'POST',
        '/api/v1/auth/refresh',
        (_) => FakeResponse.json(200, refreshedJson),
      );

      final List<PlayerProfile> results = await Future.wait<PlayerProfile>(
        List<Future<PlayerProfile>>.generate(8, (_) => h.api.getMe()),
      );

      expect(results, hasLength(8));
      expect(results.every((PlayerProfile p) => p.id == 'u'), isTrue);
      expect(h.fake.callsTo('POST', '/api/v1/auth/refresh'), 1);
      expect((await h.store.read())!.accessToken, 'access-1');
    },
  );

  test(
    'a rejected refresh surfaces UnauthorizedError and signals signed-out',
    () async {
      final _Harness h = await _Harness.create();
      bool signedOut = false;
      h.client.onSignedOut = () => signedOut = true;

      h.fake.on(
        'GET',
        '/api/v1/players/me',
        (_) => FakeResponse.json(401, <String, dynamic>{'status': 401}),
      );
      h.fake.on(
        'POST',
        '/api/v1/auth/refresh',
        (_) => FakeResponse.json(401, <String, dynamic>{
          'status': 401,
          'code': 'auth.refresh_token_reuse',
        }),
      );

      await expectLater(h.api.getMe(), throwsA(isA<UnauthorizedError>()));
      expect(signedOut, isTrue);
      expect(
        await h.store.read(),
        isNull,
      ); // rejected refresh cleared the tokens
    },
  );

  test(
    'a transient 5xx during refresh fails cleanly but keeps the tokens',
    () async {
      final _Harness h = await _Harness.create();
      bool signedOut = false;
      h.client.onSignedOut = () => signedOut = true;
      h.fake.on(
        'GET',
        '/api/v1/players/me',
        (_) => FakeResponse.json(401, <String, dynamic>{'status': 401}),
      );
      // The refresh itself hits a transient 5xx — the session must NOT be destroyed.
      h.fake.on(
        'POST',
        '/api/v1/auth/refresh',
        (_) => FakeResponse.json(503, <String, dynamic>{'status': 503}),
      );

      await expectLater(h.api.getMe(), throwsA(isA<AppError>()));
      expect(signedOut, isFalse); // not signed out on a transient error
      expect(
        await h.store.read(),
        isNotNull,
      ); // tokens preserved for a later retry
    },
  );
}
