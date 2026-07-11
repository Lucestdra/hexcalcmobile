import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller.dart';
import 'package:hexcalc/features/gameplay/application/game_event.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import '../support/harness.dart';

void main() {
  final Ruleset rs1 = loadTestRuleset();

  test('startRun emits runStarted', () {
    final List<GameSignal> seen = <GameSignal>[];
    GameController(
      ruleset: rs1,
      seed: 'alpha',
      onEvent: (GameEvent e) => seen.add(e.signal),
    ).startRun();
    expect(seen, contains(GameSignal.runStarted));
  });

  test('a solved equation emits cellSelected then equationCorrect', () {
    final List<GameEvent> seen = <GameEvent>[];
    final GameController c = GameController(
      ruleset: rs1,
      seed: 'alpha',
      onEvent: seen.add,
    )..startRun();

    final List<AxialCoordinate> sol = c.board.sampleSolutions.first;
    c.pressCell(sol.first);
    for (int i = 1; i < sol.length; i++) {
      c.extendToCell(sol[i]);
    }
    c.release();

    expect(
      seen.where((GameEvent e) => e.signal == GameSignal.cellSelected).length,
      sol.length,
    );
    final GameEvent correct = seen.firstWhere(
      (GameEvent e) => e.signal == GameSignal.equationCorrect,
    );
    // The committed cells travel with the event for the choreography.
    expect(correct.cells, sol);
  });

  test('the run end emits runFinished exactly once', () {
    int finishes = 0;
    final GameController c = GameController(
      ruleset: rs1,
      seed: 'alpha',
      onEvent: (GameEvent e) {
        if (e.signal == GameSignal.runFinished) {
          finishes++;
        }
      },
    )..startRun();

    // Drive well past the run duration.
    for (int i = 0; i < 80; i++) {
      c.tick(1000);
    }
    expect(finishes, 1);
  });
}
