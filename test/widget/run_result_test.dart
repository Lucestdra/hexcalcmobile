import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/features/gameplay/presentation/run_result_screen.dart';

void main() {
  testWidgets('result screen shows the final score and stats', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/result',
      routes: <RouteBase>[
        GoRoute(
          path: '/result',
          builder: (_, _) => const RunResultScreen(
            data: RunResultData(
              score: 2460,
              equationsSolved: 14,
              bestCombo: 7,
              level: 2,
            ),
          ),
        ),
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
        GoRoute(
          path: '/play',
          builder: (_, _) => const Scaffold(body: Text('play')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('2460'), findsOneWidget);
    expect(find.text('14'), findsOneWidget); // equations
    expect(find.text('x7'), findsOneWidget); // best combo
    expect(find.text('3'), findsOneWidget); // level reached (level 2 + 1)
    expect(find.text('Play again'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });
}
