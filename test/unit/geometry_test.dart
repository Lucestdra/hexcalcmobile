import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

/// Hand-written unit tests for hex geometry primitives (beyond the golden fixtures).
void main() {
  test('there are exactly six directions', () {
    expect(Hex.directions.length, 6);
  });

  test('origin has six distinct neighbors, none equal to origin', () {
    const AxialCoordinate origin = AxialCoordinate(0, 0);
    final List<AxialCoordinate> neighbors = Hex.neighbors(origin);

    expect(neighbors.length, 6);
    expect(neighbors.toSet().length, 6);
    expect(neighbors.contains(origin), isFalse);
  });

  test('all six neighbors are adjacent both ways (symmetric)', () {
    const AxialCoordinate origin = AxialCoordinate(3, -2);
    for (final AxialCoordinate n in Hex.neighbors(origin)) {
      expect(Hex.areAdjacent(origin, n), isTrue);
      expect(Hex.areAdjacent(n, origin), isTrue);
    }
  });

  test('a cell is not adjacent to itself', () {
    const AxialCoordinate c = AxialCoordinate(1, 1);
    expect(Hex.areAdjacent(c, c), isFalse);
  });

  test('non-neighbors are not adjacent', () {
    const AxialCoordinate a = AxialCoordinate(0, 0);
    expect(Hex.areAdjacent(a, const AxialCoordinate(2, 0)), isFalse);
    expect(Hex.areAdjacent(a, const AxialCoordinate(1, 1)), isFalse);
    expect(Hex.areAdjacent(a, const AxialCoordinate(2, -1)), isFalse);
  });
}
