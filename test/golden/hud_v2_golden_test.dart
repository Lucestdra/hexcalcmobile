import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/design_system/design_system.dart';
import 'package:hexcalc/features/gameplay/application/game_phase.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/application/game_snapshot_v2.dart';
import 'package:hexcalc/features/gameplay/presentation/game_hud_v2.dart';

void main() {
  testWidgets('target-swipe Level HUD golden', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: AppTypography.uiFamily,
          scaffoldBackgroundColor: AppColors.background,
        ),
        home: const Scaffold(
          backgroundColor: AppColors.background,
          body: GameHudV2(
            snapshot: GameSnapshotV2(
              phase: GamePhase.selecting,
              mode: V2GameMode.level,
              mapId: 'inner-wall',
              mapName: 'Inner Wall',
              score: 1240,
              timeRemainingMs: 43000,
              comboCount: 4,
              feverActive: false,
              feverEnergy: 5,
              feverThreshold: 8,
              target: 27,
              expression: '3 + 5 × 2',
              pathLength: 5,
              boardRevision: 3,
              targetsSolved: 5,
              targetQuota: 8,
              bestCombo: 4,
              rating: 0,
              levelCompleted: false,
              lastChainCorrect: true,
            ),
            onPause: _noop,
            reducedMotion: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(GameHudV2),
      matchesGoldenFile('goldens/hud_v2_level.png'),
    );
  });
}

void _noop() {}
