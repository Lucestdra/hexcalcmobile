import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/run_history_repository.dart';
import 'package:hexcalc/features/home/home_screen.dart';
import 'package:hexcalc/features/onboarding/data/onboarding_store.dart';

import '../../support/harness.dart';

void main() {
  Future<void> pumpHome(
    WidgetTester tester, {
    required OnboardingStore store,
    RecordingAnalytics? analytics,
  }) async {
    await tester.binding.setSurfaceSize(const Size(400, 780));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      await testScope(
        child: const MaterialApp(home: HomeScreen()),
        analytics: analytics,
        onboardingStore: store,
        homeStats: RunStats.empty,
        homeRecent: const <RunSummary>[],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('first launch shows the onboarding overlay over home', (
    WidgetTester tester,
  ) async {
    final RecordingAnalytics analytics = RecordingAnalytics();
    await pumpHome(
      tester,
      store: InMemoryOnboardingStore(seen: false),
      analytics: analytics,
    );

    expect(find.text('HOW TO PLAY'), findsOneWidget);
    expect(find.text('GOT IT'), findsOneWidget);
    expect(analytics.contains('onboarding_started'), isTrue);
  });

  testWidgets('dismissing marks it seen, hides it, and logs completion', (
    WidgetTester tester,
  ) async {
    final InMemoryOnboardingStore store = InMemoryOnboardingStore(seen: false);
    final RecordingAnalytics analytics = RecordingAnalytics();
    await pumpHome(tester, store: store, analytics: analytics);

    await tester.tap(find.text('GOT IT'));
    await tester.pumpAndSettle();

    expect(find.text('HOW TO PLAY'), findsNothing);
    expect(find.text('PLAY'), findsOneWidget); // home is now interactive
    expect(store.hasSeenOnboarding(), isTrue);
    expect(analytics.contains('onboarding_completed'), isTrue);
  });

  testWidgets('a returning player sees no onboarding overlay', (
    WidgetTester tester,
  ) async {
    await pumpHome(tester, store: InMemoryOnboardingStore(seen: true));

    expect(find.text('HOW TO PLAY'), findsNothing);
    expect(find.text('PLAY'), findsOneWidget);
  });

  testWidgets('home exposes accessible semantics for its key values', (
    WidgetTester tester,
  ) async {
    final SemanticsHandle handle = tester.ensureSemantics();
    await pumpHome(tester, store: InMemoryOnboardingStore(seen: true));

    // The personal-best card reads as one labelled value (not two loose texts).
    expect(find.bySemanticsLabel(RegExp('Personal best')), findsOneWidget);

    handle.dispose();
  });
}
