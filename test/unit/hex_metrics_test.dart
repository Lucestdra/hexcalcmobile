import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/features/gameplay/flame/hex_metrics.dart';

void main() {
  test('roundToCell inverts centerOf for every cell', () {
    final HexMetrics m = HexMetrics.fit(const Size(400, 600), 2);
    for (final AxialCoordinate c in BoardGeneratorV1.enumerateCells(2)) {
      expect(m.roundToCell(m.centerOf(c)), c);
    }
  });

  test('a small nudge from a center still hits the same cell (hit slop)', () {
    final HexMetrics m = HexMetrics.fit(const Size(400, 600), 2);
    for (final AxialCoordinate c in BoardGeneratorV1.enumerateCells(2)) {
      final Offset center = m.centerOf(c);
      expect(m.roundToCell(center + Offset(m.hexSize * 0.2, 0)), c);
      expect(m.roundToCell(center - Offset(0, m.hexSize * 0.2)), c);
    }
  });

  test('each cell has six distinct corners', () {
    final HexMetrics m = HexMetrics.fit(const Size(400, 600), 2);
    final List<Offset> corners = m.cornersOf(const AxialCoordinate(0, 0));
    expect(corners.length, 6);
    expect(corners.toSet().length, 6);
  });

  test(
    'fits and hit-tests an irregular topology from its actual coordinates',
    () {
      const List<AxialCoordinate> topology = <AxialCoordinate>[
        AxialCoordinate(2, -1),
        AxialCoordinate(3, -1),
        AxialCoordinate(2, 0),
        AxialCoordinate(1, 0),
      ];
      final HexMetrics metrics = HexMetrics.fitCoordinates(
        const Size(320, 480),
        topology,
      );

      for (final AxialCoordinate coordinate in topology) {
        final Offset center = metrics.centerOf(coordinate);
        expect(center.dx, inInclusiveRange(0, 320));
        expect(center.dy, inInclusiveRange(0, 480));
        expect(metrics.roundToCell(center), coordinate);
      }
    },
  );

  test('rejects an empty authored topology', () {
    expect(
      () => HexMetrics.fitCoordinates(
        const Size(320, 480),
        const <AxialCoordinate>[],
      ),
      throwsArgumentError,
    );
  });

  test(
    'line fills every cell between two coords (fast-swipe interpolation)',
    () {
      expect(
        HexMetrics.line(
          const AxialCoordinate(0, 0),
          const AxialCoordinate(2, 0),
        ),
        <AxialCoordinate>[
          const AxialCoordinate(0, 0),
          const AxialCoordinate(1, 0),
          const AxialCoordinate(2, 0),
        ],
      );

      expect(
        HexMetrics.line(
          const AxialCoordinate(0, 0),
          const AxialCoordinate(0, 0),
        ),
        <AxialCoordinate>[const AxialCoordinate(0, 0)],
      );

      // A longer line is contiguous: endpoints correct and every step adjacent.
      final List<AxialCoordinate> diag = HexMetrics.line(
        const AxialCoordinate(-2, 2),
        const AxialCoordinate(2, -2),
      );
      expect(diag.first, const AxialCoordinate(-2, 2));
      expect(diag.last, const AxialCoordinate(2, -2));
      for (int i = 1; i < diag.length; i++) {
        expect(Hex.areAdjacent(diag[i - 1], diag[i]), isTrue);
      }
    },
  );
}
