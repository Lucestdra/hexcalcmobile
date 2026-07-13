import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/features/gameplay/presentation/mode_selection_screen.dart';

void main() {
  testWidgets('shows every v2 mode and routes Time Attack to play', (
    WidgetTester tester,
  ) async {
    final GoRouter router = GoRouter(
      initialLocation: '/modes',
      routes: <RouteBase>[
        GoRoute(path: '/modes', builder: (_, _) => const ModeSelectionScreen()),
        GoRoute(
          path: '/play-v2',
          builder: (_, _) => const Scaffold(body: Text('v2 game')),
        ),
        for (final String path in <String>[
          '/levels',
          '/endless-maps',
          '/ranked',
          '/daily',
        ])
          GoRoute(
            path: path,
            builder: (_, _) => Scaffold(body: Text(path)),
          ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(find.text('Time Attack'), findsOneWidget);
    expect(find.text('Level Mode'), findsOneWidget);
    expect(find.text('Endless'), findsOneWidget);
    expect(find.text('Ranked'), findsOneWidget);
    expect(find.text('Daily Challenge'), findsOneWidget);

    await tester.tap(find.text('Time Attack'));
    await tester.pumpAndSettle();
    expect(find.text('v2 game'), findsOneWidget);
  });
}
