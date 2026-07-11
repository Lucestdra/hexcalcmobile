/// Deterministic board generator gen-v1 — Dart twin of the C# BoardGeneratorV1.
/// Must reproduce every board byte-for-byte. See the backend spec
/// docs/gameplay/board-generation.md.
library;

import 'board.dart';
import 'drbg.dart';
import 'expression.dart';
import 'geometry.dart';

/// Structural classification of a token prefix during the solvability search.
enum PrefixClass { dead, prefix, complete }

/// Grammar of expression-evaluation.md in prefix form (spec §6).
PrefixClass classifyPrefix(List<Token> tokens) {
  if (tokens.isEmpty) {
    return PrefixClass.prefix;
  }
  if (tokens[0].kind != TokenKind.number) {
    return PrefixClass.dead;
  }

  bool equalsSeen = false;
  bool resultSeen = false;
  int operatorCount = 0;
  TokenKind lastKind = TokenKind.number;

  for (int i = 1; i < tokens.length; i++) {
    if (resultSeen) {
      return PrefixClass.dead;
    }
    final TokenKind kind = tokens[i].kind;

    if (!equalsSeen) {
      if (lastKind == TokenKind.number) {
        if (kind == TokenKind.operator) {
          operatorCount++;
          lastKind = TokenKind.operator;
        } else if (kind == TokenKind.equals) {
          if (operatorCount < 1) {
            return PrefixClass.dead;
          }
          equalsSeen = true;
          lastKind = TokenKind.equals;
        } else {
          return PrefixClass.dead;
        }
      } else {
        if (kind == TokenKind.number) {
          lastKind = TokenKind.number;
        } else {
          return PrefixClass.dead;
        }
      }
    } else {
      if (kind == TokenKind.number) {
        resultSeen = true;
        lastKind = TokenKind.number;
      } else {
        return PrefixClass.dead;
      }
    }
  }

  return equalsSeen && resultSeen ? PrefixClass.complete : PrefixClass.prefix;
}

class BoardSolution {
  const BoardSolution(this.path, this.leftHandValue);
  final List<AxialCoordinate> path;
  final int leftHandValue;
}

class BoardGeneratorV1 {
  BoardGeneratorV1._();

  static const String generatorVersion = 'gen-v1';

  static const int boardRadius = 2;
  static const int valueMin = 1;
  static const int valueMax = 9;
  static const int categoryTotal = 10;
  static const int operatorTotal = 10;
  static const int minDistinctSolutions = 5;
  static const int solutionSearchCap = 24;
  static const int maxPathCells = 7;
  static const int maxAttempts = 64;

  static Board generate(String seed, String rulesetVersion, int levelIndex) {
    final String payload =
        'HEXCALC|$seed|$rulesetVersion|$generatorVersion|$levelIndex';
    final Drbg drbg = Drbg(payload);
    final List<AxialCoordinate> coords = enumerateCells(boardRadius);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final List<BoardCell> cells = _drawCells(drbg, coords);
      final List<BoardSolution> solutions = findSolutions(cells);
      if (solutions.length >= minDistinctSolutions) {
        return _buildBoard(cells, solutions, attempt + 1, usedFallback: false);
      }
    }

    return generateFallback(levelIndex);
  }

  /// Builds the deterministic fallback board directly (mirrors the C# twin;
  /// exposed so the fallback path gets shared golden-fixture parity coverage).
  static Board generateFallback(int levelIndex) {
    final List<AxialCoordinate> coords = enumerateCells(boardRadius);
    final List<BoardCell> cells = buildFallback(coords, levelIndex);
    final List<BoardSolution> solutions = findSolutions(cells);
    return _buildBoard(cells, solutions, maxAttempts, usedFallback: true);
  }

  static List<AxialCoordinate> enumerateCells(int radius) {
    final List<AxialCoordinate> cells = <AxialCoordinate>[];
    for (int q = -radius; q <= radius; q++) {
      final int rLow = (-radius > -q - radius) ? -radius : -q - radius;
      final int rHigh = (radius < -q + radius) ? radius : -q + radius;
      for (int r = rLow; r <= rHigh; r++) {
        cells.add(AxialCoordinate(q, r));
      }
    }
    return cells;
  }

  static List<BoardCell> _drawCells(Drbg drbg, List<AxialCoordinate> coords) {
    final List<BoardCell> cells = <BoardCell>[];
    for (final AxialCoordinate coord in coords) {
      final int c = drbg.nextInt(categoryTotal);
      if (c < 6) {
        final int value = valueMin + drbg.nextInt(valueMax - valueMin + 1);
        cells.add(BoardCell.number(coord, value));
      } else if (c < 9) {
        cells.add(BoardCell.op(coord, _drawOperator(drbg)));
      } else {
        cells.add(BoardCell.equalsCell(coord));
      }
    }
    return cells;
  }

  static Operator _drawOperator(Drbg drbg) {
    final int w = drbg.nextInt(operatorTotal);
    if (w < 4) {
      return Operator.add;
    }
    if (w < 7) {
      return Operator.subtract;
    }
    return w < 9 ? Operator.multiply : Operator.divide;
  }

  static List<BoardSolution> findSolutions(List<BoardCell> cells) {
    final Map<AxialCoordinate, BoardCell> byCoord =
        <AxialCoordinate, BoardCell>{};
    for (final BoardCell cell in cells) {
      byCoord[cell.coord] = cell;
    }

    final List<BoardSolution> solutions = <BoardSolution>[];
    for (final BoardCell cell in cells) {
      if (solutions.length >= solutionSearchCap) {
        break;
      }
      if (cell.kind == CellKind.number) {
        _dfs(
          byCoord,
          <AxialCoordinate>[cell.coord],
          <Token>[cell.toToken()],
          solutions,
        );
      }
    }
    return solutions;
  }

  static void _dfs(
    Map<AxialCoordinate, BoardCell> byCoord,
    List<AxialCoordinate> path,
    List<Token> tokens,
    List<BoardSolution> solutions,
  ) {
    if (solutions.length >= solutionSearchCap) {
      return;
    }

    final PrefixClass cls = classifyPrefix(tokens);
    if (cls == PrefixClass.complete) {
      final EquationResult result = EquationEvaluator.evaluate(tokens);
      if (result.status == EquationStatus.valid) {
        solutions.add(
          BoardSolution(
            List<AxialCoordinate>.from(path),
            result.leftHandValue!,
          ),
        );
      }
      return;
    }

    if (path.length >= maxPathCells) {
      return;
    }

    final AxialCoordinate last = path[path.length - 1];
    for (final AxialCoordinate dir in Hex.directions) {
      final AxialCoordinate next = AxialCoordinate(
        last.q + dir.q,
        last.r + dir.r,
      );
      final BoardCell? nextCell = byCoord[next];
      if (nextCell == null || path.contains(next)) {
        continue;
      }

      tokens.add(nextCell.toToken());
      if (classifyPrefix(tokens) != PrefixClass.dead) {
        path.add(next);
        _dfs(byCoord, path, tokens, solutions);
        path.removeLast();
      }
      tokens.removeLast();
    }
  }

  static Board _buildBoard(
    List<BoardCell> cells,
    List<BoardSolution> solutions,
    int attemptsUsed, {
    required bool usedFallback,
  }) {
    final int target = _selectTarget(solutions);
    final List<List<AxialCoordinate>> sample = solutions
        .take(3)
        .map((BoardSolution s) => s.path)
        .toList();
    return Board(
      radius: boardRadius,
      cells: cells,
      target: target,
      attemptsUsed: attemptsUsed,
      usedFallback: usedFallback,
      sampleSolutions: sample,
    );
  }

  static int _selectTarget(List<BoardSolution> solutions) {
    if (solutions.isEmpty) {
      return 0;
    }
    int best = solutions[0].leftHandValue;
    for (int i = 1; i < solutions.length; i++) {
      if (solutions[i].leftHandValue > best) {
        best = solutions[i].leftHandValue;
      }
    }
    return best;
  }

  /// Deterministic guaranteed-solvable fallback (spec §8). Mirrors the C# twin.
  static List<BoardCell> buildFallback(
    List<AxialCoordinate> coords,
    int levelIndex,
  ) {
    // Rows grouped by r, ascending; within each row ascending by q.
    final List<int> rows =
        coords.map((AxialCoordinate c) => c.r).toSet().toList()..sort();
    final List<BoardCell> cells = <BoardCell>[];
    for (final int r in rows) {
      final List<AxialCoordinate> ordered =
          coords.where((AxialCoordinate c) => c.r == r).toList()..sort(
            (AxialCoordinate a, AxialCoordinate b) => a.q.compareTo(b.q),
          );
      for (int i = 0; i < ordered.length; i++) {
        final AxialCoordinate coord = ordered[i];
        final int slot = i % 5;
        switch (slot) {
          case 0:
            cells.add(BoardCell.number(coord, 1));
          case 1:
            cells.add(BoardCell.op(coord, Operator.add));
          case 2:
            cells.add(BoardCell.number(coord, 1));
          case 3:
            cells.add(BoardCell.equalsCell(coord));
          default:
            cells.add(BoardCell.number(coord, 2));
        }
      }
    }

    // Re-sort into canonical coord order.
    final Map<AxialCoordinate, int> order = <AxialCoordinate, int>{};
    for (int i = 0; i < coords.length; i++) {
      order[coords[i]] = i;
    }
    cells.sort(
      (BoardCell a, BoardCell b) => order[a.coord]!.compareTo(order[b.coord]!),
    );
    return cells;
  }
}
