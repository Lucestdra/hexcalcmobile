import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/presentation/gameplay_screen_v2.dart';
import 'package:hexcalc/features/gameplay/presentation/run_result_screen.dart';

import '../support/harness.dart';

void main() {
  testWidgets('v2 Time Attack finishes and routes a target-aware result', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    RunResultData? result;
    final GoRouter router = GoRouter(
      initialLocation: '/play-v2',
      routes: <RouteBase>[
        GoRoute(
          path: '/play-v2',
          builder: (_, _) => const GameplayScreenV2(
            config: GameSessionConfig(
              protocol: GameplayProtocolRef.targetSwipeV2,
              mode: V2GameMode.timeAttack,
              seed: 'finish-v2',
              mapId: 'open-hex',
              durationMs: 300,
            ),
          ),
        ),
        GoRoute(
          path: '/result',
          builder: (_, GoRouterState state) {
            result = state.extra! as RunResultData;
            return const Scaffold(body: Text('V2_RESULT_SENTINEL'));
          },
        ),
      ],
    );
    await tester.pumpWidget(
      await testScope(child: MaterialApp.router(routerConfig: router)),
    );

    for (
      int i = 0;
      i < 30 && find.text('V2_RESULT_SENTINEL').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('V2_RESULT_SENTINEL'), findsOneWidget);
    expect(result!.targetsSolved, 0);
    expect(result!.mapName, 'Open Hex');
    expect(result!.modeId, 'timeAttack');
  });
}
