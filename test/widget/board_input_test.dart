import 'dart:convert';
import 'dart:io';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/features/gameplay/flame/hex_board_game.dart';
import 'package:hexcalc/features/gameplay/flame/hex_metrics.dart';

Ruleset loadRs1() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

void main() {
  testWidgets(
    'dragging along a solution path over the Flame board scores an equation',
    (WidgetTester tester) async {
      const Size surface = Size(400, 600);
      await tester.binding.setSurfaceSize(surface);
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final GameController controller = GameController(
        ruleset: loadRs1(),
        seed: 'alpha',
      )..startRun();
      final HexBoardGame game = HexBoardGame(controller);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (DragStartDetails d) => game.pressAt(d.localPosition),
              onPanUpdate: (DragUpdateDetails d) =>
                  game.extendAt(d.localPosition),
              onPanEnd: (DragEndDetails d) => game.release(),
              child: GameWidget(game: game),
            ),
          ),
        ),
      );

      // Let the Flame game mount and compute its metrics from the surface size.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 16));

      final HexMetrics metrics = HexMetrics.fit(surface, 2);
      final List<AxialCoordinate> path = controller.board.sampleSolutions.first;

      final TestGesture gesture = await tester.startGesture(
        metrics.centerOf(path.first),
      );
      await tester.pump();
      for (int i = 1; i < path.length; i++) {
        await gesture.moveTo(metrics.centerOf(path[i]));
        await tester.pump();
      }
      await gesture.up();
      await tester.pump();

      expect(controller.notifier.value.equationsSolved, 1);
      expect(controller.notifier.value.score, greaterThan(0));
    },
  );
}
