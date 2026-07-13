/// Incremental swipe-chain validation independent of input/rendering code.
library;

import '../expression.dart';
import '../geometry.dart';
import 'board_state_v2.dart';
import 'expression_evaluator_v2.dart';

class SwipeChainErrorCodesV2 {
  SwipeChainErrorCodesV2._();

  static const String startNotNumber = 'START_NOT_NUMBER';
  static const String cellNotPlayable = 'CELL_NOT_PLAYABLE';
  static const String notAdjacent = 'NOT_ADJACENT';
  static const String repeatedCell = 'REPEATED_CELL';
  static const String expectedNumber = 'EXPECTED_NUMBER';
  static const String expectedOperator = 'EXPECTED_OPERATOR';
  static const String maxLength = 'MAX_LENGTH';
}

/// Canonical committed-chain validation codes shared with replay verification.
class ChainErrorCodesV2 {
  ChainErrorCodesV2._();

  static const String empty = 'CHAIN_EMPTY';
  static const String tooLong = 'CHAIN_TOO_LONG';
  static const String tileMissing = 'TILE_MISSING';
  static const String mustStartWithNumber = 'MUST_START_WITH_NUMBER';
  static const String notAdjacent = 'NOT_ADJACENT';
  static const String repeatedTile = 'REPEATED_TILE';
  static const String mustAlternate = 'MUST_ALTERNATE';
}

class ChainValidationResultV2 {
  const ChainValidationResultV2({
    required this.isValid,
    required this.isComplete,
    this.errorCode,
    this.violationIndex,
  });

  final bool isValid;
  final bool isComplete;
  final String? errorCode;
  final int? violationIndex;
}

/// Pure first-failure-wins validation for a committed release path.
class ChainValidatorV2 {
  ChainValidatorV2._();

  static ChainValidationResultV2 validate(
    BoardStateV2 board,
    List<AxialCoordinate> path,
  ) {
    if (path.isEmpty) {
      return const ChainValidationResultV2(
        isValid: false,
        isComplete: false,
        errorCode: ChainErrorCodesV2.empty,
      );
    }
    if (path.length > ExpressionEvaluatorV2.maxCells) {
      return const ChainValidationResultV2(
        isValid: false,
        isComplete: false,
        errorCode: ChainErrorCodesV2.tooLong,
        violationIndex: ExpressionEvaluatorV2.maxCells,
      );
    }
    final BoardTileV2? first = board.tileAt(path.first);
    if (first == null) {
      return const ChainValidationResultV2(
        isValid: false,
        isComplete: false,
        errorCode: ChainErrorCodesV2.tileMissing,
        violationIndex: 0,
      );
    }
    if (first.kind != BoardTileKindV2.number) {
      return const ChainValidationResultV2(
        isValid: false,
        isComplete: false,
        errorCode: ChainErrorCodesV2.mustStartWithNumber,
        violationIndex: 0,
      );
    }

    final Set<AxialCoordinate> visited = <AxialCoordinate>{path.first};
    for (int index = 1; index < path.length; index++) {
      if (!Hex.areAdjacent(path[index - 1], path[index])) {
        return ChainValidationResultV2(
          isValid: false,
          isComplete: false,
          errorCode: ChainErrorCodesV2.notAdjacent,
          violationIndex: index,
        );
      }
      if (!visited.add(path[index])) {
        return ChainValidationResultV2(
          isValid: false,
          isComplete: false,
          errorCode: ChainErrorCodesV2.repeatedTile,
          violationIndex: index,
        );
      }
      final BoardTileV2? tile = board.tileAt(path[index]);
      if (tile == null) {
        return ChainValidationResultV2(
          isValid: false,
          isComplete: false,
          errorCode: ChainErrorCodesV2.tileMissing,
          violationIndex: index,
        );
      }
      final BoardTileKindV2 expected = index.isEven
          ? BoardTileKindV2.number
          : BoardTileKindV2.operator;
      if (tile.kind != expected) {
        return ChainValidationResultV2(
          isValid: false,
          isComplete: false,
          errorCode: ChainErrorCodesV2.mustAlternate,
          violationIndex: index,
        );
      }
    }
    return ChainValidationResultV2(
      isValid: true,
      isComplete: path.length >= 3 && path.length.isOdd,
    );
  }
}

enum SwipeAppendOutcomeV2 { accepted, backtracked, ignored, rejected }

class SwipeAppendResultV2 {
  const SwipeAppendResultV2({
    required this.outcome,
    required this.chain,
    this.errorCode,
  });

  final SwipeAppendOutcomeV2 outcome;
  final SwipeChainV2 chain;
  final String? errorCode;

  bool get changed =>
      outcome == SwipeAppendOutcomeV2.accepted ||
      outcome == SwipeAppendOutcomeV2.backtracked;
}

enum SwipeReleaseStatusV2 {
  incomplete,
  arithmeticError,
  targetMismatch,
  targetMatch,
}

class SwipeReleaseResultV2 {
  const SwipeReleaseResultV2({
    required this.status,
    this.errorCode,
    this.value,
  });

  final SwipeReleaseStatusV2 status;
  final String? errorCode;
  final int? value;

  bool get isComplete => status != SwipeReleaseStatusV2.incomplete;
  bool get matchesTarget => status == SwipeReleaseStatusV2.targetMatch;
}

class SwipeChainV2 {
  SwipeChainV2._({required this.board, required List<AxialCoordinate> path})
    : path = List<AxialCoordinate>.unmodifiable(path);

  factory SwipeChainV2.start(BoardStateV2 board, AxialCoordinate coordinate) {
    final BoardTileV2? tile = board.tileAt(coordinate);
    if (tile == null) {
      throw ArgumentError.value(
        coordinate,
        'coordinate',
        SwipeChainErrorCodesV2.cellNotPlayable,
      );
    }
    if (tile.kind != BoardTileKindV2.number) {
      throw ArgumentError.value(
        coordinate,
        'coordinate',
        SwipeChainErrorCodesV2.startNotNumber,
      );
    }
    return SwipeChainV2._(board: board, path: <AxialCoordinate>[coordinate]);
  }

  final BoardStateV2 board;
  final List<AxialCoordinate> path;

  List<Token> get tokens => List<Token>.unmodifiable(
    path.map(
      (AxialCoordinate coordinate) => board.tileAt(coordinate)!.toToken(),
    ),
  );

  String get formattedExpression => ExpressionEvaluatorV2.format(tokens);

  SwipeAppendResultV2 append(AxialCoordinate coordinate) {
    if (coordinate == path.last) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.ignored,
        chain: this,
      );
    }

    // Re-entering the immediately previous cell is the sole repeat exception:
    // it removes the latest cell rather than adding a duplicate.
    if (path.length > 1 && coordinate == path[path.length - 2]) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.backtracked,
        chain: SwipeChainV2._(
          board: board,
          path: path.sublist(0, path.length - 1),
        ),
      );
    }

    final BoardTileV2? tile = board.tileAt(coordinate);
    if (tile == null) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.cellNotPlayable,
      );
    }
    if (!Hex.areAdjacent(path.last, coordinate)) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.notAdjacent,
      );
    }
    if (path.contains(coordinate)) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.repeatedCell,
      );
    }
    if (path.length >= ExpressionEvaluatorV2.maxCells) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.maxLength,
      );
    }

    final bool expectsOperator = path.length.isOdd;
    if (expectsOperator && tile.kind != BoardTileKindV2.operator) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.expectedOperator,
      );
    }
    if (!expectsOperator && tile.kind != BoardTileKindV2.number) {
      return SwipeAppendResultV2(
        outcome: SwipeAppendOutcomeV2.rejected,
        chain: this,
        errorCode: SwipeChainErrorCodesV2.expectedNumber,
      );
    }

    return SwipeAppendResultV2(
      outcome: SwipeAppendOutcomeV2.accepted,
      chain: SwipeChainV2._(
        board: board,
        path: <AxialCoordinate>[...path, coordinate],
      ),
    );
  }

  SwipeReleaseResultV2 release() {
    if (path.length < 3 || path.length.isEven) {
      return const SwipeReleaseResultV2(
        status: SwipeReleaseStatusV2.incomplete,
      );
    }
    final ExpressionResultV2 result = ExpressionEvaluatorV2.evaluate(tokens);
    if (!result.isValid) {
      return SwipeReleaseResultV2(
        status: ExpressionStatusV2.arithmeticError == result.status
            ? SwipeReleaseStatusV2.arithmeticError
            : SwipeReleaseStatusV2.incomplete,
        errorCode: result.errorCode,
      );
    }
    return SwipeReleaseResultV2(
      status: result.value == board.target
          ? SwipeReleaseStatusV2.targetMatch
          : SwipeReleaseStatusV2.targetMismatch,
      value: result.value,
    );
  }

  /// Builds a committed chain while applying the exact same incremental rules
  /// used during pointer input. Invalid paths return their first append error.
  static SwipePathValidationV2 validateCommitted(
    BoardStateV2 board,
    List<AxialCoordinate> coordinates,
  ) {
    final ChainValidationResultV2 validation = ChainValidatorV2.validate(
      board,
      coordinates,
    );
    if (!validation.isValid) {
      return SwipePathValidationV2.invalid(
        validation.errorCode!,
        validation.violationIndex,
      );
    }
    final SwipeChainV2 chain = SwipeChainV2._(board: board, path: coordinates);
    return SwipePathValidationV2.valid(chain);
  }
}

class SwipePathValidationV2 {
  const SwipePathValidationV2._({
    required this.isValid,
    this.chain,
    this.errorCode,
    this.violationIndex,
  });

  const SwipePathValidationV2.valid(SwipeChainV2 chain)
    : this._(isValid: true, chain: chain);

  const SwipePathValidationV2.invalid(String errorCode, int? violationIndex)
    : this._(
        isValid: false,
        errorCode: errorCode,
        violationIndex: violationIndex,
      );

  final bool isValid;
  final SwipeChainV2? chain;
  final String? errorCode;
  final int? violationIndex;
}
