import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/features/gameplay/persistence/app_database.dart';
import 'package:hexcalc/features/gameplay/persistence/run_history_repository.dart';
import 'package:hexcalc/features/home/home_screen.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_providers.dart';

/// Home reads the two run-history stream providers plus the best-effort weekly
/// rank teaser. Overriding them keeps the widget test decoupled from Drift and
/// the network. [rank] drives the teaser (null → the neutral "View").
Widget _home({
  RunStats stats = RunStats.empty,
  List<RunSummary> recent = const <RunSummary>[],
  int? rank,
}) {
  return ProviderScope(
    overrides: [
      runStatsProvider.overrideWith((ref) => Stream<RunStats>.value(stats)),
      recentRunsProvider.overrideWith(
        (ref) => Stream<List<RunSummary>>.value(recent),
      ),
      weeklyRankTeaserProvider.overrideWith((ref) async => rank),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets(
    'home shows personal best 0 and an empty-history hint initially',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 720));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(_home());
      await tester.pumpAndSettle();

      expect(find.text('PERSONAL BEST'), findsOneWidget);
      expect(find.text('PLAY'), findsOneWidget);
      expect(find.text('No runs yet — play one!'), findsOneWidget);
    },
  );

  testWidgets('home shows the personal best and recent runs when present', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _home(
        stats: const RunStats(personalBest: 1840, totalRuns: 3, bestCombo: 6),
        recent: const <RunSummary>[
          RunSummary(
            playedAtMs: 2000,
            mode: 'normal',
            score: 1840,
            equations: 11,
            bestCombo: 6,
            levelReached: 2,
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('1840'), findsWidgets); // personal best + the run row
    expect(find.text('RECENT RUNS'), findsOneWidget);
    expect(find.text('11 eq · x6'), findsOneWidget);
  });

  testWidgets('home has ranked, daily, and a rank teaser', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_home(rank: 7));
    await tester.pumpAndSettle();

    expect(find.text('RANKED'), findsOneWidget);
    expect(find.text('DAILY'), findsOneWidget);
    expect(find.text('WEEKLY RANK'), findsOneWidget);
    expect(find.text('#7'), findsOneWidget);
  });

  testWidgets('the rank teaser shows "View" when there is no rank', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(_home());
    await tester.pumpAndSettle();

    expect(find.text('WEEKLY RANK'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
  });
}
