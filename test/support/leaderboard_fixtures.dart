import 'package:hexcalc/core/api/dtos.dart';
import 'package:hexcalc/features/leaderboard/application/leaderboard_repository.dart';

/// Deterministic leaderboard DTO/data fixtures shared by widget and golden tests.

LeaderboardEntryView entry(
  int rank,
  String name,
  int score, {
  bool mine = false,
}) => LeaderboardEntryView(
  rank: rank,
  playerId: 'p$rank',
  displayName: name,
  score: score,
  achievedAtUtc: DateTime.utc(2026, 7, 7, 10),
  isCurrentPlayer: mine,
);

List<LeaderboardEntryView> sampleTop() => <LeaderboardEntryView>[
  entry(1, 'Ada', 2480),
  entry(2, 'Ben', 2110),
  entry(3, 'Cy', 1990, mine: true),
  entry(4, 'Del', 1750),
  entry(5, 'Eve', 1600),
];

WeeklyLeaderboardResponse weeklyOf(List<LeaderboardEntryView> entries) =>
    WeeklyLeaderboardResponse(
      weekStartUtc: DateTime.utc(2026, 7, 6),
      status: 'open',
      entries: entries,
      nextCursor: null,
      asOfUtc: DateTime.utc(2026, 7, 8, 12),
    );

MyWeeklyRankResponse meRank({
  int? rank = 3,
  int totalPlayers = 5,
  List<LeaderboardEntryView>? window,
}) => MyWeeklyRankResponse(
  weekStartUtc: DateTime.utc(2026, 7, 6),
  status: 'open',
  rank: rank,
  totalPlayers: totalPlayers,
  window: window ?? sampleTop(),
  asOfUtc: DateTime.utc(2026, 7, 8, 12),
);

/// A full content payload (live source).
LeaderboardData contentData({
  LeaderboardSource source = LeaderboardSource.live,
  int? cachedAtMs,
  int? myRank = 3,
}) {
  final List<LeaderboardEntryView> top = sampleTop();
  return LeaderboardData(
    top: weeklyOf(top),
    me: meRank(rank: myRank, window: top),
    source: source,
    cachedAtMs: cachedAtMs,
  );
}

/// A board where the player ranks below the visible top page, so the "around you"
/// ±5 window is additive (not a duplicate of the top rows).
LeaderboardData contentRankedBelowTop() {
  final List<LeaderboardEntryView> top = <LeaderboardEntryView>[
    entry(1, 'Ada', 2480),
    entry(2, 'Ben', 2110),
    entry(3, 'Cy', 1990),
    entry(4, 'Del', 1750),
    entry(5, 'Eve', 1600),
  ];
  final List<LeaderboardEntryView> window = <LeaderboardEntryView>[
    entry(10, 'Jo', 980),
    entry(11, 'Kit', 940),
    entry(12, 'You', 900, mine: true),
    entry(13, 'Mo', 860),
    entry(14, 'Ng', 820),
  ];
  return LeaderboardData(
    top: weeklyOf(top),
    me: meRank(rank: 12, totalPlayers: 40, window: window),
    source: LeaderboardSource.live,
  );
}

/// A board where the player sits just past the top page, so their ±5 window
/// OVERLAPS the top list (window ranks 4–8, top ranks 1–5). Used to prove the
/// overlapping rows (4, 5) are not rendered twice.
LeaderboardData contentWindowOverlappingTop() {
  final List<LeaderboardEntryView> top = <LeaderboardEntryView>[
    entry(1, 'Ada', 2480),
    entry(2, 'Ben', 2110),
    entry(3, 'Cy', 1990),
    entry(4, 'Del', 1750),
    entry(5, 'Eve', 1600),
  ];
  final List<LeaderboardEntryView> window = <LeaderboardEntryView>[
    entry(4, 'Del', 1750),
    entry(5, 'Eve', 1600),
    entry(6, 'You', 1500, mine: true),
    entry(7, 'Fo', 1400),
    entry(8, 'Gu', 1300),
  ];
  return LeaderboardData(
    top: weeklyOf(top),
    me: meRank(rank: 6, totalPlayers: 20, window: window),
    source: LeaderboardSource.live,
  );
}

/// An empty board with no verified scores and no personal rank.
LeaderboardData emptyData() => LeaderboardData(
  top: weeklyOf(<LeaderboardEntryView>[]),
  me: meRank(rank: null, totalPlayers: 0, window: <LeaderboardEntryView>[]),
  source: LeaderboardSource.live,
);
