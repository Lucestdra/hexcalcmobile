import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'v2_test_support.dart';

void main() {
  test('counts every directed solution and picks canonical hint', () {
    final BoardStateV2 board = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(const AxialCoordinate(0, 0), 1),
        BoardTileV2.op(const AxialCoordinate(1, 0), Operator.add),
        BoardTileV2.number(const AxialCoordinate(2, 0), 2),
      ],
      target: 3,
    );

    final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyze(board);

    expect(candidates, hasLength(1));
    expect(candidates.single.result, 3);
    expect(candidates.single.solutionCount, 2);
    expect(candidates.single.shortestChainLength, 3);
    expect(candidates.single.canonicalHintPath, const <AxialCoordinate>[
      AxialCoordinate(0, 0),
      AxialCoordinate(1, 0),
      AxialCoordinate(2, 0),
    ]);
    expect(candidates.single.difficulty, 108);
  });

  test('uses precedence and exposes exact counts for 3/5-cell paths', () {
    final BoardStateV2 board = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(const AxialCoordinate(0, 0), 2),
        BoardTileV2.op(const AxialCoordinate(1, 0), Operator.add),
        BoardTileV2.number(const AxialCoordinate(2, 0), 3),
        BoardTileV2.op(const AxialCoordinate(3, 0), Operator.multiply),
        BoardTileV2.number(const AxialCoordinate(4, 0), 4),
      ],
      target: 14,
    );

    final Map<int, TargetCandidateV2> candidates = <int, TargetCandidateV2>{
      for (final TargetCandidateV2 candidate in TargetAnalyzerV2.analyze(board))
        candidate.result: candidate,
    };

    expect(candidates.keys, containsAll(<int>[5, 12, 14]));
    expect(candidates[14]!.solutionCount, 2);
    expect(candidates[14]!.shortestChainLength, 5);
    expect(candidates[14]!.operatorComplexity, 2);
    expect(candidates[14]!.difficulty, 228);
  });

  test('candidate results are always sorted ascending', () {
    final BoardStateV2 board = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(const AxialCoordinate(0, 0), 2),
        BoardTileV2.op(const AxialCoordinate(1, 0), Operator.subtract),
        BoardTileV2.number(const AxialCoordinate(2, 0), 1),
        BoardTileV2.op(const AxialCoordinate(3, 0), Operator.add),
        BoardTileV2.number(const AxialCoordinate(4, 0), 5),
      ],
      target: 1,
    );
    final List<int> results = TargetAnalyzerV2.analyze(
      board,
    ).map((TargetCandidateV2 candidate) => candidate.result).toList();
    expect(results, orderedEquals(<int>[1, 4, 6]));
  });
}
