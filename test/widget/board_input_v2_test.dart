import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller_v2.dart';
import 'package:hexcalc/features/gameplay/application/game_session_config.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/features/gameplay/flame/hex_board_game_v2.dart';
import 'package:hexcalc/features/gameplay/flame/hex_metrics.dart';
import 'package:hexcalc/features/gameplay/presentation/single_pointer_swipe_input.dart';

import '../support/harness.dart';

void main() {
  testWidgets('real pointer swipe solves an irregular map with blocked cells', (
    WidgetTester tester,
  ) async {
    const Size surface = Size(400, 600);
    await tester.binding.setSurfaceSize(surface);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final MapDefinitionV2 map = loadTestMapCatalogV1().map('twin-gates');
    final GameControllerV2 controller = GameControllerV2(
      ruleset: loadTestRulesetV2(),
      config: GameSessionConfig(
        protocol: GameplayProtocolRef.targetSwipeV2,
        mode: V2GameMode.timeAttack,
        seed: 'pointer-v2',
        mapId: map.id,
      ),
      map: map,
    )..startRun();
    addTearDown(controller.dispose);
    final HexBoardGameV2 game = HexBoardGameV2(controller);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: <Widget>[
              Positioned.fill(child: GameWidget(game: game)),
              Positioned.fill(
                child: SinglePointerSwipeInput(
                  onDown: game.pressAt,
                  onMove: game.extendAt,
                  onUp: game.release,
                  onCancel: game.cancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final HexMetrics metrics = HexMetrics.fitCoordinates(
      surface,
      map.topology.layoutCoordinates,
      usable: 0.78,
    );
    expect(map.blockedCoordinates, isNotEmpty);

    // A visible blocked cell never begins a chain.
    final TestGesture blocked = await tester.startGesture(
      metrics.centerOf(map.blockedCoordinates.first),
      pointer: 11,
    );
    await blocked.up();
    await tester.pump();
    expect(controller.path, isEmpty);
    expect(controller.loggedEvents, isEmpty);

    final TargetCandidateV2 solution =
        TargetAnalyzerV2.analyze(controller.board).singleWhere(
          (TargetCandidateV2 candidate) =>
              candidate.result == controller.board.target,
        );
    final TestGesture swipe = await tester.startGesture(
      metrics.centerOf(solution.canonicalHintPath.first),
      pointer: 12,
    );
    for (final AxialCoordinate coordinate in solution.canonicalHintPath.skip(
      1,
    )) {
      await swipe.moveTo(metrics.centerOf(coordinate));
      await tester.pump();
    }
    await swipe.up();
    await tester.pump();

    expect(controller.board.revision, 1);
    expect(controller.notifier.value.targetsSolved, 1);
    expect(controller.loggedEvents.single.boardRevision, 0);
  });
}
