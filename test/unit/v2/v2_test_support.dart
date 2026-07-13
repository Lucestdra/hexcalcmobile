import 'package:hexcalc/features/gameplay/domain/domain.dart';

MapDefinitionV2 simpleMap({
  String id = 'test-map',
  MapTierV2 tier = MapTierV2.beginner,
  List<AxialCoordinate>? coordinates,
}) => MapDefinitionV2(
  id: id,
  order: 0,
  name: 'Test Map',
  tier: tier,
  eligibleModes: const <String>[GameModeIdsV1.timeAttack, GameModeIdsV1.level],
  playableCoordinates:
      coordinates ??
      const <AxialCoordinate>[
        AxialCoordinate(0, 0),
        AxialCoordinate(1, 0),
        AxialCoordinate(2, 0),
      ],
  distribution: TileDistributionV2(
    numberWeight: 1,
    operatorWeight: 1,
    numbers: const <WeightedNumberV2>[
      WeightedNumberV2(value: 1, weight: 1),
      WeightedNumberV2(value: 2, weight: 1),
      WeightedNumberV2(value: 3, weight: 1),
    ],
    operators: const <Operator, int>{
      Operator.add: 1,
      Operator.subtract: 1,
      Operator.multiply: 1,
      Operator.divide: 1,
    },
  ),
  levelGoal: LevelGoalV2(
    durationMs: 60000,
    targetQuota: 1,
    starScoreThresholds: const <int>[100, 150, 225],
  ),
);

BoardStateV2 boardFromTiles({
  required List<BoardTileV2> tiles,
  required int target,
  String seed = 'test-seed',
}) {
  final List<AxialCoordinate> coordinates = tiles
      .map((BoardTileV2 tile) => tile.coordinate)
      .toList();
  final BoardTopologyV2 topology = BoardTopologyV2(
    mapId: 'test-map',
    playableCoordinates: coordinates,
  );
  return BoardStateV2.create(
    seed: seed,
    topology: topology,
    tiles: tiles,
    target: target,
    revision: 0,
    lastTransition: BoardTransitionV2(
      kind: BoardTransitionKindV2.initial,
      fromRevision: -1,
      toRevision: 0,
      previousTarget: null,
      target: target,
    ),
  );
}
