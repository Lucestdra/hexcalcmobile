import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/networking/api_client.dart';

import '../../support/fake_http_adapter.dart';

String _fakeJwt(String role) {
  String seg(Object o) => base64Url.encode(utf8.encode(jsonEncode(o)));
  return '${seg(<String, String>{'alg': 'none'})}.${seg(<String, String>{'role': role})}.sig';
}

Map<String, dynamic> _tokens(
  String access,
  String user, {
  String refresh = 'r',
}) => <String, dynamic>{
  'accessToken': access,
  'refreshToken': refresh,
  'tokenType': 'Bearer',
  'expiresInSeconds': 900,
  'userId': user,
};

/// Deterministically awaits the notifier's non-blocking bootstrap to finish
/// (state leaves `isBootstrapping`), so nothing is left pending at teardown.
Future<void> _settleBootstrap(ProviderContainer c) async {
  for (int i = 0; i < 200; i++) {
    if (!c.read(authSessionProvider).isBootstrapping) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 2));
  }
}

void main() {
  late FakeHttpAdapter fake;
  late InMemoryTokenStore store;

  ProviderContainer makeContainer() {
    final ProviderContainer container = ProviderContainer(
      overrides: [
        apiBaseUrlProvider.overrideWithValue('http://test.local'),
        tokenStoreProvider.overrideWithValue(store),
        apiClientProvider.overrideWith(
          (ref) => ApiClient(
            baseUrl: ref.read(apiBaseUrlProvider),
            tokenStore: ref.read(tokenStoreProvider),
            dioBuilder: fakeDioBuilder(fake),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    fake = FakeHttpAdapter();
    store = InMemoryTokenStore();
    fake.on(
      'POST',
      '/api/v1/auth/guest',
      (_) => FakeResponse.json(200, _tokens(_fakeJwt('guest'), 'guest-1')),
    );
  });

  test('bootstrap with no tokens creates a guest session', () async {
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider); // trigger build/bootstrap
    await _settleBootstrap(c);

    final AuthState state = c.read(authSessionProvider);
    expect(state.kind, AuthKind.guest);
    expect(state.isBootstrapping, isFalse);
    expect((await store.read())!.userId, 'guest-1');
  });

  test('a stored account token restores an account session', () async {
    await store.write(
      AuthTokenSet(
        accessToken: _fakeJwt('user'),
        refreshToken: 'r',
        userId: 'acc-1',
      ),
    );
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider);
    await _settleBootstrap(c);

    expect(c.read(authSessionProvider).kind, AuthKind.account);
    expect(c.read(authSessionProvider).userId, 'acc-1');
  });

  test('login persists tokens and becomes an account', () async {
    fake.on(
      'POST',
      '/api/v1/auth/login',
      (_) => FakeResponse.json(200, _tokens(_fakeJwt('user'), 'acc-2')),
    );
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider); // trigger build/guest bootstrap
    await _settleBootstrap(c);

    await c.read(authSessionProvider.notifier).signIn('a@b.com', 'Passw0rd!23');

    expect(c.read(authSessionProvider).kind, AuthKind.account);
    expect((await store.read())!.userId, 'acc-2');
  });

  test('register returns a status and leaves the session unchanged', () async {
    fake.on(
      'POST',
      '/api/v1/auth/register',
      (_) => FakeResponse.json(202, <String, dynamic>{
        'status': 'registration_received',
      }),
    );
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider);
    await _settleBootstrap(c);

    final status = await c
        .read(authSessionProvider.notifier)
        .register('a@b.com', 'Passw0rd!23');

    expect(status.status, 'registration_received');
    expect(c.read(authSessionProvider).kind, AuthKind.guest); // still a guest
  });

  test('linking merges the guest into an account', () async {
    fake.on(
      'POST',
      '/api/v1/auth/link-account',
      (_) => FakeResponse.json(200, _tokens(_fakeJwt('user'), 'acc-3')),
    );
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider);
    await _settleBootstrap(c);
    expect(c.read(authSessionProvider).kind, AuthKind.guest);

    await c
        .read(authSessionProvider.notifier)
        .linkAccount('a@b.com', 'Passw0rd!23');

    expect(c.read(authSessionProvider).kind, AuthKind.account);
    expect((await store.read())!.userId, 'acc-3');
  });

  test('signing out clears then bootstraps a fresh guest', () async {
    fake.on(
      'POST',
      '/api/v1/auth/login',
      (_) => FakeResponse.json(200, _tokens(_fakeJwt('user'), 'acc-4')),
    );
    fake.on('POST', '/api/v1/auth/logout', (_) => const FakeResponse(204, ''));
    final ProviderContainer c = makeContainer();
    c.read(authSessionProvider);
    await _settleBootstrap(c);
    await c.read(authSessionProvider.notifier).signIn('a@b.com', 'Passw0rd!23');
    expect(c.read(authSessionProvider).kind, AuthKind.account);

    await c.read(authSessionProvider.notifier).signOut();

    expect(c.read(authSessionProvider).kind, AuthKind.guest);
    expect((await store.read())!.userId, 'guest-1');
    expect(fake.callsTo('POST', '/api/v1/auth/logout'), 1);
  });

  test(
    'concurrent ensureGuest calls sign in only once (single-flight)',
    () async {
      final ProviderContainer c = makeContainer();
      final AuthSessionNotifier notifier = c.read(authSessionProvider.notifier);
      // Fire several alongside the bootstrap's own call — all must share one sign-in.
      await Future.wait<void>(<Future<void>>[
        notifier.ensureGuest(),
        notifier.ensureGuest(),
        notifier.ensureGuest(),
      ]);
      await _settleBootstrap(c);

      expect(c.read(authSessionProvider).kind, AuthKind.guest);
      expect(fake.callsTo('POST', '/api/v1/auth/guest'), 1);
    },
  );
}
