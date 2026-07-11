import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

/// Asserts the Dart grammar validator matches every grammar/v1 golden case.
void main() {
  final List<GrammarFixtureCase> cases = loadGrammarCases();

  group('grammar/v1 golden parity', () {
    for (final GrammarFixtureCase c in cases) {
      test(c.id, () {
        final GrammarValidation r = EquationGrammar.validate(c.tokens);
        expect(r.isValid, c.valid, reason: c.description);
        expect(r.errorCode, c.errorCode, reason: c.description);
      });
    }
  });
}
