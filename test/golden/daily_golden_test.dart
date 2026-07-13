import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/api/dtos.dart';
import 'package:hexcalc/core/design_system/design_system.dart';
import 'package:hexcalc/features/daily_challenge/application/daily_challenge_providers.dart';
import 'package:hexcalc/features/daily_challenge/presentation/daily_challenge_screen.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import '../support/harness.dart';

void main() {
  testWidgets('daily challenge card golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final Ruleset ruleset = loadTestRuleset();
    final DailyChallengeView card = DailyChallengeView(
      challengeDateUtc: DateTime.utc(2026, 7, 13),
      windowStartUtc: DateTime.utc(2026, 7, 13),
      windowEndUtc: DateTime.utc(2026, 7, 14),
      rulesetVersion: ruleset.rulesetVersion,
      generatorVersion: BoardGeneratorV1.generatorVersion,
      attempted: false,
      asOfUtc: DateTime.utc(2026, 7, 13, 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dailyChallengeProvider.overrideWith((ref) async => card),
          rulesetProvider.overrideWithValue(ruleset),
          analyticsProvider.overrideWithValue(const NoopAnalytics()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            fontFamily: AppTypography.uiFamily,
            scaffoldBackgroundColor: AppColors.background,
          ),
          home: const DailyChallengeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(DailyChallengeScreen),
      matchesGoldenFile('goldens/daily_card.png'),
    );
  });
}
