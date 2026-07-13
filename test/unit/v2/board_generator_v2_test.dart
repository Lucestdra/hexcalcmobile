import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'v2_test_support.dart';

void main() {
  test(
    'generation is deterministic and always publishes a reachable target',
    () {
      final MapDefinitionV2 map = simpleMap();
      final BoardStateV2 a = BoardGeneratorV2.generate(seed: 'alpha', map: map);
      final BoardStateV2 b = BoardGeneratorV2.generate(seed: 'alpha', map: map);

      expect(a.tiles, orderedEquals(b.tiles));
      expect(a.target, b.target);
      expect(a.revision, 0);
      expect(a.lastTransition.attemptsUsed, b.lastTransition.attemptsUsed);
      expect(
        TargetAnalyzerV2.analyze(
          a,
        ).any((TargetCandidateV2 candidate) => candidate.result == a.target),
        isTrue,
      );
    },
  );

  test(
    'accepted release refills only consumed cells and advances revision',
    () {
      final List<AxialCoordinate> coordinates = <AxialCoordinate>[
        for (int q = 0; q < 5; q++) AxialCoordinate(q, 0),
      ];
      final MapDefinitionV2 map = simpleMap(coordinates: coordinates);
      final BoardStateV2 board = boardFromTiles(
        seed: 'refill-seed',
        tiles: <BoardTileV2>[
          BoardTileV2.number(coordinates[0], 1),
          BoardTileV2.op(coordinates[1], Operator.add),
          BoardTileV2.number(coordinates[2], 2),
          BoardTileV2.op(coordinates[3], Operator.multiply),
          BoardTileV2.number(coordinates[4], 4),
        ],
        target: 3,
      );
      final List<AxialCoordinate> path = coordinates.take(3).toList();

      final ChainReleaseResultV2 result = BoardEngineV2.release(
        state: board,
        path: path,
        map: map,
      );

      expect(result.status, ChainReleaseStatusV2.accepted);
      expect(result.board.revision, 1);
      expect(result.board.lastTransition.consumed, path);
      expect(result.board.tileAt(coordinates[3]), board.tileAt(coordinates[3]));
      expect(result.board.tileAt(coordinates[4]), board.tileAt(coordinates[4]));
      expect(
        TargetAnalyzerV2.analyze(result.board).any(
          (TargetCandidateV2 candidate) =>
              candidate.result == result.board.target,
        ),
        isTrue,
      );
    },
  );

  test('wrong target and arithmetic rejection retain exact board instance', () {
    final MapDefinitionV2 map = simpleMap();
    final BoardStateV2 wrong = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(const AxialCoordinate(0, 0), 1),
        BoardTileV2.op(const AxialCoordinate(1, 0), Operator.add),
        BoardTileV2.number(const AxialCoordinate(2, 0), 2),
      ],
      target: 99,
    );
    final ChainReleaseResultV2 mismatch = BoardEngineV2.release(
      state: wrong,
      path: wrong.topology.playableCoordinates,
      map: map,
    );
    expect(mismatch.status, ChainReleaseStatusV2.targetMismatch);
    expect(identical(mismatch.board, wrong), isTrue);

    final BoardStateV2 inexact = boardFromTiles(
      tiles: <BoardTileV2>[
        BoardTileV2.number(const AxialCoordinate(0, 0), 5),
        BoardTileV2.op(const AxialCoordinate(1, 0), Operator.divide),
        BoardTileV2.number(const AxialCoordinate(2, 0), 2),
      ],
      target: 2,
    );
    final ChainReleaseResultV2 rejected = BoardEngineV2.release(
      state: inexact,
      path: inexact.topology.playableCoordinates,
      map: map,
    );
    expect(rejected.status, ChainReleaseStatusV2.arithmeticRejected);
    expect(identical(rejected.board, inexact), isTrue);
  });

  test('64 failed random draws trigger safe deterministic repair', () {
    final MapDefinitionV2 map = MapDefinitionV2(
      id: 'repair-test',
      order: 0,
      name: 'Repair Test',
      tier: MapTierV2.beginner,
      eligibleModes: const <String>[GameModeIdsV1.timeAttack],
      playableCoordinates: const <AxialCoordinate>[
        AxialCoordinate(0, 0),
        AxialCoordinate(1, 0),
        AxialCoordinate(2, 0),
      ],
      distribution: TileDistributionV2(
        numberWeight: 1000000,
        operatorWeight: 1,
        numbers: const <WeightedNumberV2>[
          WeightedNumberV2(value: 9, weight: 1),
        ],
        operators: const <Operator, int>{
          Operator.add: 1,
          Operator.subtract: 0,
          Operator.multiply: 0,
          Operator.divide: 0,
        },
      ),
      levelGoal: LevelGoalV2(
        durationMs: 60000,
        targetQuota: 1,
        starScoreThresholds: const <int>[100, 150, 225],
      ),
    );

    final BoardStateV2 board = BoardGeneratorV2.generate(
      seed: 'force-repair',
      map: map,
    );

    expect(board.lastTransition.usedRepair, isTrue);
    expect(board.tiles.map((BoardTileV2 tile) => tile.displayText), <String>[
      '1',
      '+',
      '1',
    ]);
    expect(board.target, 2);
  });

  test('target selection avoids an immediate repeat when possible', () {
    final MapDefinitionV2 map = simpleMap();
    final List<TargetCandidateV2> candidates = <TargetCandidateV2>[
      TargetCandidateV2(
        result: 3,
        solutionCount: 1,
        canonicalHintPath: const <AxialCoordinate>[
          AxialCoordinate(0, 0),
          AxialCoordinate(1, 0),
          AxialCoordinate(2, 0),
        ],
        shortestChainLength: 3,
        operatorComplexity: 0,
        difficulty: 109,
      ),
      TargetCandidateV2(
        result: 4,
        solutionCount: 1,
        canonicalHintPath: const <AxialCoordinate>[
          AxialCoordinate(0, 0),
          AxialCoordinate(1, 0),
          AxialCoordinate(2, 0),
        ],
        shortestChainLength: 3,
        operatorComplexity: 0,
        difficulty: 109,
      ),
    ];
    expect(
      TargetSelectorV2.select(
        candidates: candidates,
        seed: 'target',
        map: map,
        revision: 1,
        previousTarget: 3,
      ).result,
      4,
    );
  });
}
