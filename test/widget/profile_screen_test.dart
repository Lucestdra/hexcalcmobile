import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/features/authentication/widgets/auth_widgets.dart';
import 'package:hexcalc/features/profile/profile_screen.dart';

import '../support/fake_http_adapter.dart';

/// A ready guest session with no async work.
class _GuestSession extends AuthSessionNotifier {
  @override
  AuthState build() =>
      const AuthState(kind: AuthKind.guest, userId: 'guest-test');
}

void main() {
  Future<void> pumpProfile(WidgetTester tester, FakeHttpAdapter fake) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apiBaseUrlProvider.overrideWithValue('http://test.local'),
          tokenStoreProvider.overrideWithValue(InMemoryTokenStore()),
          apiClientProvider.overrideWith(
            (ref) => ApiClient(
              baseUrl: ref.read(apiBaseUrlProvider),
              tokenStore: ref.read(tokenStoreProvider),
              dioBuilder: fakeDioBuilder(fake),
            ),
          ),
          authSessionProvider.overrideWith(_GuestSession.new),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
  }

  testWidgets('guest profile shows the guest actions', (
    WidgetTester tester,
  ) async {
    final FakeHttpAdapter fake = FakeHttpAdapter();
    fake.on(
      'GET',
      '/api/v1/players/me',
      (_) => FakeResponse.json(200, <String, dynamic>{
        'id': 'guest-test',
        'displayName': 'Player-ABCDEF',
        'locale': 'en',
        'status': 'Active',
        'createdAtUtc': '2026-01-01T00:00:00Z',
      }),
    );
    await pumpProfile(tester, fake);
    await tester.pumpAndSettle();

    expect(find.text('Link an account'), findsOneWidget);
    expect(find.text('Player-ABCDEF'), findsOneWidget);
  });

  testWidgets('a failed profile fetch shows an error with retry', (
    WidgetTester tester,
  ) async {
    final FakeHttpAdapter fake = FakeHttpAdapter();
    fake.on(
      'GET',
      '/api/v1/players/me',
      (_) => FakeResponse.json(500, <String, dynamic>{'status': 500}),
    );
    await pumpProfile(tester, fake);
    await tester.pumpAndSettle();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    // The session actions are still available.
    expect(find.text('Link an account'), findsOneWidget);
  });
}
