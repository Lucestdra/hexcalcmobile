/// Shared release/evaluate/refill mechanic, independent of game mode.
library;

import '../expression.dart';
import '../geometry.dart';
import 'board_generator_v2.dart';
import 'board_state_v2.dart';
import 'expression_evaluator_v2.dart';
import 'map_catalog_v1.dart';
import 'swipe_chain_v2.dart';

enum ChainReleaseStatusV2 {
  accepted,
  incomplete,
  invalidChain,
  arithmeticRejected,
  targetMismatch,
}

class ChainReleaseResultV2 {
  const ChainReleaseResultV2({
    required this.status,
    required this.board,
    required this.chain,
    this.expression,
  });

  final ChainReleaseStatusV2 status;
  final BoardStateV2 board;
  final ChainValidationResultV2 chain;
  final ExpressionResultV2? expression;

  bool get consumed => status == ChainReleaseStatusV2.accepted;
}

class BoardEngineV2 {
  BoardEngineV2._();

  static ChainReleaseResultV2 release({
    required BoardStateV2 state,
    required List<AxialCoordinate> path,
    required MapDefinitionV2 map,
    String? seed,
  }) {
    final ChainValidationResultV2 validation = ChainValidatorV2.validate(
      state,
      path,
    );
    if (!validation.isValid) {
      return ChainReleaseResultV2(
        status: ChainReleaseStatusV2.invalidChain,
        board: state,
        chain: validation,
      );
    }
    if (!validation.isComplete) {
      return ChainReleaseResultV2(
        status: ChainReleaseStatusV2.incomplete,
        board: state,
        chain: validation,
      );
    }

    final List<Token> tokens = <Token>[
      for (final AxialCoordinate coordinate in path)
        state.tileAt(coordinate)!.toToken(),
    ];
    final ExpressionResultV2 expression = ExpressionEvaluatorV2.evaluate(
      tokens,
    );
    if (!expression.isValid) {
      return ChainReleaseResultV2(
        status: ChainReleaseStatusV2.arithmeticRejected,
        board: state,
        chain: validation,
        expression: expression,
      );
    }
    if (expression.value != state.target) {
      return ChainReleaseResultV2(
        status: ChainReleaseStatusV2.targetMismatch,
        board: state,
        chain: validation,
        expression: expression,
      );
    }

    final BoardStateV2 next = BoardGeneratorV2.refill(
      seed: seed ?? state.seed,
      map: map,
      board: state,
      consumedPath: path,
    );
    return ChainReleaseResultV2(
      status: ChainReleaseStatusV2.accepted,
      board: next,
      chain: validation,
      expression: expression,
    );
  }

  static ChainReleaseResultV2 submit({
    required BoardStateV2 state,
    required List<AxialCoordinate> path,
    required MapDefinitionV2 map,
    String? seed,
  }) => release(state: state, path: path, map: map, seed: seed);
}
