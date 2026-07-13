import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/api/dtos.dart';
import 'package:hexcalc/core/api/hexcalc_api.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/features/daily_challenge/application/daily_challenge_providers.dart';
import 'package:hexcalc/features/daily_challenge/presentation/daily_challenge_screen.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import '../../support/fake_http_adapter.dart';
import '../../support/harness.dart';

DailyChallengeView _card({
  bool attempted = false,
  required String ruleset,
  String? generator,
}) => DailyChallengeView(
  challengeDateUtc: DateTime.utc(2026, 7, 13),
  windowStartUtc: DateTime.utc(2026, 7, 13),
  windowEndUtc: DateTime.utc(2026, 7, 14),
  rulesetVersion: ruleset,
  generatorVersion: generator ?? BoardGeneratorV1.generatorVersion,
  attempted: attempted,
  asOfUtc: DateTime.utc(2026, 7, 13, 12),
);

void main() {
  late Ruleset ruleset;
  late String rulesetVersion;

  setUp(() {
    ruleset = loadTestRuleset();
    rulesetVersion = ruleset.rulesetVersion;
  });

  // ── State rendering (card provider overridden) ─────────────────────────────

  Future<void> pumpCard(
    WidgetTester tester, {
    DailyChallengeView? card,
    Object? error,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final cardOverride = error != null
        ? dailyChallengeProvider.overrideWith((ref) async => throw error)
        : dailyChallengeProvider.overrideWith((ref) async => card!);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cardOverride,
          rulesetProvider.overrideWithValue(ruleset),
          analyticsProvider.overrideWithValue(const NoopAnalytics()),
        ],
        child: const MaterialApp(home: DailyChallengeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('an unplayed challenge shows the play card', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, card: _card(ruleset: rulesetVersion));
    expect(find.text('START DAILY RUN'), findsOneWidget);
    expect(find.text('Today\'s challenge'), findsOneWidget);
  });

  testWidgets('an already-attempted challenge shows the played state', (
    WidgetTester tester,
  ) async {
    await pumpCard(
      tester,
      card: _card(ruleset: rulesetVersion, attempted: true),
    );
    expect(find.text('Played today'), findsOneWidget);
    expect(find.text('START DAILY RUN'), findsNothing);
  });

  testWidgets('offline shows the offline state + retry', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, error: const NetworkError());
    expect(find.text('You\'re offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('an unsupported ruleset blocks with update-required', (
    WidgetTester tester,
  ) async {
    await pumpCard(tester, card: _card(ruleset: 'rs-v999'));
    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('START DAILY RUN'), findsNothing);
  });

  // ── Attempt flow (real api over a fake adapter + a router) ──────────────────

  Future<FakeHttpAdapter> pumpAttempt(
    WidgetTester tester, {
    required FakeHandler attemptHandler,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final FakeHttpAdapter fake = FakeHttpAdapter();
    fake.on(
      'POST',
      '/api/v1/daily-challenges/current/attempts',
      attemptHandler,
    );
    final InMemoryTokenStore tokens = InMemoryTokenStore();
    await tokens.write(
      const AuthTokenSet(accessToken: 'a', refreshToken: 'r', userId: 'u'),
    );
    final HexcalcApi api = HexcalcApi(
      ApiClient(
        baseUrl: 'http://test.local',
        tokenStore: tokens,
        dioBuilder: fakeDioBuilder(fake),
      ),
    );

    final GoRouter router = GoRouter(
      initialLocation: '/daily',
      routes: <RouteBase>[
        GoRoute(
          path: '/daily',
          builder: (_, _) => const DailyChallengeScreen(),
        ),
        GoRoute(
          path: '/play-ranked',
          builder: (_, _) => const Scaffold(body: Text('PLAY_RANKED_SENTINEL')),
        ),
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(
          path: '/leaderboard',
          builder: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyChallengeProvider.overrideWith(
            (ref) async => _card(ruleset: rulesetVersion),
          ),
          rulesetProvider.overrideWithValue(ruleset),
          hexcalcApiProvider.overrideWithValue(api),
          analyticsProvider.overrideWithValue(const NoopAnalytics()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return fake;
  }

  Map<String, dynamic> attemptBody() => <String, dynamic>{
    'runId': '11111111-1111-1111-1111-111111111111',
    'mode': 'daily',
    'seed': 'seed-1',
    'rulesetVersion': rulesetVersion,
    'generatorVersion': BoardGeneratorV1.generatorVersion,
    'runDurationMs': 60000,
    'nonce': 'n1',
    'issuedAtUtc': '2026-07-13T12:00:00Z',
    'expiresAtUtc': '2026-07-13T12:05:00Z',
    'challengeToken': 'tok-1',
  };

  testWidgets('starting an attempt issues a run and enters gameplay', (
    WidgetTester tester,
  ) async {
    await pumpAttempt(
      tester,
      attemptHandler: (_) => FakeResponse.json(200, attemptBody()),
    );

    await tester.tap(find.text('START DAILY RUN'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY_RANKED_SENTINEL'), findsOneWidget);
  });

  testWidgets('a 409 (already completed) is messaged, not a crash', (
    WidgetTester tester,
  ) async {
    await pumpAttempt(
      tester,
      attemptHandler: (_) => FakeResponse.json(409, <String, dynamic>{
        'code': 'daily.already_completed',
        'status': 409,
        'detail': 'Already completed.',
      }),
    );

    await tester.tap(find.text('START DAILY RUN'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY_RANKED_SENTINEL'), findsNothing);
    expect(find.textContaining('already played'), findsOneWidget);
  });

  testWidgets('an offline start is messaged honestly', (
    WidgetTester tester,
  ) async {
    await pumpAttempt(
      tester,
      attemptHandler: (_) => throw DioException(
        requestOptions: RequestOptions(path: '/'),
        type: DioExceptionType.connectionError,
      ),
    );

    await tester.tap(find.text('START DAILY RUN'));
    await tester.pumpAndSettle();

    expect(find.text('PLAY_RANKED_SENTINEL'), findsNothing);
    expect(find.textContaining('offline'), findsOneWidget);
  });
}
