import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/app.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart'
    show RunStats;

import '../support/harness.dart';

void main() {
  testWidgets('home shows the wordmark and PLAY starts a run', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await testScope(
        // Finite home streams so no live drift query lingers past teardown.
        homeStats: RunStats.empty,
        homeRecent: const [],
        child: const HexCalcApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('HEX • CALC'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();
    expect(find.text('CHOOSE MODE'), findsOneWidget);

    await tester.tap(find.text('Time Attack'));
    // Do NOT pumpAndSettle: the Flame game loop schedules frames forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The gameplay HUD is now visible.
    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
  });
}
