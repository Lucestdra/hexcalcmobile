import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'v2_test_support.dart';

void main() {
  late MapCatalogV1 catalog;
  setUpAll(() {
    catalog = MapCatalogV1.fromJson(
      jsonDecode(File('assets/gameplay/maps-v1.json').readAsStringSync())
          as Map<String, dynamic>,
    );
  });

  test('canonical maps-v1 catalog contains twelve stable ordered maps', () {
    expect(catalog.version, 'maps-v1');
    expect(catalog.maps, hasLength(12));
    expect(catalog.maps.map((MapDefinitionV2 map) => map.id), <String>[
      'open-hex',
      'center-ring',
      'twin-gates',
      'diamond',
      'crescent',
      'crossroads',
      'inner-wall',
      'split-ring',
      'narrow-bridge',
      'broken-crown',
      'labyrinth',
      'operator-forge',
    ]);
    expect(catalog.map('open-hex').tier, MapTierV2.beginner);
    expect(catalog.map('crescent').levelGoal.durationMs, 75000);
    expect(catalog.map('operator-forge').levelGoal.targetQuota, 10);
    expect(catalog.map('labyrinth').blockedCoordinates, hasLength(5));
    expect(
      catalog.maps.every(
        (MapDefinitionV2 map) =>
            map.eligibleModes.contains(GameModeIdsV1.timeAttack),
      ),
      isTrue,
    );
  });

  test('parser accepts coordinate objects and compact coordinate pairs', () {
    final Map<String, dynamic> json =
        jsonDecode(File('assets/gameplay/maps-v1.json').readAsStringSync())
            as Map<String, dynamic>;
    final Map<String, dynamic> first =
        (json['maps'] as List<dynamic>).first as Map<String, dynamic>;
    first['playableCoordinates'] = <List<int>>[
      <int>[0, 0],
      <int>[1, 0],
      <int>[2, 0],
    ];
    final MapCatalogV1 parsed = MapCatalogV1.fromJson(json);
    expect(parsed.maps.first.playableCoordinates, const <AxialCoordinate>[
      AxialCoordinate(0, 0),
      AxialCoordinate(1, 0),
      AxialCoordinate(2, 0),
    ]);
  });

  test(
    'every authored map passes schema, topology, target and refill validation',
    () {
      final CatalogValidationReportV2 report = MapValidatorV2.validateCatalog(
        catalog,
        simulations: 1,
      );
      expect(
        report.catalogIssues,
        isEmpty,
        reason: report.catalogIssues
            .map((MapValidationIssueV2 issue) => issue.message)
            .join('\n'),
      );
      for (final MapValidationReportV2 map in report.maps) {
        expect(
          map.issues,
          isEmpty,
          reason:
              '${map.mapId}: ${map.issues.map((MapValidationIssueV2 issue) => '${issue.code} ${issue.message}').join(', ')}',
        );
        expect(map.expressionCount, greaterThan(0));
        expect(map.targetCount, greaterThan(0));
        expect(map.computedDifficulty, greaterThan(0));
      }
    },
  );

  test(
    'validator reports overlapping coordinates and invalid distribution',
    () {
      final MapDefinitionV2 source = simpleMap();
      final MapDefinitionV2 invalid = MapDefinitionV2(
        id: source.id,
        order: source.order,
        name: source.name,
        tier: source.tier,
        eligibleModes: source.eligibleModes,
        playableCoordinates: source.playableCoordinates,
        blockedCoordinates: <AxialCoordinate>[source.playableCoordinates.first],
        distribution: TileDistributionV2(
          numberWeight: 0,
          operatorWeight: 1,
          numbers: source.distribution.numbers,
          operators: source.distribution.operators,
        ),
        levelGoal: source.levelGoal,
      );

      final Set<String> codes = MapValidatorV2.validateMap(
        invalid,
        simulations: 0,
      ).issues.map((MapValidationIssueV2 issue) => issue.code).toSet();
      expect(codes, contains(MapValidationErrorCodesV2.coordinateOverlap));
      expect(codes, contains(MapValidationErrorCodesV2.invalidDistribution));
    },
  );
}
