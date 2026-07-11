import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

/// Independent solvability property test (mirrors the backend BoardTests): every
/// generated board must be solvable with a reachable target.
void main() {
  for (int i = 0; i < 30; i++) {
    for (int level = 0; level <= 2; level++) {
      test('board seed-$i level $level is solvable and target reachable', () {
        final Board board = BoardGeneratorV1.generate(
          'seed-$i',
          'rs-v1',
          level,
        );
        final Map<AxialCoordinate, BoardCell> byCoord =
            <AxialCoordinate, BoardCell>{
              for (final BoardCell c in board.cells) c.coord: c,
            };
        final List<BoardSolution> solutions = BoardGeneratorV1.findSolutions(
          board.cells,
        );

        expect(board.cells.length, 19);
        if (!board.usedFallback) {
          expect(
            solutions.length,
            greaterThanOrEqualTo(BoardGeneratorV1.minDistinctSolutions),
          );
        }
        expect(solutions, isNotEmpty);

        for (final BoardSolution s in solutions) {
          expect(PathValidator.validate(s.path).isValid, isTrue);
          final List<Token> tokens = s.path
              .map((AxialCoordinate co) => byCoord[co]!.toToken())
              .toList();
          final EquationResult r = EquationEvaluator.evaluate(tokens);
          expect(r.status, EquationStatus.valid);
          expect(r.leftHandValue, s.leftHandValue);
        }

        final int maxValue = solutions
            .map((BoardSolution s) => s.leftHandValue)
            .reduce((int a, int b) => a > b ? a : b);
        expect(board.target, maxValue);
      });
    }
  }

  test('generate is deterministic', () {
    final Board a = BoardGeneratorV1.generate('determinism', 'rs-v1', 1);
    final Board b = BoardGeneratorV1.generate('determinism', 'rs-v1', 1);
    expect(a.target, b.target);
    expect(a.attemptsUsed, b.attemptsUsed);
    expect(a.cells.length, b.cells.length);
    for (int i = 0; i < a.cells.length; i++) {
      expect(a.cells[i].kind, b.cells[i].kind);
      expect(a.cells[i].value, b.cells[i].value);
      expect(a.cells[i].operator, b.cells[i].operator);
    }
  });

  test('radius two enumeration has nineteen cells in canonical order', () {
    final List<AxialCoordinate> cells = BoardGeneratorV1.enumerateCells(2);
    expect(cells.length, 19);
    expect(cells.first, const AxialCoordinate(-2, 0));
    expect(cells.last, const AxialCoordinate(2, 0));
  });

  test('generating 1000 boards is fast enough', () {
    final Stopwatch sw = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      BoardGeneratorV1.generate('perf-$i', 'rs-v1', 0);
    }
    sw.stop();
    // Documented sanity budget, not a hard gate.
    expect(sw.elapsedMilliseconds, lessThan(5000));
  });
}
