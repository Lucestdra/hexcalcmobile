import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_phase.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/application/game_snapshot_v2.dart';
import 'package:hexcalc/features/gameplay/presentation/game_hud_v2.dart';

GameSnapshotV2 snapshot({int? timeRemainingMs = 42000}) => GameSnapshotV2(
  phase: GamePhase.selecting,
  mode: timeRemainingMs == null ? V2GameMode.endless : V2GameMode.timeAttack,
  mapId: 'open-hex',
  mapName: 'Open Hex',
  score: 1234,
  timeRemainingMs: timeRemainingMs,
  comboCount: 3,
  feverActive: false,
  feverEnergy: 2,
  feverThreshold: 8,
  target: 13,
  expression: '3 + 5 × 2',
  pathLength: 5,
  boardRevision: 2,
  targetsSolved: 4,
  targetQuota: timeRemainingMs == null ? null : 6,
  bestCombo: 3,
  rating: null,
  levelCompleted: false,
  lastChainCorrect: true,
);

void main() {
  testWidgets('shows target, live expression, and Level-style progress', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHudV2(snapshot: snapshot(), onPause: () {}),
        ),
      ),
    );

    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('13'), findsOneWidget);
    expect(find.text('3 + 5 × 2'), findsOneWidget);
    expect(find.text('4/6 TARGETS'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
  });

  testWidgets('Endless shows infinity and solved count without a timer', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GameHudV2(
            snapshot: snapshot(timeRemainingMs: null),
            onPause: () {},
          ),
        ),
      ),
    );

    expect(find.text('∞'), findsOneWidget);
    expect(find.text('4 SOLVED'), findsOneWidget);
    expect(find.text('TIME'), findsNothing);
  });
}
