import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/design_system/design_system.dart';
import 'package:hexcalc/features/gameplay/application/game_phase.dart';
import 'package:hexcalc/features/gameplay/application/game_snapshot.dart';
import 'package:hexcalc/features/gameplay/presentation/game_hud.dart';

Widget _host(GameSnapshot s) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppTypography.uiFamily,
    scaffoldBackgroundColor: AppColors.background,
  ),
  home: Scaffold(
    backgroundColor: AppColors.background,
    // reducedMotion keeps the score static so the golden is deterministic.
    body: GameHud(snapshot: s, onPause: () {}, reducedMotion: true),
  ),
);

GameSnapshot _snap({
  required int score,
  required int combo,
  required bool fever,
  required int feverEnergy,
}) => GameSnapshot(
  phase: fever ? GamePhase.feverActive : GamePhase.idle,
  score: score,
  timeRemainingMs: 42000,
  comboCount: combo,
  feverActive: fever,
  feverEnergy: feverEnergy,
  feverThreshold: 8,
  level: 0,
  equationsThisLevel: 2,
  equationsRequiredThisLevel: 5,
  target: 27,
  pathLength: 0,
  lastEquationCorrect: null,
  equationsSolved: 0,
  bestCombo: 0,
);

void main() {
  testWidgets('HUD idle golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _host(_snap(score: 1280, combo: 3, fever: false, feverEnergy: 5)),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GameHud),
      matchesGoldenFile('goldens/hud_idle.png'),
    );
  });

  testWidgets('HUD fever golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _host(_snap(score: 3120, combo: 6, fever: true, feverEnergy: 8)),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GameHud),
      matchesGoldenFile('goldens/hud_fever.png'),
    );
  });
}
