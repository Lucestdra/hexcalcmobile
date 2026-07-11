import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hexcalc/core/design_system/design_system.dart';
import 'package:hexcalc/features/gameplay/presentation/run_result_screen.dart';

void main() {
  testWidgets('run result golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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
        GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink()),
        GoRoute(path: '/play', builder: (_, _) => const SizedBox.shrink()),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: AppTypography.uiFamily,
          scaffoldBackgroundColor: AppColors.background,
        ),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(RunResultScreen),
      matchesGoldenFile('goldens/run_result.png'),
    );
  });
}
