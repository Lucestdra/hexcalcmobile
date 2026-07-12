import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/api/dtos.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/core/networking/refresh_coordinator.dart';

void main() {
  AuthTokenSet seeded() =>
      const AuthTokenSet(accessToken: 'a', refreshToken: 'r', userId: 'u');

  AuthTokens issued(int n) => AuthTokens(
    accessToken: 'access-$n',
    refreshToken: 'refresh-$n',
    tokenType: 'Bearer',
    expiresInSeconds: 900,
    userId: 'u',
  );

  test(
    'concurrent refreshes trigger exactly one network call (single-flight)',
    () async {
      final InMemoryTokenStore store = InMemoryTokenStore();
      await store.write(seeded());
      int calls = 0;
      final RefreshCoordinator coordinator = RefreshCoordinator(
        store: store,
        performRefresh: (String _) async {
          calls++;
          await Future<void>.delayed(const Duration(milliseconds: 20));
          return issued(calls);
        },
      );

      final List<RefreshOutcome> outcomes = await Future.wait<RefreshOutcome>(
        List<Future<RefreshOutcome>>.generate(12, (_) => coordinator.refresh()),
      );

      expect(calls, 1);
      expect(coordinator.networkRefreshCount, 1);
      expect(outcomes, everyElement(RefreshOutcome.refreshed));
      expect((await store.read())!.accessToken, 'access-1');
    },
  );

  test('a later refresh after one completes starts a fresh call', () async {
    final InMemoryTokenStore store = InMemoryTokenStore();
    await store.write(seeded());
    int calls = 0;
    final RefreshCoordinator coordinator = RefreshCoordinator(
      store: store,
      performRefresh: (String _) async {
        calls++;
        return issued(calls);
      },
    );

    expect(await coordinator.refresh(), RefreshOutcome.refreshed);
    expect(await coordinator.refresh(), RefreshOutcome.refreshed);
    expect(calls, 2);
  });

  test('no stored token yields signedOut without a network call', () async {
    final RefreshCoordinator coordinator = RefreshCoordinator(
      store: InMemoryTokenStore(),
      performRefresh: (String _) async => fail('should not be called'),
    );

    expect(await coordinator.refresh(), RefreshOutcome.signedOut);
    expect(coordinator.networkRefreshCount, 0);
  });

  test('a rejected refresh signs out and clears the stored tokens', () async {
    final InMemoryTokenStore store = InMemoryTokenStore();
    await store.write(seeded());
    final RefreshCoordinator coordinator = RefreshCoordinator(
      store: store,
      performRefresh: (String _) async =>
          throw const UnauthorizedError(message: 'reused'),
    );

    expect(await coordinator.refresh(), RefreshOutcome.signedOut);
    expect(await store.read(), isNull);
  });

  test('an offline refresh keeps the tokens for a later retry', () async {
    final InMemoryTokenStore store = InMemoryTokenStore();
    await store.write(seeded());
    final RefreshCoordinator coordinator = RefreshCoordinator(
      store: store,
      performRefresh: (String _) async => throw const NetworkError(),
    );

    expect(await coordinator.refresh(), RefreshOutcome.offline);
    expect(await store.read(), isNotNull);
  });

  test(
    'a transient server error (5xx) keeps the tokens, does not sign out',
    () async {
      final InMemoryTokenStore store = InMemoryTokenStore();
      await store.write(seeded());
      final RefreshCoordinator coordinator = RefreshCoordinator(
        store: store,
        performRefresh: (String _) async => throw const ServerError(),
      );

      expect(await coordinator.refresh(), RefreshOutcome.offline);
      expect(await store.read(), isNotNull);
    },
  );

  test('a rate-limited refresh (429) keeps the tokens', () async {
    final InMemoryTokenStore store = InMemoryTokenStore();
    await store.write(seeded());
    final RefreshCoordinator coordinator = RefreshCoordinator(
      store: store,
      performRefresh: (String _) async => throw const RateLimitedError(),
    );

    expect(await coordinator.refresh(), RefreshOutcome.offline);
    expect(await store.read(), isNotNull);
  });
}
