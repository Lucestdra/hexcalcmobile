import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/design_system/design_system.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_providers.dart';
import 'package:hexcalc/features/leaderboard/presentation/leaderboard_screen.dart';

import '../support/leaderboard_fixtures.dart';

void main() {
  testWidgets('leaderboard content golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          weeklyLeaderboardProvider.overrideWith(
            (ref) async => contentRankedBelowTop(),
          ),
          pendingRankedCountProvider.overrideWith(
            (ref) => Stream<int>.value(0),
          ),
          analyticsProvider.overrideWithValue(const NoopAnalytics()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: AppTypography.uiFamily,
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: const LeaderboardScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(LeaderboardScreen),
      matchesGoldenFile('goldens/leaderboard_content.png'),
    );
  });
}
