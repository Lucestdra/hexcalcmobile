/// Exhaustive reachable-target analysis for target-swipe boards.
library;

import '../expression.dart';
import '../geometry.dart';
import 'board_state_v2.dart';
import 'expression_evaluator_v2.dart';

int operatorComplexityV2(Operator operator) => switch (operator) {
  Operator.add => 0,
  Operator.subtract => 1,
  Operator.multiply => 2,
  Operator.divide => 3,
};

class TargetCandidateV2 {
  TargetCandidateV2({
    required this.result,
    required this.solutionCount,
    required Iterable<AxialCoordinate> canonicalHintPath,
    required this.shortestChainLength,
    required this.operatorComplexity,
    required this.difficulty,
  }) : canonicalHintPath = List<AxialCoordinate>.unmodifiable(
         canonicalHintPath,
       );

  final int result;
  final int solutionCount;
  final List<AxialCoordinate> canonicalHintPath;
  final int shortestChainLength;
  final int operatorComplexity;
  final int difficulty;

  int get operatorCount => (shortestChainLength - 1) ~/ 2;
}

class _CandidateAccumulator {
  _CandidateAccumulator({
    required this.result,
    required List<AxialCoordinate> hint,
    required this.hintComplexity,
    required this.hintDiscoveryOrder,
  }) : hint = List<AxialCoordinate>.from(hint);

  final int result;
  int solutionCount = 1;
  List<AxialCoordinate> hint;
  int hintComplexity;
  int hintDiscoveryOrder;

  void record(List<AxialCoordinate> path, int complexity, int discoveryOrder) {
    solutionCount++;
    final bool isBetter =
        path.length < hint.length ||
        (path.length == hint.length && complexity < hintComplexity) ||
        (path.length == hint.length &&
            complexity == hintComplexity &&
            discoveryOrder < hintDiscoveryOrder);
    if (isBetter) {
      hint = List<AxialCoordinate>.from(path);
      hintComplexity = complexity;
      hintDiscoveryOrder = discoveryOrder;
    }
  }

  TargetCandidateV2 finish() {
    final int operatorCount = (hint.length - 1) ~/ 2;
    final int scarcity = 10 - (solutionCount < 10 ? solutionCount : 10);
    return TargetCandidateV2(
      result: result,
      solutionCount: solutionCount,
      canonicalHintPath: hint,
      shortestChainLength: hint.length,
      operatorComplexity: hintComplexity,
      difficulty: operatorCount * 100 + hintComplexity * 10 + scarcity,
    );
  }
}

/// Enumerates every directed, non-repeating alternating path of length 3, 5,
/// or 7. Starting cells follow authored map order and neighbors follow
/// [Hex.directions], which makes hint tie-breaking cross-platform stable.
class TargetAnalyzerV2 {
  TargetAnalyzerV2._();

  static List<TargetCandidateV2> analyze(BoardStateV2 board) =>
      analyzeTiles(topology: board.topology, tiles: board.tiles);

  static List<TargetCandidateV2> analyzeTiles({
    required BoardTopologyV2 topology,
    required Iterable<BoardTileV2> tiles,
  }) {
    final Map<AxialCoordinate, BoardTileV2> byCoordinate =
        <AxialCoordinate, BoardTileV2>{
          for (final BoardTileV2 tile in tiles) tile.coordinate: tile,
        };
    final Map<int, _CandidateAccumulator> candidates =
        <int, _CandidateAccumulator>{};
    int discoveryOrder = 0;

    for (final AxialCoordinate start in topology.playableCoordinates) {
      final BoardTileV2? tile = byCoordinate[start];
      if (tile == null || tile.kind != BoardTileKindV2.number) {
        continue;
      }
      _search(
        byCoordinate: byCoordinate,
        path: <AxialCoordinate>[start],
        tokens: <Token>[tile.toToken()],
        complexity: 0,
        onSolution: (int result, List<AxialCoordinate> path, int complexity) {
          final int order = discoveryOrder++;
          final _CandidateAccumulator? current = candidates[result];
          if (current == null) {
            candidates[result] = _CandidateAccumulator(
              result: result,
              hint: path,
              hintComplexity: complexity,
              hintDiscoveryOrder: order,
            );
          } else {
            current.record(path, complexity, order);
          }
        },
      );
    }

    final List<TargetCandidateV2> result =
        candidates.values
            .map((_CandidateAccumulator candidate) => candidate.finish())
            .toList()
          ..sort(
            (TargetCandidateV2 a, TargetCandidateV2 b) =>
                a.result.compareTo(b.result),
          );
    return List<TargetCandidateV2>.unmodifiable(result);
  }

  static void _search({
    required Map<AxialCoordinate, BoardTileV2> byCoordinate,
    required List<AxialCoordinate> path,
    required List<Token> tokens,
    required int complexity,
    required void Function(
      int result,
      List<AxialCoordinate> path,
      int complexity,
    )
    onSolution,
  }) {
    if (path.length >= 3 && path.length.isOdd) {
      final ExpressionResultV2 evaluation = ExpressionEvaluatorV2.evaluate(
        tokens,
      );
      if (evaluation.isValid) {
        onSolution(
          evaluation.value!,
          List<AxialCoordinate>.from(path),
          complexity,
        );
      }
    }
    if (path.length >= ExpressionEvaluatorV2.maxCells) {
      return;
    }

    final bool expectsOperator = path.length.isOdd;
    final AxialCoordinate last = path.last;
    for (final AxialCoordinate direction in Hex.directions) {
      final AxialCoordinate next = AxialCoordinate(
        last.q + direction.q,
        last.r + direction.r,
      );
      final BoardTileV2? tile = byCoordinate[next];
      if (tile == null || path.contains(next)) {
        continue;
      }
      if (expectsOperator && tile.kind != BoardTileKindV2.operator) {
        continue;
      }
      if (!expectsOperator && tile.kind != BoardTileKindV2.number) {
        continue;
      }

      path.add(next);
      tokens.add(tile.toToken());
      _search(
        byCoordinate: byCoordinate,
        path: path,
        tokens: tokens,
        complexity:
            complexity +
            (tile.kind == BoardTileKindV2.operator
                ? operatorComplexityV2(tile.operator!)
                : 0),
        onSolution: onSolution,
      );
      tokens.removeLast();
      path.removeLast();
    }
  }
}
