/// Hex geometry & path validation — Dart twin of the C# domain.
///
/// Must produce identical results to the backend and to the adjacency/v1 golden
/// fixtures. See ../../../../test/contract/fixtures and the backend spec
/// docs/gameplay/hex-geometry.md.
library;

/// A hex cell position in axial coordinates `(q, r)`.
class AxialCoordinate {
  const AxialCoordinate(this.q, this.r);

  final int q;
  final int r;

  @override
  bool operator ==(Object other) =>
      other is AxialCoordinate && other.q == q && other.r == r;

  @override
  int get hashCode => Object.hash(q, r);

  @override
  String toString() => '($q, $r)';
}

/// Canonical hex adjacency. The six direction vectors are fixed in this order;
/// the ordering is part of the deterministic contract.
class Hex {
  Hex._();

  static const List<AxialCoordinate> directions = <AxialCoordinate>[
    AxialCoordinate(1, 0),
    AxialCoordinate(1, -1),
    AxialCoordinate(0, -1),
    AxialCoordinate(-1, 0),
    AxialCoordinate(-1, 1),
    AxialCoordinate(0, 1),
  ];

  /// True when [b] is one of the six neighbors of [a]. A cell is never adjacent
  /// to itself.
  static bool areAdjacent(AxialCoordinate a, AxialCoordinate b) {
    final int dq = b.q - a.q;
    final int dr = b.r - a.r;
    for (final AxialCoordinate d in directions) {
      if (d.q == dq && d.r == dr) {
        return true;
      }
    }
    return false;
  }

  /// The six neighbors of [c] in canonical direction order.
  static List<AxialCoordinate> neighbors(AxialCoordinate c) =>
      <AxialCoordinate>[
        for (final AxialCoordinate d in directions)
          AxialCoordinate(c.q + d.q, c.r + d.r),
      ];
}

/// Canonical path-validation error codes (docs/gameplay/hex-geometry.md §3.2).
class PathErrorCodes {
  PathErrorCodes._();

  static const String pathEmpty = 'PATH_EMPTY';
  static const String notAdjacent = 'NOT_ADJACENT';
  static const String repeatedCell = 'REPEATED_CELL';
}

/// Outcome of validating a swiped hex path.
class PathValidationResult {
  const PathValidationResult(this.isValid, this.errorCode, this.violationIndex);

  final bool isValid;
  final String? errorCode;
  final int? violationIndex;

  static const PathValidationResult valid = PathValidationResult(
    true,
    null,
    null,
  );
}

/// Validates a committed cell path: every step adjacent, no repeated cell.
/// Deterministic, first-failure-wins, adjacency checked before repeat.
class PathValidator {
  PathValidator._();

  static PathValidationResult validate(List<AxialCoordinate> path) {
    if (path.isEmpty) {
      return const PathValidationResult(false, PathErrorCodes.pathEmpty, null);
    }

    for (int i = 1; i < path.length; i++) {
      if (!Hex.areAdjacent(path[i - 1], path[i])) {
        return PathValidationResult(false, PathErrorCodes.notAdjacent, i);
      }

      for (int j = 0; j < i; j++) {
        if (path[j] == path[i]) {
          return PathValidationResult(false, PathErrorCodes.repeatedCell, i);
        }
      }
    }

    return PathValidationResult.valid;
  }
}
