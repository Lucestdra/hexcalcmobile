import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'v2_test_support.dart';

void main() {
  const AxialCoordinate a = AxialCoordinate(0, 0);
  const AxialCoordinate b = AxialCoordinate(1, 0);
  const AxialCoordinate c = AxialCoordinate(2, 0);
  const AxialCoordinate offBoard = AxialCoordinate(9, 9);

  late BoardStateV2 board;
  setUp(() {
    board = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(a, 1),
        BoardTileV2.op(b, Operator.add),
        BoardTileV2.number(c, 2),
      ],
      target: 3,
    );
  });

  test('starts on a number and alternates adjacent tiles', () {
    SwipeChainV2 chain = SwipeChainV2.start(board, a);
    final SwipeAppendResultV2 operator = chain.append(b);
    expect(operator.outcome, SwipeAppendOutcomeV2.accepted);
    chain = operator.chain;
    final SwipeAppendResultV2 number = chain.append(c);
    expect(number.outcome, SwipeAppendOutcomeV2.accepted);
    expect(number.chain.formattedExpression, '1 + 2');
    expect(number.chain.release().status, SwipeReleaseStatusV2.targetMatch);
  });

  test('immediate previous cell backtracks without committing a repeat', () {
    SwipeChainV2 chain = SwipeChainV2.start(board, a).append(b).chain;
    chain = chain.append(c).chain;

    final SwipeAppendResultV2 update = chain.append(b);

    expect(update.outcome, SwipeAppendOutcomeV2.backtracked);
    expect(update.chain.path, <AxialCoordinate>[a, b]);
    expect(update.chain.release().status, SwipeReleaseStatusV2.incomplete);
  });

  test('rejects holes, non-adjacent cells, repeats and bad alternation', () {
    expect(
      SwipeChainV2.start(board, a).append(offBoard).errorCode,
      SwipeChainErrorCodesV2.cellNotPlayable,
    );
    expect(
      SwipeChainV2.start(board, c).append(a).errorCode,
      SwipeChainErrorCodesV2.notAdjacent,
    );
    final BoardStateV2 triangle = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(a, 1),
        BoardTileV2.op(b, Operator.add),
        BoardTileV2.number(const AxialCoordinate(1, -1), 2),
      ],
      target: 3,
    );
    final SwipeChainV2 complete = SwipeChainV2.start(
      triangle,
      a,
    ).append(b).chain.append(const AxialCoordinate(1, -1)).chain;
    expect(complete.append(a).errorCode, SwipeChainErrorCodesV2.repeatedCell);
    expect(
      SwipeChainV2.start(board, a).append(c).errorCode,
      SwipeChainErrorCodesV2.notAdjacent,
    );
    expect(() => SwipeChainV2.start(board, b), throwsArgumentError);
  });

  test('committed validator reports completeness and stable errors', () {
    expect(
      ChainValidatorV2.validate(board, <AxialCoordinate>[a]).isComplete,
      isFalse,
    );
    expect(
      ChainValidatorV2.validate(board, <AxialCoordinate>[a, b, c]).isComplete,
      isTrue,
    );
    final ChainValidationResultV2 repeated = ChainValidatorV2.validate(
      board,
      <AxialCoordinate>[a, b, a],
    );
    expect(repeated.errorCode, ChainErrorCodesV2.repeatedTile);
    expect(repeated.violationIndex, 2);
  });
}
