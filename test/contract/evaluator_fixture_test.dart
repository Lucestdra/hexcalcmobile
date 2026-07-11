import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

/// Asserts the Dart evaluator matches every evaluator/v1 golden case — the same
/// fixtures the C# backend asserts. This is the cross-platform parity proof.
void main() {
  final List<EvaluatorFixtureCase> cases = loadEvaluatorCases();

  group('evaluator/v1 golden parity', () {
    for (final EvaluatorFixtureCase c in cases) {
      test(c.id, () {
        final EquationResult r = EquationEvaluator.evaluate(c.tokens);
        expect(r.status, c.status, reason: c.description);
        expect(r.errorCode, c.errorCode, reason: c.description);
        expect(r.leftHandValue, c.leftHandValue, reason: c.description);
        expect(r.resultValue, c.resultValue, reason: c.description);
      });
    }
  });

  test('fixture set is nonempty and covers every status', () {
    final Set<EquationStatus> statuses = cases
        .map((EvaluatorFixtureCase c) => c.status)
        .toSet();
    expect(cases.length, greaterThanOrEqualTo(40));
    expect(statuses, containsAll(EquationStatus.values));
  });
}
