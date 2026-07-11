import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

/// Asserts the Dart path validator matches every adjacency/v1 golden case.
void main() {
  final List<AdjacencyFixtureCase> cases = loadAdjacencyCases();

  group('adjacency/v1 golden parity', () {
    for (final AdjacencyFixtureCase c in cases) {
      test(c.id, () {
        final PathValidationResult r = PathValidator.validate(c.path);
        expect(r.isValid, c.valid, reason: c.description);
        expect(r.errorCode, c.errorCode, reason: c.description);
        expect(r.violationIndex, c.violationIndex, reason: c.description);
      });
    }
  });
}
