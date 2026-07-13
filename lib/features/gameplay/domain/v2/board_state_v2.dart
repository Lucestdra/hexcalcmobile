/// Immutable target-swipe board models for protocol v2.
library;

import '../expression.dart';
import '../geometry.dart';

int compareAxialCoordinatesV2(AxialCoordinate a, AxialCoordinate b) {
  final int q = a.q.compareTo(b.q);
  return q != 0 ? q : a.r.compareTo(b.r);
}

enum BoardTileKindV2 { number, operator }

class BoardTileV2 {
  const BoardTileV2._({
    required this.coordinate,
    required this.kind,
    required this.number,
    required this.operator,
  });

  factory BoardTileV2.number(AxialCoordinate coordinate, int number) =>
      BoardTileV2._(
        coordinate: coordinate,
        kind: BoardTileKindV2.number,
        number: number,
        operator: null,
      );

  factory BoardTileV2.op(AxialCoordinate coordinate, Operator operator) =>
      BoardTileV2._(
        coordinate: coordinate,
        kind: BoardTileKindV2.operator,
        number: null,
        operator: operator,
      );

  final AxialCoordinate coordinate;
  final BoardTileKindV2 kind;
  final int? number;
  final Operator? operator;

  Token toToken() => switch (kind) {
    BoardTileKindV2.number => Token.number(number!),
    BoardTileKindV2.operator => Token.op(operator!),
  };

  String get displayText => switch (kind) {
    BoardTileKindV2.number => number.toString(),
    BoardTileKindV2.operator => switch (operator!) {
      Operator.add => '+',
      Operator.subtract => '−',
      Operator.multiply => '×',
      Operator.divide => '÷',
    },
  };

  @override
  bool operator ==(Object other) =>
      other is BoardTileV2 &&
      other.coordinate == coordinate &&
      other.kind == kind &&
      other.number == number &&
      other.operator == operator;

  @override
  int get hashCode => Object.hash(coordinate, kind, number, operator);
}

/// Immutable map topology. Holes are coordinates absent from both lists;
/// blocked coordinates are visible but never carry a tile.
class BoardTopologyV2 {
  BoardTopologyV2({
    this.catalogVersion = 'maps-v1',
    required this.mapId,
    required Iterable<AxialCoordinate> playableCoordinates,
    Iterable<AxialCoordinate> blockedCoordinates = const <AxialCoordinate>[],
  }) : playableCoordinates = List<AxialCoordinate>.unmodifiable(
         playableCoordinates,
       ),
       blockedCoordinates = List<AxialCoordinate>.unmodifiable(
         blockedCoordinates,
       ),
       _playable = Set<AxialCoordinate>.unmodifiable(playableCoordinates),
       _blocked = Set<AxialCoordinate>.unmodifiable(blockedCoordinates);

  final String catalogVersion;
  final String mapId;
  final List<AxialCoordinate> playableCoordinates;
  final List<AxialCoordinate> blockedCoordinates;
  final Set<AxialCoordinate> _playable;
  final Set<AxialCoordinate> _blocked;

  bool isPlayable(AxialCoordinate coordinate) => _playable.contains(coordinate);
  bool isBlocked(AxialCoordinate coordinate) => _blocked.contains(coordinate);

  List<AxialCoordinate> get layoutCoordinates =>
      List<AxialCoordinate>.unmodifiable(
        <AxialCoordinate>[...playableCoordinates, ...blockedCoordinates]
          ..sort(compareAxialCoordinatesV2),
      );
}

enum BoardTransitionKindV2 { initial, acceptedRefill, repairedRefill }

class BoardTransitionV2 {
  BoardTransitionV2({
    required this.kind,
    required this.fromRevision,
    required this.toRevision,
    required this.previousTarget,
    required this.target,
    Iterable<AxialCoordinate> consumed = const <AxialCoordinate>[],
    this.attemptsUsed = 1,
  }) : consumed = List<AxialCoordinate>.unmodifiable(consumed);

  final BoardTransitionKindV2 kind;
  final int fromRevision;
  final int toRevision;
  final int? previousTarget;
  final int target;
  final List<AxialCoordinate> consumed;
  final int attemptsUsed;

  bool get usedRepair => kind == BoardTransitionKindV2.repairedRefill;
  List<AxialCoordinate> get changedCoordinates => consumed;
}

class BoardStateV2 {
  BoardStateV2._({
    required this.seed,
    required this.topology,
    required this.tiles,
    required this.tilesByCoordinate,
    required this.target,
    required this.revision,
    required this.lastTransition,
  });

  factory BoardStateV2.create({
    String seed = '',
    required BoardTopologyV2 topology,
    required Iterable<BoardTileV2> tiles,
    required int target,
    required int revision,
    required BoardTransitionV2 lastTransition,
  }) {
    final List<BoardTileV2> ordered = List<BoardTileV2>.from(tiles);
    final Map<AxialCoordinate, BoardTileV2> byCoordinate =
        <AxialCoordinate, BoardTileV2>{};
    for (final BoardTileV2 tile in ordered) {
      if (!topology.isPlayable(tile.coordinate)) {
        throw ArgumentError.value(
          tile.coordinate,
          'tiles',
          'Tile is not on a playable coordinate',
        );
      }
      if (byCoordinate.containsKey(tile.coordinate)) {
        throw ArgumentError.value(
          tile.coordinate,
          'tiles',
          'Duplicate tile coordinate',
        );
      }
      byCoordinate[tile.coordinate] = tile;
    }
    if (byCoordinate.length != topology.playableCoordinates.length ||
        topology.playableCoordinates.any(
          (AxialCoordinate coordinate) => !byCoordinate.containsKey(coordinate),
        )) {
      throw ArgumentError(
        'Every playable coordinate must have exactly one tile',
      );
    }
    ordered.sort(
      (BoardTileV2 a, BoardTileV2 b) =>
          compareAxialCoordinatesV2(a.coordinate, b.coordinate),
    );
    return BoardStateV2._(
      topology: topology,
      seed: seed,
      tiles: List<BoardTileV2>.unmodifiable(ordered),
      tilesByCoordinate: Map<AxialCoordinate, BoardTileV2>.unmodifiable(
        byCoordinate,
      ),
      target: target,
      revision: revision,
      lastTransition: lastTransition,
    );
  }

  final BoardTopologyV2 topology;
  final String seed;
  final List<BoardTileV2> tiles;
  final Map<AxialCoordinate, BoardTileV2> tilesByCoordinate;
  final int target;
  final int revision;
  final BoardTransitionV2 lastTransition;

  BoardTileV2? tileAt(AxialCoordinate coordinate) =>
      tilesByCoordinate[coordinate];
}
