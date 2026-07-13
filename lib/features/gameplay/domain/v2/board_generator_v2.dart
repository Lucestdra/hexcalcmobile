/// Deterministic `gen-v2` board generation, target selection, and refill.
library;

import '../drbg.dart';
import '../expression.dart';
import '../geometry.dart';
import 'board_state_v2.dart';
import 'expression_evaluator_v2.dart';
import 'map_catalog_v1.dart';
import 'swipe_chain_v2.dart';
import 'target_analyzer_v2.dart';

class TargetSelectorV2 {
  TargetSelectorV2._();

  static TargetCandidateV2 select({
    required List<TargetCandidateV2> candidates,
    required String seed,
    required MapDefinitionV2 map,
    required int revision,
    int? previousTarget,
  }) {
    if (candidates.isEmpty) {
      throw StateError('Cannot select a target from an empty candidate list');
    }

    // Avoid an immediate repeat whenever any other reachable result exists.
    List<TargetCandidateV2> pool = candidates;
    if (previousTarget != null && candidates.length > 1) {
      pool = candidates
          .where(
            (TargetCandidateV2 candidate) => candidate.result != previousTarget,
          )
          .toList(growable: false);
    }

    final int preferredOperatorCount = switch (map.tier) {
      MapTierV2.beginner => 1,
      MapTierV2.intermediate => 2,
      MapTierV2.advanced => 3,
    };
    final List<TargetCandidateV2> preferred = pool
        .where(
          (TargetCandidateV2 candidate) =>
              candidate.operatorCount == preferredOperatorCount,
        )
        .toList(growable: false);
    if (preferred.isNotEmpty) {
      pool = preferred;
    }

    final Drbg drbg = Drbg(
      'HEXCALC|${BoardGeneratorV2.generatorVersion}|target|$seed|'
      '${map.catalogVersion}|${map.id}|$revision|-|0',
    );
    return pool[drbg.nextInt(pool.length)];
  }
}

class BoardGeneratorV2 {
  BoardGeneratorV2._();

  static const String protocolId = 'target-swipe-v2';
  static const String rulesetVersion = 'rs-v2';
  static const String generatorVersion = 'gen-v2';
  static const int maxAttempts = 64;

  static BoardStateV2 generate({
    required String seed,
    required MapDefinitionV2 map,
  }) {
    _validateDistribution(map.distribution);
    final BoardTopologyV2 topology = map.topology;

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final List<BoardTileV2> tiles = <BoardTileV2>[
        for (final AxialCoordinate coordinate in map.playableCoordinates)
          _drawTile(
            seed: seed,
            map: map,
            revision: 0,
            coordinate: coordinate,
            attempt: attempt,
          ),
      ];
      final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyzeTiles(
        topology: topology,
        tiles: tiles,
      );
      if (candidates.isNotEmpty) {
        final TargetCandidateV2 target = TargetSelectorV2.select(
          candidates: candidates,
          seed: seed,
          map: map,
          revision: 0,
        );
        return BoardStateV2.create(
          seed: seed,
          topology: topology,
          tiles: tiles,
          target: target.result,
          revision: 0,
          lastTransition: BoardTransitionV2(
            kind: BoardTransitionKindV2.initial,
            fromRevision: -1,
            toRevision: 0,
            previousTarget: null,
            target: target.result,
            consumed: topology.playableCoordinates,
            attemptsUsed: attempt + 1,
          ),
        );
      }
    }

    // A valid map always has a three-cell physical path. Repairing that path
    // gives generation the same hard solvability guarantee as refills.
    final List<AxialCoordinate> repairPath = _findRepairPath(topology);
    final List<BoardTileV2> tiles = <BoardTileV2>[
      for (final AxialCoordinate coordinate in map.playableCoordinates)
        _drawTile(
          seed: seed,
          map: map,
          revision: 0,
          coordinate: coordinate,
          attempt: maxAttempts - 1,
        ),
    ];
    final List<BoardTileV2> repaired = _repairTiles(tiles, repairPath);
    final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyzeTiles(
      topology: topology,
      tiles: repaired,
    );
    if (candidates.isEmpty) {
      throw StateError(
        'Map ${map.id} cannot be repaired into a solvable board',
      );
    }
    final TargetCandidateV2 target = TargetSelectorV2.select(
      candidates: candidates,
      seed: seed,
      map: map,
      revision: 0,
    );
    return BoardStateV2.create(
      seed: seed,
      topology: topology,
      tiles: repaired,
      target: target.result,
      revision: 0,
      lastTransition: BoardTransitionV2(
        kind: BoardTransitionKindV2.repairedRefill,
        fromRevision: -1,
        toRevision: 0,
        previousTarget: null,
        target: target.result,
        consumed: topology.playableCoordinates,
        attemptsUsed: maxAttempts,
      ),
    );
  }

  /// Replaces only [consumedPath]. The returned board revision is exactly one
  /// greater than [board], and its target is proven reachable on its new tiles.
  static BoardStateV2 refill({
    required String seed,
    required MapDefinitionV2 map,
    required BoardStateV2 board,
    required List<AxialCoordinate> consumedPath,
  }) {
    if (board.topology.mapId != map.id) {
      throw ArgumentError('Board and map IDs do not match');
    }
    if (board.topology.catalogVersion != map.catalogVersion ||
        !_coordinatesEqual(
          board.topology.playableCoordinates,
          map.playableCoordinates,
        ) ||
        !_coordinatesEqual(
          board.topology.blockedCoordinates,
          map.blockedCoordinates,
        )) {
      throw ArgumentError('Board and map topologies do not match');
    }
    if (board.seed.isNotEmpty && board.seed != seed) {
      throw ArgumentError('Board and refill seeds do not match');
    }
    final ChainValidationResultV2 validation = ChainValidatorV2.validate(
      board,
      consumedPath,
    );
    if (!validation.isValid || !validation.isComplete) {
      throw ArgumentError('Only a complete valid chain can be refilled');
    }
    final ExpressionResultV2 evaluation =
        ExpressionEvaluatorV2.evaluate(<Token>[
          for (final AxialCoordinate coordinate in consumedPath)
            board.tileAt(coordinate)!.toToken(),
        ]);
    if (!evaluation.isValid || evaluation.value != board.target) {
      throw ArgumentError('Only a target-matching chain can be refilled');
    }
    _validateRepairPath(board.topology, consumedPath);
    _validateDistribution(map.distribution);
    final int revision = board.revision + 1;
    final Set<AxialCoordinate> consumed = consumedPath.toSet();

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      final List<BoardTileV2> tiles = <BoardTileV2>[
        for (final AxialCoordinate coordinate in map.playableCoordinates)
          if (consumed.contains(coordinate))
            _drawTile(
              seed: seed,
              map: map,
              revision: revision,
              coordinate: coordinate,
              attempt: attempt,
            )
          else
            board.tileAt(coordinate)!,
      ];
      final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyzeTiles(
        topology: board.topology,
        tiles: tiles,
      );
      if (candidates.isNotEmpty) {
        final TargetCandidateV2 target = TargetSelectorV2.select(
          candidates: candidates,
          seed: seed,
          map: map,
          revision: revision,
          previousTarget: board.target,
        );
        return BoardStateV2.create(
          seed: seed,
          topology: board.topology,
          tiles: tiles,
          target: target.result,
          revision: revision,
          lastTransition: BoardTransitionV2(
            kind: BoardTransitionKindV2.acceptedRefill,
            fromRevision: board.revision,
            toRevision: revision,
            previousTarget: board.target,
            target: target.result,
            consumed: consumedPath,
            attemptsUsed: attempt + 1,
          ),
        );
      }
    }

    final List<BoardTileV2> repaired = _repairTiles(board.tiles, consumedPath);
    final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyzeTiles(
      topology: board.topology,
      tiles: repaired,
    );
    if (candidates.isEmpty) {
      throw StateError('Consumed path failed deterministic solvability repair');
    }
    final TargetCandidateV2 target = TargetSelectorV2.select(
      candidates: candidates,
      seed: seed,
      map: map,
      revision: revision,
      previousTarget: board.target,
    );
    return BoardStateV2.create(
      seed: seed,
      topology: board.topology,
      tiles: repaired,
      target: target.result,
      revision: revision,
      lastTransition: BoardTransitionV2(
        kind: BoardTransitionKindV2.repairedRefill,
        fromRevision: board.revision,
        toRevision: revision,
        previousTarget: board.target,
        target: target.result,
        consumed: consumedPath,
        attemptsUsed: maxAttempts,
      ),
    );
  }

  static BoardTileV2 _drawTile({
    required String seed,
    required MapDefinitionV2 map,
    required int revision,
    required AxialCoordinate coordinate,
    required int attempt,
  }) {
    final Drbg drbg = Drbg(
      'HEXCALC|$generatorVersion|tile|$seed|${map.catalogVersion}|${map.id}|'
      '$revision|${coordinate.q},${coordinate.r}|$attempt',
    );
    final TileDistributionV2 distribution = map.distribution;
    final int kindDraw = drbg.nextInt(distribution.tileKindTotal);
    if (kindDraw < distribution.numberWeight) {
      final int draw = drbg.nextInt(distribution.numberTotal);
      int cursor = 0;
      for (final WeightedNumberV2 entry in distribution.numbers) {
        cursor += entry.weight;
        if (draw < cursor) {
          return BoardTileV2.number(coordinate, entry.value);
        }
      }
    } else {
      final int draw = drbg.nextInt(distribution.operatorTotal);
      int cursor = 0;
      for (final Operator operator in Operator.values) {
        cursor += distribution.operators[operator] ?? 0;
        if (draw < cursor) {
          return BoardTileV2.op(coordinate, operator);
        }
      }
    }
    throw StateError('Weighted draw escaped its distribution');
  }

  static List<BoardTileV2> _repairTiles(
    Iterable<BoardTileV2> original,
    List<AxialCoordinate> repairPath,
  ) {
    final Map<AxialCoordinate, int> pathIndex = <AxialCoordinate, int>{
      for (int index = 0; index < repairPath.length; index++)
        repairPath[index]: index,
    };
    return <BoardTileV2>[
      for (final BoardTileV2 tile in original)
        if (pathIndex[tile.coordinate] case final int index)
          index.isEven
              ? BoardTileV2.number(tile.coordinate, 1)
              : BoardTileV2.op(tile.coordinate, Operator.add)
        else
          tile,
    ];
  }

  static List<AxialCoordinate> _findRepairPath(BoardTopologyV2 topology) {
    for (final AxialCoordinate start in topology.playableCoordinates) {
      for (final AxialCoordinate firstDirection in Hex.directions) {
        final AxialCoordinate middle = AxialCoordinate(
          start.q + firstDirection.q,
          start.r + firstDirection.r,
        );
        if (!topology.isPlayable(middle)) {
          continue;
        }
        for (final AxialCoordinate secondDirection in Hex.directions) {
          final AxialCoordinate end = AxialCoordinate(
            middle.q + secondDirection.q,
            middle.r + secondDirection.r,
          );
          if (end != start && topology.isPlayable(end)) {
            return <AxialCoordinate>[start, middle, end];
          }
        }
      }
    }
    throw StateError('Topology needs at least one simple three-cell path');
  }

  static void _validateRepairPath(
    BoardTopologyV2 topology,
    List<AxialCoordinate> path,
  ) {
    if (path.length < 3 || path.length > 7 || path.length.isEven) {
      throw ArgumentError('Consumed path must contain 3, 5, or 7 cells');
    }
    final Set<AxialCoordinate> seen = <AxialCoordinate>{};
    for (int index = 0; index < path.length; index++) {
      if (!topology.isPlayable(path[index])) {
        throw ArgumentError('Consumed path contains a non-playable coordinate');
      }
      if (!seen.add(path[index])) {
        throw ArgumentError('Consumed path repeats a coordinate');
      }
      if (index > 0 && !Hex.areAdjacent(path[index - 1], path[index])) {
        throw ArgumentError('Consumed path contains a non-adjacent step');
      }
    }
  }

  static void _validateDistribution(TileDistributionV2 distribution) {
    if (distribution.numberWeight <= 0 ||
        distribution.operatorWeight <= 0 ||
        distribution.numberTotal <= 0 ||
        distribution.operatorTotal <= 0) {
      throw ArgumentError('All distribution totals must be positive');
    }
    if (distribution.numbers.any(
      (WeightedNumberV2 entry) => entry.value < 0 || entry.weight <= 0,
    )) {
      throw ArgumentError(
        'Number values must be non-negative with positive weights',
      );
    }
    if (distribution.operators.values.any((int weight) => weight < 0)) {
      throw ArgumentError('Operator weights cannot be negative');
    }
  }

  static bool _coordinatesEqual(
    List<AxialCoordinate> a,
    List<AxialCoordinate> b,
  ) {
    if (a.length != b.length) {
      return false;
    }
    for (int index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }
}
