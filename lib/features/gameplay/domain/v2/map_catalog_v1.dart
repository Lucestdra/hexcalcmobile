/// Data-driven map catalog models and parser for `maps-v1`.
library;

import '../expression.dart';
import '../geometry.dart';
import 'board_state_v2.dart';

enum MapTierV2 { beginner, intermediate, advanced }

class WeightedNumberV2 {
  const WeightedNumberV2({required this.value, required this.weight});

  final int value;
  final int weight;
}

class TileDistributionV2 {
  TileDistributionV2({
    required this.numberWeight,
    required this.operatorWeight,
    required Iterable<WeightedNumberV2> numbers,
    required Map<Operator, int> operators,
  }) : numbers = List<WeightedNumberV2>.unmodifiable(numbers),
       operators = Map<Operator, int>.unmodifiable(operators);

  final int numberWeight;
  final int operatorWeight;
  final List<WeightedNumberV2> numbers;
  final Map<Operator, int> operators;

  int get tileKindTotal => numberWeight + operatorWeight;
  int get numberTotal => numbers.fold(
    0,
    (int total, WeightedNumberV2 entry) => total + entry.weight,
  );
  int get operatorTotal =>
      operators.values.fold(0, (int total, int weight) => total + weight);
}

class LevelGoalV2 {
  LevelGoalV2({
    required this.durationMs,
    required this.targetQuota,
    required Iterable<int> starScoreThresholds,
  }) : starScoreThresholds = List<int>.unmodifiable(starScoreThresholds);

  final int durationMs;
  final int targetQuota;
  final List<int> starScoreThresholds;
}

class MapDefinitionV2 {
  MapDefinitionV2({
    this.catalogVersion = MapCatalogV1.catalogVersionId,
    required this.id,
    required this.order,
    required this.name,
    required this.tier,
    required Iterable<String> eligibleModes,
    required Iterable<AxialCoordinate> playableCoordinates,
    Iterable<AxialCoordinate> blockedCoordinates = const <AxialCoordinate>[],
    required this.distribution,
    required this.levelGoal,
  }) : eligibleModes = Set<String>.unmodifiable(eligibleModes),
       playableCoordinates = List<AxialCoordinate>.unmodifiable(
         playableCoordinates,
       ),
       blockedCoordinates = List<AxialCoordinate>.unmodifiable(
         blockedCoordinates,
       );

  final String catalogVersion;
  final String id;
  final int order;
  final String name;
  final MapTierV2 tier;
  final Set<String> eligibleModes;
  final List<AxialCoordinate> playableCoordinates;
  final List<AxialCoordinate> blockedCoordinates;
  final TileDistributionV2 distribution;
  final LevelGoalV2 levelGoal;

  BoardTopologyV2 get topology => BoardTopologyV2(
    catalogVersion: catalogVersion,
    mapId: id,
    playableCoordinates: playableCoordinates,
    blockedCoordinates: blockedCoordinates,
  );
}

class MapCatalogV1 {
  MapCatalogV1._({required this.version, required this.maps})
    : mapsById = Map<String, MapDefinitionV2>.unmodifiable(
        <String, MapDefinitionV2>{
          for (final MapDefinitionV2 map in maps) map.id: map,
        },
      );

  static const String catalogVersionId = 'maps-v1';

  factory MapCatalogV1.fromJson(Map<String, dynamic> json) {
    final String version = _string(json, 'catalogVersion', 'catalog');
    final List<dynamic> rawMaps = _list(json, 'maps', 'catalog');
    final List<MapDefinitionV2> maps = <MapDefinitionV2>[];
    for (int index = 0; index < rawMaps.length; index++) {
      final Map<String, dynamic> map = _map(rawMaps[index], 'maps[$index]');
      maps.add(_parseMap(version, map, index));
    }
    maps.sort(
      (MapDefinitionV2 a, MapDefinitionV2 b) => a.order.compareTo(b.order),
    );
    return MapCatalogV1._(
      version: version,
      maps: List<MapDefinitionV2>.unmodifiable(maps),
    );
  }

  final String version;
  final List<MapDefinitionV2> maps;
  final Map<String, MapDefinitionV2> mapsById;

  MapDefinitionV2 map(String id) {
    final MapDefinitionV2? result = mapsById[id];
    if (result == null) {
      throw ArgumentError.value(id, 'id', 'Unknown map');
    }
    return result;
  }

  static MapDefinitionV2 _parseMap(
    String catalogVersion,
    Map<String, dynamic> json,
    int index,
  ) {
    final String context = 'maps[$index]';
    final Map<String, dynamic> distribution = _map(
      json['distribution'],
      '$context.distribution',
    );
    final List<dynamic> rawNumbers = _list(
      distribution,
      'numbers',
      '$context.distribution',
    );
    final List<WeightedNumberV2> numbers = <WeightedNumberV2>[
      for (int numberIndex = 0; numberIndex < rawNumbers.length; numberIndex++)
        _parseNumberWeight(
          _map(
            rawNumbers[numberIndex],
            '$context.distribution.numbers[$numberIndex]',
          ),
          '$context.distribution.numbers[$numberIndex]',
        ),
    ];
    final Map<String, dynamic> operatorJson = _map(
      distribution['operators'],
      '$context.distribution.operators',
    );
    final Map<String, dynamic> levelGoal = _map(
      json['levelGoal'],
      '$context.levelGoal',
    );

    return MapDefinitionV2(
      catalogVersion: catalogVersion,
      id: _string(json, 'id', context),
      order: _integer(json, 'order', context),
      name: json['name'] is String
          ? json['name'] as String
          : _string(json, 'id', context),
      tier: _parseTier(_string(json, 'tier', context), '$context.tier'),
      eligibleModes: _list(json, 'eligibleModes', context).map((dynamic value) {
        if (value is! String) {
          throw FormatException('$context.eligibleModes must be strings');
        }
        return value;
      }),
      playableCoordinates: _parseCoordinates(
        _list(json, 'playableCoordinates', context),
        '$context.playableCoordinates',
      ),
      blockedCoordinates: _parseCoordinates(
        json['blockedCoordinates'] == null
            ? const <dynamic>[]
            : _list(json, 'blockedCoordinates', context),
        '$context.blockedCoordinates',
      ),
      distribution: TileDistributionV2(
        numberWeight: _integer(
          distribution,
          'numberWeight',
          '$context.distribution',
        ),
        operatorWeight: _integer(
          distribution,
          'operatorWeight',
          '$context.distribution',
        ),
        numbers: numbers,
        operators: <Operator, int>{
          Operator.add: _integer(
            operatorJson,
            'add',
            '$context.distribution.operators',
          ),
          Operator.subtract: _integer(
            operatorJson,
            'subtract',
            '$context.distribution.operators',
          ),
          Operator.multiply: _integer(
            operatorJson,
            'multiply',
            '$context.distribution.operators',
          ),
          Operator.divide: _integer(
            operatorJson,
            'divide',
            '$context.distribution.operators',
          ),
        },
      ),
      levelGoal: LevelGoalV2(
        durationMs: _integer(levelGoal, 'durationMs', '$context.levelGoal'),
        targetQuota: _integer(levelGoal, 'targetQuota', '$context.levelGoal'),
        starScoreThresholds:
            _list(levelGoal, 'starScoreThresholds', '$context.levelGoal').map((
              dynamic value,
            ) {
              if (value is! int) {
                throw FormatException(
                  '$context.levelGoal.starScoreThresholds must be integers',
                );
              }
              return value;
            }),
      ),
    );
  }

  static WeightedNumberV2 _parseNumberWeight(
    Map<String, dynamic> json,
    String context,
  ) => WeightedNumberV2(
    value: _integer(json, 'value', context),
    weight: _integer(json, 'weight', context),
  );

  static List<AxialCoordinate> _parseCoordinates(
    List<dynamic> raw,
    String context,
  ) => List<AxialCoordinate>.generate(raw.length, (int index) {
    final dynamic value = raw[index];
    if (value is List<dynamic> &&
        value.length == 2 &&
        value[0] is int &&
        value[1] is int) {
      return AxialCoordinate(value[0] as int, value[1] as int);
    }
    if (value is Map<String, dynamic> &&
        value['q'] is int &&
        value['r'] is int) {
      return AxialCoordinate(value['q'] as int, value['r'] as int);
    }
    throw FormatException('$context[$index] must be [q, r] or {q, r}');
  });

  static MapTierV2 _parseTier(String value, String context) => switch (value) {
    'beginner' => MapTierV2.beginner,
    'intermediate' => MapTierV2.intermediate,
    'advanced' => MapTierV2.advanced,
    _ => throw FormatException('$context has unknown tier "$value"'),
  };

  static Map<String, dynamic> _map(dynamic value, String context) {
    if (value is! Map<String, dynamic>) {
      throw FormatException('$context must be an object');
    }
    return value;
  }

  static List<dynamic> _list(
    Map<String, dynamic> json,
    String key,
    String context,
  ) {
    final dynamic value = json[key];
    if (value is! List<dynamic>) {
      throw FormatException('$context.$key must be an array');
    }
    return value;
  }

  static String _string(Map<String, dynamic> json, String key, String context) {
    final dynamic value = json[key];
    if (value is! String) {
      throw FormatException('$context.$key must be a string');
    }
    return value;
  }

  static int _integer(Map<String, dynamic> json, String key, String context) {
    final dynamic value = json[key];
    if (value is! int) {
      throw FormatException('$context.$key must be an integer');
    }
    return value;
  }
}
