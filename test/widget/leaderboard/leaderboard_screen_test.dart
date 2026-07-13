import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/core/analytics/analytics_service.dart';
import 'package:hexcalc/core/errors/app_error.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_providers.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_repository.dart';
import 'package:hexcalc/features/leaderboard/presentation/leaderboard_screen.dart';

import '../../support/leaderboard_fixtures.dart';

/// Mounts the leaderboard screen with the data provider forced to a given async
/// outcome (data, thrown error, or never-completing loading) and a controllable
/// pending-count. Analytics is stubbed (the screen logs leaderboard_viewed).
Future<void> _pump(
  WidgetTester tester, {
  LeaderboardData? data,
  Object? error,
  bool loading = false,
  int pending = 0,
}) async {
  await tester.binding.setSurfaceSize(const Size(400, 720));
  addTearDown(() => tester.binding.setSurfaceSize(null));

  final dataOverride = loading
      ? weeklyLeaderboardProvider.overrideWith(
          (ref) => Completer<LeaderboardData>().future,
        )
      : error != null
      ? weeklyLeaderboardProvider.overrideWith((ref) async => throw error)
      : weeklyLeaderboardProvider.overrideWith((ref) async => data!);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dataOverride,
        pendingRankedCountProvider.overrideWith(
          (ref) => Stream<int>.value(pending),
        ),
        analyticsProvider.overrideWithValue(const NoopAnalytics()),
      ],
      child: const MaterialApp(home: LeaderboardScreen()),
    ),
  );
}

void main() {
  testWidgets('loading shows a spinner', (WidgetTester tester) async {
    await _pump(tester, loading: true);
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('content shows the top list and the player rank', (
    WidgetTester tester,
  ) async {
    await _pump(tester, data: contentData());
    await tester.pumpAndSettle();

    expect(find.text('TOP 100'), findsOneWidget);
    expect(find.text('Ada'), findsOneWidget);
    expect(find.text('YOU'), findsWidgets); // you-card label + the row tag
    expect(find.text('#3'), findsOneWidget); // my rank in the you-card
    // A player already in the top page is not duplicated in an "around you" list.
    expect(find.text('AROUND YOU'), findsNothing);
  });

  testWidgets(
    'a player ranked below the top page gets an "around you" window',
    (WidgetTester tester) async {
      await _pump(tester, data: contentRankedBelowTop());
      await tester.pumpAndSettle();

      expect(find.text('AROUND YOU'), findsOneWidget);
      expect(find.text('You'), findsWidgets); // the windowed row for the player
      expect(find.text('#12'), findsOneWidget); // rank in the you-card
      expect(find.text('TOP 100'), findsOneWidget);
    },
  );

  testWidgets('window rows overlapping the top page are not duplicated', (
    WidgetTester tester,
  ) async {
    await _pump(tester, data: contentWindowOverlappingTop());
    await tester.pumpAndSettle();

    expect(find.text('AROUND YOU'), findsOneWidget);
    expect(find.text('You'), findsWidgets); // rank 6, in the window
    // Ranks 4 and 5 (Del, Eve) are in BOTH the raw window and the top list;
    // they must render once (in TOP 100), not twice.
    expect(find.text('Del'), findsOneWidget);
    expect(find.text('Eve'), findsOneWidget);
  });

  testWidgets('empty shows the no-scores state', (WidgetTester tester) async {
    await _pump(tester, data: emptyData());
    await tester.pumpAndSettle();

    expect(find.text('No verified scores yet this week'), findsOneWidget);
  });

  testWidgets('offline-cached shows the saved-standings banner', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      data: contentData(source: LeaderboardSource.cached, cachedAtMs: 1000),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Saved standings'), findsOneWidget);
    expect(find.text('Ada'), findsWidgets); // still shows the cached list
  });

  testWidgets('offline with no cache shows the offline state + retry', (
    WidgetTester tester,
  ) async {
    await _pump(tester, error: const NetworkError());
    await tester.pumpAndSettle();

    expect(find.text('You\'re offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('a server error shows a recoverable error + retry', (
    WidgetTester tester,
  ) async {
    await _pump(tester, error: const ServerError());
    await tester.pumpAndSettle();

    expect(find.text('Couldn\'t load the leaderboard'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('pending ranked runs are marked distinctly', (
    WidgetTester tester,
  ) async {
    await _pump(tester, data: contentData(), pending: 2);
    await tester.pumpAndSettle();

    expect(find.textContaining('awaiting verification'), findsOneWidget);
  });
}
