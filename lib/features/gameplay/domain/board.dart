/// Board model — Dart twin of the C# Board/BoardCell.
/// See the backend spec docs/gameplay/board-generation.md §9.
library;

import 'expression.dart';
import 'geometry.dart';

enum CellKind { number, operator, equals }

class BoardCell {
  const BoardCell(this.coord, this.kind, this.value, this.operator);

  final AxialCoordinate coord;
  final CellKind kind;

  /// Meaningful for [CellKind.number].
  final int value;

  /// Meaningful for [CellKind.operator].
  final Operator? operator;

  factory BoardCell.number(AxialCoordinate c, int value) =>
      BoardCell(c, CellKind.number, value, null);

  factory BoardCell.op(AxialCoordinate c, Operator op) =>
      BoardCell(c, CellKind.operator, 0, op);

  factory BoardCell.equalsCell(AxialCoordinate c) =>
      BoardCell(c, CellKind.equals, 0, null);

  Token toToken() {
    switch (kind) {
      case CellKind.number:
        return Token.number(value);
      case CellKind.operator:
        return Token.op(operator!);
      case CellKind.equals:
        return Token.equals;
    }
  }
}

class Board {
  const Board({
    required this.radius,
    required this.cells,
    required this.target,
    required this.attemptsUsed,
    required this.usedFallback,
    required this.sampleSolutions,
  });

  final int radius;
  final List<BoardCell> cells;
  final int target;
  final int attemptsUsed;
  final bool usedFallback;
  final List<List<AxialCoordinate>> sampleSolutions;
}
