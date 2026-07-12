import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/features/authentication/login_screen.dart';
import 'package:hexcalc/features/authentication/widgets/auth_widgets.dart';

import '../../support/fake_http_adapter.dart';

void main() {
  Future<void> pumpLogin(WidgetTester tester, FakeHttpAdapter fake) async {
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
        ],
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
  }

  testWidgets('renders the sign-in form', (WidgetTester tester) async {
    await pumpLogin(tester, FakeHttpAdapter());
    expect(find.widgetWithText(ElevatedButton, 'Sign in'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Create account'), findsOneWidget);
    expect(find.text('Forgot password?'), findsOneWidget);
  });

  testWidgets('invalid credentials show an error banner', (
    WidgetTester tester,
  ) async {
    final FakeHttpAdapter fake = FakeHttpAdapter();
    fake.on(
      'POST',
      '/api/v1/auth/login',
      (_) => FakeResponse.json(401, <String, dynamic>{
        'status': 401,
        'code': 'auth.invalid_credentials',
        'detail': 'Email or password is incorrect.',
      }),
    );
    await pumpLogin(tester, fake);

    await tester.enterText(find.byType(TextField).at(0), 'nobody@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(AuthErrorBanner), findsOneWidget);
    expect(find.text('Email or password is incorrect.'), findsOneWidget);
  });
}
