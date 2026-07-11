import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/application/game_controller.dart';
import 'package:hexcalc/features/gameplay/application/game_phase.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

Ruleset loadRs1() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

void drivePath(GameController c, List<AxialCoordinate> path) {
  c.pressCell(path.first);
  for (int i = 1; i < path.length; i++) {
    c.extendToCell(path[i]);
  }
  c.release();
}

/// Advances past any transient feedback phase so the next press is accepted.
void settle(GameController c) => c.tick(600);

void main() {
  final Ruleset rs1 = loadRs1();

  GameController newController([String seed = 'alpha']) =>
      GameController(ruleset: rs1, seed: seed)..startRun();

  test('startRun produces a solvable board in idle', () {
    final GameController c = newController();
    expect(c.board.cells.length, 19);
    expect(c.board.target, greaterThan(0));
    expect(c.phase, GamePhase.idle);
    expect(c.notifier.value.score, 0);
    expect(c.board.sampleSolutions, isNotEmpty);
  });

  test('a valid solution path scores a correct equation', () {
    final GameController c = newController();
    final int target = c.board.target;
    drivePath(c, c.board.sampleSolutions.first);

    expect(c.notifier.value.equationsSolved, 1);
    expect(c.notifier.value.lastEquationCorrect, isTrue);
    expect(c.notifier.value.score, greaterThan(0));
    // sampleSolutions[0] is the first found, not necessarily the target value;
    // the run still scores. Sanity: target is unchanged mid-level.
    expect(c.board.target, target);
  });

  test('press only begins on a number cell', () {
    final GameController c = newController();
    final BoardCell op = c.board.cells.firstWhere(
      (BoardCell x) => x.kind == CellKind.operator,
    );
    c.pressCell(op.coord);
    expect(c.phase, GamePhase.idle);
    expect(c.path, isEmpty);
  });

  test('extend rejects a non-adjacent cell', () {
    final GameController c = newController();
    final BoardCell start = c.board.cells.firstWhere(
      (BoardCell x) => x.kind == CellKind.number,
    );
    c.pressCell(start.coord);
    // A far cell (guaranteed non-adjacent): shift q by 4.
    c.extendToCell(AxialCoordinate(start.coord.q + 4, start.coord.r));
    expect(c.path.length, 1);
  });

  test('backtracking to the previous cell pops the selection', () {
    final GameController c = newController();
    final List<AxialCoordinate> sol = c.board.sampleSolutions.first;
    c.pressCell(sol[0]);
    c.extendToCell(sol[1]);
    expect(c.path.length, 2);
    c.extendToCell(sol[0]); // drag back
    expect(c.path.length, 1);
  });

  test('releasing an incomplete path rewinds without penalty', () {
    final GameController c = newController();
    final BoardCell start = c.board.cells.firstWhere(
      (BoardCell x) => x.kind == CellKind.number,
    );
    c.pressCell(start.coord);
    c.release();
    expect(c.notifier.value.equationsSolved, 0);
    expect(c.notifier.value.score, 0);
    expect(c.phase.acceptsPress, isTrue);
  });

  test('a complete-but-wrong equation breaks the combo', () {
    final GameController c = newController();
    // First a correct equation (combo 1).
    drivePath(c, c.board.sampleSolutions.first);
    settle(c);
    expect(c.notifier.value.comboCount, 1);

    // Build a wrong variant: same LHS but a different result cell.
    final List<AxialCoordinate>? wrong = _wrongVariant(c);
    if (wrong == null) {
      return; // extremely rare: no wrong result reachable; covered by replay tests
    }
    drivePath(c, wrong);
    expect(c.notifier.value.lastEquationCorrect, isFalse);
    expect(c.notifier.value.comboCount, 0);
  });

  test('eight consecutive correct equations ignite Fever', () {
    final GameController c = newController();
    for (int i = 0; i < 8; i++) {
      drivePath(c, c.board.sampleSolutions.first);
      c.tick(500); // within the combo window, clears the feedback phase
    }
    expect(c.notifier.value.feverActive, isTrue);
  });

  test(
    'completing enough equations advances the level and swaps the board',
    () {
      final GameController c = newController();
      final int firstTarget = c.board.target;
      final List<BoardCell> firstCells = List<BoardCell>.of(c.board.cells);

      for (int i = 0; i < 5; i++) {
        drivePath(c, c.board.sampleSolutions.first);
        c.tick(500);
      }
      expect(c.notifier.value.level, 1);
      // Board changed at level completion.
      final bool boardChanged =
          c.board.target != firstTarget ||
          !_sameCells(c.board.cells, firstCells);
      expect(boardChanged, isTrue);
    },
  );

  test('a full run drives to the finished state with a positive score', () {
    final GameController c = newController();
    int guard = 0;
    while (!c.notifier.value.finished && guard < 400) {
      if (c.phase.acceptsPress && c.board.sampleSolutions.isNotEmpty) {
        drivePath(c, c.board.sampleSolutions.first);
      }
      c.tick(1000);
      guard++;
    }
    expect(c.notifier.value.finished, isTrue);
    expect(c.notifier.value.score, greaterThan(0));
    expect(c.notifier.value.equationsSolved, greaterThan(0));
    expect(c.notifier.value.timeRemainingMs, 0);
  });

  test('the combo pill decays after the combo window lapses', () {
    final GameController c = newController();
    drivePath(c, c.board.sampleSolutions.first);
    settle(c);
    drivePath(c, c.board.sampleSolutions.first);
    c.tick(500); // within the 4s window
    expect(c.notifier.value.comboCount, 2);

    c.tick(5000); // past the window with no new equation
    expect(c.notifier.value.comboCount, 0);
  });

  test('cancelSelection aborts an in-progress path without recording', () {
    final GameController c = newController();
    final List<AxialCoordinate> sol = c.board.sampleSolutions.first;
    c.pressCell(sol[0]);
    c.extendToCell(sol[1]);
    expect(c.path.length, 2);
    c.cancelSelection();
    expect(c.path, isEmpty);
    expect(c.notifier.value.equationsSolved, 0);
    expect(c.phase.acceptsPress, isTrue);
  });

  test('cancelling a complete-but-wrong path does not break the combo', () {
    final GameController c = newController();
    drivePath(c, c.board.sampleSolutions.first);
    settle(c);
    expect(c.notifier.value.comboCount, 1);

    final List<AxialCoordinate>? wrong = _wrongVariant(c);
    if (wrong == null) {
      return; // no reachable wrong result; covered elsewhere
    }
    // Draw the wrong equation but CANCEL instead of releasing.
    c.pressCell(wrong.first);
    for (int i = 1; i < wrong.length; i++) {
      c.extendToCell(wrong[i]);
    }
    c.cancelSelection();

    // The wrong equation was never committed: combo intact, no penalty.
    expect(c.notifier.value.comboCount, 1);
    expect(c.notifier.value.lastEquationCorrect, isTrue);
  });

  test('pausing clears an in-progress selection', () {
    final GameController c = newController();
    final List<AxialCoordinate> sol = c.board.sampleSolutions.first;
    c.pressCell(sol[0]);
    c.extendToCell(sol[1]);
    expect(c.path.length, 2);
    c.togglePause();
    expect(c.path, isEmpty);
  });

  test('pause freezes the run clock', () {
    final GameController c = newController();
    c.tick(2000);
    final int before = c.notifier.value.timeRemainingMs;
    c.togglePause();
    expect(c.phase, GamePhase.paused);
    c.tick(5000);
    expect(c.notifier.value.timeRemainingMs, before);
    c.togglePause();
    expect(c.phase.acceptsPress, isTrue);
  });
}

bool _sameCells(List<BoardCell> a, List<BoardCell> b) {
  if (a.length != b.length) {
    return false;
  }
  for (int i = 0; i < a.length; i++) {
    if (a[i].kind != b[i].kind ||
        a[i].value != b[i].value ||
        a[i].operator != b[i].operator) {
      return false;
    }
  }
  return true;
}

/// Finds a complete-but-wrong path: the sample solution's LHS and equals, then a
/// different adjacent number result cell whose value differs from the true value.
List<AxialCoordinate>? _wrongVariant(GameController c) {
  final List<AxialCoordinate> sol = c.board.sampleSolutions.first;
  final AxialCoordinate equalsCoord = sol[sol.length - 2];
  final AxialCoordinate resultCoord = sol[sol.length - 1];
  final int trueValue = c.cellAt(resultCoord)!.value;
  final List<AxialCoordinate> lhsAndEquals = sol.sublist(0, sol.length - 1);

  for (final AxialCoordinate dir in Hex.directions) {
    final AxialCoordinate cand = AxialCoordinate(
      equalsCoord.q + dir.q,
      equalsCoord.r + dir.r,
    );
    final BoardCell? cell = c.cellAt(cand);
    if (cell == null || cell.kind != CellKind.number) {
      continue;
    }
    if (lhsAndEquals.contains(cand) || cell.value == trueValue) {
      continue;
    }
    return <AxialCoordinate>[...lhsAndEquals, cand];
  }
  return null;
}
