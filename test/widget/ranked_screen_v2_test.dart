import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/api/hexcalc_api.dart';
import 'package:hexcalc/core/auth/auth_session.dart';
import 'package:hexcalc/core/auth/token_store.dart';
import 'package:hexcalc/core/networking/api_client.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/presentation/ranked_run_config.dart';
import 'package:hexcalc/features/gameplay/presentation/ranked_screen.dart';

import '../support/fake_http_adapter.dart';
import '../support/harness.dart';

void main() {
  testWidgets(
    'adapts a server-issued v2 Ranked challenge into gameplay config',
    (WidgetTester tester) async {
      final FakeHttpAdapter fake = FakeHttpAdapter()
        ..on(
          'GET',
          '/api/v1/meta/config',
          (_) => FakeResponse.json(200, <String, dynamic>{
            'protocolVersion': 'target-swipe-v2',
            'rulesetVersion': 'rs-v2',
            'generatorVersion': 'gen-v2',
            'payloadVersion': 2,
            'runDurationMs': 60000,
            'mapCatalogVersion': 'maps-v1',
            'mapCatalogHash': 'hash-map',
            'modeCatalogVersion': 'modes-v1',
            'modeCatalogHash': 'hash-mode',
            'ruleset': <String, dynamic>{},
          }),
        )
        ..on(
          'POST',
          '/api/v1/game-runs',
          (_) => FakeResponse.json(201, <String, dynamic>{
            'runId': '11111111-1111-1111-1111-111111111111',
            'mode': 'ranked',
            'seed': 'ranked-v2-seed',
            'rulesetVersion': 'rs-v2',
            'generatorVersion': 'gen-v2',
            'runDurationMs': 60000,
            'nonce': 'n1',
            'issuedAtUtc': '2026-07-13T12:00:00Z',
            'expiresAtUtc': '2026-07-13T12:05:00Z',
            'challengeToken': 'signed-v2-token',
            'protocolVersion': 'target-swipe-v2',
            'payloadVersion': 2,
            'mapCatalogVersion': 'maps-v1',
            'mapId': 'crossroads',
            'modeCatalogVersion': 'modes-v1',
            'modeId': 'ranked',
          }),
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
      Object? routedExtra;
      final GoRouter router = GoRouter(
        initialLocation: '/ranked',
        routes: <RouteBase>[
          GoRoute(path: '/ranked', builder: (_, _) => const RankedScreen()),
          GoRoute(
            path: '/play-ranked',
            builder: (_, GoRouterState state) {
              routedExtra = state.extra;
              return const Scaffold(body: Text('V2_PLAY_SENTINEL'));
            },
          ),
          GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            rulesetProvider.overrideWithValue(loadTestRuleset()),
            gameplayCatalogHashesV2Provider.overrideWithValue(
              const GameplayCatalogHashesV2(
                mapCatalogHash: 'hash-map',
                modeCatalogHash: 'hash-mode',
              ),
            ),
            hexcalcApiProvider.overrideWithValue(api),
            analyticsProvider.overrideWithValue(const NoopAnalytics()),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ranked run ready'), findsOneWidget);

      await tester.tap(find.text('START RANKED RUN'));
      await tester.pumpAndSettle();

      expect(find.text('V2_PLAY_SENTINEL'), findsOneWidget);
      final RankedRunConfig config = routedExtra! as RankedRunConfig;
      expect(config.isTargetSwipeV2, isTrue);
      expect(config.mapId, 'crossroads');
      expect(config.modeId, 'ranked');
      expect(config.payloadVersion, 2);
    },
  );
}
