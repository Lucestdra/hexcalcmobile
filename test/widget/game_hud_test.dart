import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_phase.dart';
import 'package:hexcalc/features/gameplay/application/game_snapshot.dart';
import 'package:hexcalc/features/gameplay/presentation/game_hud.dart';

Widget host(GameSnapshot s) => MaterialApp(
  home: Scaffold(
    body: GameHud(snapshot: s, onPause: () {}),
  ),
);

GameSnapshot snapshotWith({
  int score = 0,
  int combo = 0,
  bool fever = false,
  int feverEnergy = 0,
  int target = 12,
}) {
  return GameSnapshot(
    phase: fever ? GamePhase.feverActive : GamePhase.idle,
    score: score,
    timeRemainingMs: 42000,
    comboCount: combo,
    feverActive: fever,
    feverEnergy: feverEnergy,
    feverThreshold: 8,
    level: 0,
    equationsThisLevel: 1,
    equationsRequiredThisLevel: 5,
    target: target,
    pathLength: 0,
    lastEquationCorrect: null,
    equationsSolved: 0,
    bestCombo: 0,
  );
}

void main() {
  testWidgets('HUD shows score, target, and time', (WidgetTester tester) async {
    await tester.pumpWidget(host(snapshotWith(score: 1234, target: 27)));
    expect(find.text('1234'), findsOneWidget);
    expect(find.text('27'), findsOneWidget);
    expect(find.text('42'), findsOneWidget); // 42 s remaining
  });

  testWidgets('combo pill appears at combo >= 2', (WidgetTester tester) async {
    await tester.pumpWidget(host(snapshotWith(combo: 3)));
    expect(find.text('COMBO x3'), findsOneWidget);
  });

  testWidgets('fever pill replaces the meter during Fever', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(snapshotWith(fever: true)));
    expect(find.text('FEVER'), findsOneWidget);
  });

  testWidgets('fever meter shows energy progress before Fever', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(host(snapshotWith(feverEnergy: 3)));
    expect(find.text('FEVER 3/8'), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });
}
