/// Deterministic authored-map validation and difficulty reporting.
library;

import '../geometry.dart';
import 'board_generator_v2.dart';
import 'board_state_v2.dart';
import 'map_catalog_v1.dart';
import 'mode_catalog_v1.dart';
import 'target_analyzer_v2.dart';

class MapValidationErrorCodesV2 {
  MapValidationErrorCodesV2._();

  static const String catalogVersion = 'CATALOG_VERSION';
  static const String duplicateMapId = 'DUPLICATE_MAP_ID';
  static const String duplicateMapOrder = 'DUPLICATE_MAP_ORDER';
  static const String invalidId = 'INVALID_ID';
  static const String coordinateOrder = 'COORDINATE_ORDER';
  static const String duplicateCoordinate = 'DUPLICATE_COORDINATE';
  static const String coordinateOverlap = 'COORDINATE_OVERLAP';
  static const String insufficientTopology = 'INSUFFICIENT_TOPOLOGY';
  static const String disconnectedTopology = 'DISCONNECTED_TOPOLOGY';
  static const String invalidDistribution = 'INVALID_DISTRIBUTION';
  static const String invalidMode = 'INVALID_MODE';
  static const String invalidLevelGoal = 'INVALID_LEVEL_GOAL';
  static const String unsolvable = 'UNSOLVABLE';
  static const String insufficientExpressions = 'INSUFFICIENT_EXPRESSIONS';
  static const String simulationFailure = 'SIMULATION_FAILURE';
}

class MapValidationIssueV2 {
  const MapValidationIssueV2({required this.code, required this.message});
  final String code;
  final String message;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'code': code,
    'message': message,
  };
}

class MapValidationReportV2 {
  MapValidationReportV2({
    required this.mapId,
    required Iterable<MapValidationIssueV2> issues,
    required this.expressionCount,
    required this.targetCount,
    required this.computedDifficulty,
    required this.simulations,
    required this.refillRecoveryUses,
  }) : issues = List<MapValidationIssueV2>.unmodifiable(issues);

  final String mapId;
  final List<MapValidationIssueV2> issues;
  final int expressionCount;
  final int targetCount;
  final int computedDifficulty;
  final int simulations;
  final int refillRecoveryUses;

  bool get isValid => issues.isEmpty;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mapId': mapId,
    'valid': isValid,
    'issues': issues
        .map((MapValidationIssueV2 issue) => issue.toJson())
        .toList(),
    'expressionCount': expressionCount,
    'targetCount': targetCount,
    'computedDifficulty': computedDifficulty,
    'simulations': simulations,
    'refillRecoveryUses': refillRecoveryUses,
  };
}

class CatalogValidationReportV2 {
  CatalogValidationReportV2({
    required this.catalogVersion,
    required Iterable<MapValidationIssueV2> catalogIssues,
    required Iterable<MapValidationReportV2> maps,
  }) : catalogIssues = List<MapValidationIssueV2>.unmodifiable(catalogIssues),
       maps = List<MapValidationReportV2>.unmodifiable(maps);

  final String catalogVersion;
  final List<MapValidationIssueV2> catalogIssues;
  final List<MapValidationReportV2> maps;

  bool get isValid =>
      catalogIssues.isEmpty &&
      maps.every((MapValidationReportV2 report) => report.isValid);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'catalogVersion': catalogVersion,
    'valid': isValid,
    'catalogIssues': catalogIssues
        .map((MapValidationIssueV2 issue) => issue.toJson())
        .toList(),
    'maps': maps
        .map((MapValidationReportV2 report) => report.toJson())
        .toList(),
  };
}

class MapValidatorV2 {
  MapValidatorV2._();

  static const int defaultSimulations = 3;
  static const int refillStepsPerSimulation = 3;
  static const int minimumExpressions = 5;

  static CatalogValidationReportV2 validateCatalog(
    MapCatalogV1 catalog, {
    int simulations = defaultSimulations,
  }) {
    final List<MapValidationIssueV2> issues = <MapValidationIssueV2>[];
    if (catalog.version != MapCatalogV1.catalogVersionId) {
      issues.add(
        MapValidationIssueV2(
          code: MapValidationErrorCodesV2.catalogVersion,
          message:
              'Expected ${MapCatalogV1.catalogVersionId}, got ${catalog.version}',
        ),
      );
    }
    final Set<String> ids = <String>{};
    final Set<int> orders = <int>{};
    for (final MapDefinitionV2 map in catalog.maps) {
      if (!ids.add(map.id)) {
        issues.add(
          MapValidationIssueV2(
            code: MapValidationErrorCodesV2.duplicateMapId,
            message: 'Duplicate map ID ${map.id}',
          ),
        );
      }
      if (!orders.add(map.order)) {
        issues.add(
          MapValidationIssueV2(
            code: MapValidationErrorCodesV2.duplicateMapOrder,
            message: 'Duplicate map order ${map.order}',
          ),
        );
      }
    }
    if (catalog.maps.length != 12) {
      issues.add(
        MapValidationIssueV2(
          code: 'MAP_COUNT',
          message: 'Expected 12 maps, got ${catalog.maps.length}',
        ),
      );
    }
    return CatalogValidationReportV2(
      catalogVersion: catalog.version,
      catalogIssues: issues,
      maps: <MapValidationReportV2>[
        for (final MapDefinitionV2 map in catalog.maps)
          validateMap(map, simulations: simulations),
      ],
    );
  }

  static MapValidationReportV2 validateMap(
    MapDefinitionV2 map, {
    int simulations = defaultSimulations,
  }) {
    final List<MapValidationIssueV2> issues = _validateStructure(map);
    int expressionCount = 0;
    int targetCount = 0;
    int difficultyTotal = 0;
    int difficultyCandidates = 0;
    int recoveryUses = 0;

    if (issues.isEmpty) {
      for (int simulation = 0; simulation < simulations; simulation++) {
        try {
          final String seed = 'map-validator-$simulation';
          BoardStateV2 board = BoardGeneratorV2.generate(seed: seed, map: map);
          if (board.lastTransition.usedRepair) {
            recoveryUses++;
          }
          for (int step = 0; step <= refillStepsPerSimulation; step++) {
            final List<TargetCandidateV2> candidates = TargetAnalyzerV2.analyze(
              board,
            );
            final TargetCandidateV2? target = candidates
                .where(
                  (TargetCandidateV2 candidate) =>
                      candidate.result == board.target,
                )
                .firstOrNull;
            if (target == null) {
              issues.add(
                MapValidationIssueV2(
                  code: MapValidationErrorCodesV2.unsolvable,
                  message:
                      'Simulation $simulation revision ${board.revision} '
                      'published an unreachable target',
                ),
              );
              break;
            }
            final int expressions = candidates.fold<int>(
              0,
              (int total, TargetCandidateV2 candidate) =>
                  total + candidate.solutionCount,
            );
            expressionCount += expressions;
            targetCount += candidates.length;
            difficultyTotal += target.difficulty;
            difficultyCandidates++;
            if (expressions < minimumExpressions) {
              issues.add(
                MapValidationIssueV2(
                  code: MapValidationErrorCodesV2.insufficientExpressions,
                  message:
                      'Simulation $simulation revision ${board.revision} '
                      'has only $expressions valid expressions',
                ),
              );
            }
            if (step < refillStepsPerSimulation) {
              board = BoardGeneratorV2.refill(
                seed: seed,
                map: map,
                board: board,
                consumedPath: target.canonicalHintPath,
              );
              if (board.lastTransition.usedRepair) {
                recoveryUses++;
              }
            }
          }
        } on Object catch (error) {
          issues.add(
            MapValidationIssueV2(
              code: MapValidationErrorCodesV2.simulationFailure,
              message: 'Simulation $simulation failed: $error',
            ),
          );
        }
      }
    }

    return MapValidationReportV2(
      mapId: map.id,
      issues: issues,
      expressionCount: expressionCount,
      targetCount: targetCount,
      computedDifficulty: difficultyCandidates == 0
          ? 0
          : difficultyTotal ~/ difficultyCandidates,
      simulations: simulations,
      refillRecoveryUses: recoveryUses,
    );
  }

  static List<MapValidationIssueV2> _validateStructure(MapDefinitionV2 map) {
    final List<MapValidationIssueV2> issues = <MapValidationIssueV2>[];
    void issue(String code, String message) =>
        issues.add(MapValidationIssueV2(code: code, message: message));

    if (!RegExp(r'^[a-z0-9]+(?:-[a-z0-9]+)*$').hasMatch(map.id)) {
      issue(MapValidationErrorCodesV2.invalidId, 'Invalid map ID ${map.id}');
    }
    if (map.playableCoordinates.length < 3) {
      issue(
        MapValidationErrorCodesV2.insufficientTopology,
        'At least three playable coordinates are required',
      );
    }
    _checkCoordinates(map.playableCoordinates, 'playable', issues);
    _checkCoordinates(map.blockedCoordinates, 'blocked', issues);
    final Set<AxialCoordinate> playable = map.playableCoordinates.toSet();
    if (map.blockedCoordinates.any(playable.contains)) {
      issue(
        MapValidationErrorCodesV2.coordinateOverlap,
        'Playable and blocked coordinates overlap',
      );
    }
    if (playable.isNotEmpty) {
      final Set<AxialCoordinate> reached = <AxialCoordinate>{};
      final List<AxialCoordinate> pending = <AxialCoordinate>[
        map.playableCoordinates.first,
      ];
      while (pending.isNotEmpty) {
        final AxialCoordinate coordinate = pending.removeLast();
        if (!reached.add(coordinate)) {
          continue;
        }
        pending.addAll(Hex.neighbors(coordinate).where(playable.contains));
      }
      if (reached.length != playable.length) {
        issue(
          MapValidationErrorCodesV2.disconnectedTopology,
          'Playable topology has disconnected regions',
        );
      }
    }
    if (!_hasThreeCellPath(map.topology)) {
      issue(
        MapValidationErrorCodesV2.insufficientTopology,
        'No simple three-cell path exists',
      );
    }
    final TileDistributionV2 distribution = map.distribution;
    if (distribution.numberWeight <= 0 ||
        distribution.operatorWeight <= 0 ||
        distribution.numberTotal <= 0 ||
        distribution.operatorTotal <= 0 ||
        distribution.numbers.any(
          (WeightedNumberV2 number) => number.value < 0 || number.weight <= 0,
        ) ||
        distribution.operators.values.any((int weight) => weight <= 0)) {
      issue(
        MapValidationErrorCodesV2.invalidDistribution,
        'Distribution weights/values are invalid',
      );
    }
    final Set<int> numberValues = <int>{};
    if (distribution.numbers.any(
      (WeightedNumberV2 number) => !numberValues.add(number.value),
    )) {
      issue(
        MapValidationErrorCodesV2.invalidDistribution,
        'Number distribution contains duplicate values',
      );
    }
    final Set<String> validModes = ModeCatalogV1.definitions
        .map((GameModeDefinitionV2 mode) => mode.id)
        .toSet();
    if (map.eligibleModes.isEmpty ||
        map.eligibleModes.any((String mode) => !validModes.contains(mode))) {
      issue(
        MapValidationErrorCodesV2.invalidMode,
        'Map contains no modes or an unknown eligible mode',
      );
    }
    final List<int> thresholds = map.levelGoal.starScoreThresholds;
    if (map.levelGoal.durationMs <= 0 ||
        map.levelGoal.targetQuota <= 0 ||
        thresholds.length != 3 ||
        thresholds[0] <= 0 ||
        thresholds[1] <= thresholds[0] ||
        thresholds[2] <= thresholds[1]) {
      issue(
        MapValidationErrorCodesV2.invalidLevelGoal,
        'Level goal duration/quota/star thresholds are invalid',
      );
    } else {
      final int baseScore = map.levelGoal.targetQuota * 100;
      if (thresholds[0] != baseScore ||
          thresholds[1] != baseScore * 3 ~/ 2 ||
          thresholds[2] != baseScore * 9 ~/ 4) {
        issue(
          MapValidationErrorCodesV2.invalidLevelGoal,
          'Star thresholds must be 1x, 1.5x and 2.25x quota base score',
        );
      }
    }
    return issues;
  }

  static void _checkCoordinates(
    List<AxialCoordinate> coordinates,
    String label,
    List<MapValidationIssueV2> issues,
  ) {
    if (coordinates.toSet().length != coordinates.length) {
      issues.add(
        MapValidationIssueV2(
          code: MapValidationErrorCodesV2.duplicateCoordinate,
          message: '$label coordinates contain duplicates',
        ),
      );
    }
    for (int index = 1; index < coordinates.length; index++) {
      if (compareAxialCoordinatesV2(
            coordinates[index - 1],
            coordinates[index],
          ) >=
          0) {
        issues.add(
          MapValidationIssueV2(
            code: MapValidationErrorCodesV2.coordinateOrder,
            message: '$label coordinates are not in canonical q/r order',
          ),
        );
        break;
      }
    }
  }

  static bool _hasThreeCellPath(BoardTopologyV2 topology) {
    for (final AxialCoordinate first in topology.playableCoordinates) {
      for (final AxialCoordinate second in Hex.neighbors(first)) {
        if (!topology.isPlayable(second)) {
          continue;
        }
        if (Hex.neighbors(second).any(
          (AxialCoordinate third) =>
              third != first && topology.isPlayable(third),
        )) {
          return true;
        }
      }
    }
    return false;
  }
}

extension _FirstOrNullV2<T> on Iterable<T> {
  T? get firstOrNull {
    final Iterator<T> iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
