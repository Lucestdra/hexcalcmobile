import 'dart:math' as math;
import 'dart:ui';

import '../domain/domain.dart';

/// Pixel layout for a pointy-top hex board. Precomputes cell centers and rounds
/// a pixel to the nearest cell for deterministic hit testing. Rounding to the
/// nearest hex gives generous, correct hit slop by construction.
class HexMetrics {
  HexMetrics._(this.hexSize, this.origin, this._centers);

  /// Distance from a cell center to a corner.
  final double hexSize;

  /// Pixel position of axial (0, 0).
  final Offset origin;

  final Map<AxialCoordinate, Offset> _centers;

  static const double _sqrt3 = 1.7320508075688772;

  /// Fits a hexagon of [radius] into [size] with a little padding.
  factory HexMetrics.fit(Size size, int radius, {double usable = 0.9}) {
    final List<AxialCoordinate> cells = BoardGeneratorV1.enumerateCells(radius);
    return HexMetrics.fitCoordinates(size, cells, usable: usable);
  }

  /// Fits an arbitrary authored topology into [size]. The coordinates include
  /// playable and visible blocked cells; omitted coordinates remain real holes
  /// and therefore do not distort centering or hit testing.
  factory HexMetrics.fitCoordinates(
    Size size,
    Iterable<AxialCoordinate> coordinates, {
    double usable = 0.9,
  }) {
    final List<AxialCoordinate> cells = coordinates.toList(growable: false);
    if (cells.isEmpty) {
      throw ArgumentError.value(
        coordinates,
        'coordinates',
        'must contain at least one visible cell',
      );
    }

    // Unit centers (hexSize == 1) and their bounding box (corner reach == 1).
    double minX = double.infinity, maxX = -double.infinity;
    double minY = double.infinity, maxY = -double.infinity;
    final Map<AxialCoordinate, Offset> unit = <AxialCoordinate, Offset>{};
    for (final AxialCoordinate c in cells) {
      final double x = _sqrt3 * (c.q + c.r / 2);
      final double y = 1.5 * c.r;
      unit[c] = Offset(x, y);
      minX = math.min(minX, x - 1);
      maxX = math.max(maxX, x + 1);
      minY = math.min(minY, y - 1);
      maxY = math.max(maxY, y + 1);
    }

    final double boardW = maxX - minX;
    final double boardH = maxY - minY;
    final double hexSize = math.min(
      size.width * usable / boardW,
      size.height * usable / boardH,
    );

    final Offset unitBoxCenter = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    final Offset widgetCenter = Offset(size.width / 2, size.height / 2);
    final Offset origin = widgetCenter - unitBoxCenter * hexSize;

    final Map<AxialCoordinate, Offset> centers = <AxialCoordinate, Offset>{
      for (final MapEntry<AxialCoordinate, Offset> e in unit.entries)
        e.key: origin + e.value * hexSize,
    };

    return HexMetrics._(hexSize, origin, centers);
  }

  Offset centerOf(AxialCoordinate c) => _centers[c] ?? _computeCenter(c);

  Offset _computeCenter(AxialCoordinate c) =>
      origin + Offset(_sqrt3 * (c.q + c.r / 2), 1.5 * c.r) * hexSize;

  /// The six corners of a pointy-top hex, for rendering.
  List<Offset> cornersOf(AxialCoordinate c) {
    final Offset center = centerOf(c);
    return <Offset>[
      for (int i = 0; i < 6; i++)
        center +
            Offset(
                  math.cos((math.pi / 180) * (60 * i - 30)),
                  math.sin((math.pi / 180) * (60 * i - 30)),
                ) *
                hexSize,
    ];
  }

  /// Rounds a pixel to the nearest axial cell.
  AxialCoordinate roundToCell(Offset px) {
    final Offset local = (px - origin) / hexSize;
    final double qf = (_sqrt3 / 3) * local.dx - (1 / 3) * local.dy;
    final double rf = (2 / 3) * local.dy;
    return _hexRound(qf, rf);
  }

  /// The cells crossed by a straight line from [a] to [b] inclusive. Used to
  /// interpolate fast pointer samples so a quick swipe never skips a cell.
  static List<AxialCoordinate> line(AxialCoordinate a, AxialCoordinate b) {
    final int n = _distance(a, b);
    if (n == 0) {
      return <AxialCoordinate>[a];
    }
    const double eps = 1e-6; // nudge off cell edges for stable rounding
    final List<AxialCoordinate> cells = <AxialCoordinate>[];
    for (int i = 0; i <= n; i++) {
      final double t = i / n;
      final double qf = a.q + (b.q - a.q) * t + eps;
      final double rf = a.r + (b.r - a.r) * t + eps;
      cells.add(_hexRound(qf, rf));
    }
    return cells;
  }

  static int _distance(AxialCoordinate a, AxialCoordinate b) {
    final int dq = (a.q - b.q).abs();
    final int dr = (a.r - b.r).abs();
    final int ds = (a.q + a.r - b.q - b.r).abs();
    return (dq + dr + ds) ~/ 2;
  }

  static AxialCoordinate _hexRound(double qf, double rf) {
    final double sf = -qf - rf;
    int q = qf.round();
    int r = rf.round();
    final int s = sf.round();

    final double dq = (q - qf).abs();
    final double dr = (r - rf).abs();
    final double ds = (s - sf).abs();

    if (dq > dr && dq > ds) {
      q = -r - s;
    } else if (dr > ds) {
      r = -q - s;
    }
    return AxialCoordinate(q, r);
  }
}
