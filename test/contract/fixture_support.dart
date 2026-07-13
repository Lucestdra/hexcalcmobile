import 'dart:convert';
import 'dart:io';

import 'package:hexcalc/features/gameplay/domain/domain.dart';

/// Root of the synced golden fixtures. `flutter test` runs from the package root,
/// so this relative path resolves against the current directory.
Directory fixturesDir() {
  final Directory dir = Directory('test/contract/fixtures');
  if (!dir.existsSync()) {
    throw StateError(
      'fixtures not found at ${dir.absolute.path}; run ./tool/sync_fixtures.sh',
    );
  }
  return dir;
}

List<File> _jsonFilesUnder(String contract) {
  final Directory dir = Directory('${fixturesDir().path}/$contract');
  return dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((File f) => f.path.endsWith('.json'))
      .toList();
}

Operator parseOperator(String s) {
  switch (s) {
    case 'add':
      return Operator.add;
    case 'subtract':
      return Operator.subtract;
    case 'multiply':
      return Operator.multiply;
    case 'divide':
      return Operator.divide;
    default:
      throw ArgumentError('Unknown operator: $s');
  }
}

Token parseToken(Map<String, dynamic> e) {
  switch (e['kind'] as String) {
    case 'number':
      return Token.number(e['value'] as int);
    case 'operator':
      return Token.op(parseOperator(e['operator'] as String));
    case 'equals':
      return Token.equals;
    default:
      throw ArgumentError('Unknown token kind: ${e['kind']}');
  }
}

EquationStatus parseStatus(String s) {
  switch (s) {
    case 'valid':
      return EquationStatus.valid;
    case 'grammarError':
      return EquationStatus.grammarError;
    case 'arithmeticError':
      return EquationStatus.arithmeticError;
    case 'resultMismatch':
      return EquationStatus.resultMismatch;
    default:
      throw ArgumentError('Unknown status: $s');
  }
}

List<Token> _tokens(Map<String, dynamic> c) => (c['tokens'] as List<dynamic>)
    .map((dynamic e) => parseToken(e as Map<String, dynamic>))
    .toList();

List<Map<String, dynamic>> _cases(File f) {
  final Map<String, dynamic> root =
      jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
  return (root['cases'] as List<dynamic>).cast<Map<String, dynamic>>();
}

class EvaluatorFixtureCase {
  EvaluatorFixtureCase(
    this.id,
    this.description,
    this.tokens,
    this.status,
    this.errorCode,
    this.leftHandValue,
    this.resultValue,
  );

  final String id;
  final String description;
  final List<Token> tokens;
  final EquationStatus status;
  final String? errorCode;
  final int? leftHandValue;
  final int? resultValue;
}

class GrammarFixtureCase {
  GrammarFixtureCase(
    this.id,
    this.description,
    this.tokens,
    this.valid,
    this.errorCode,
  );

  final String id;
  final String description;
  final List<Token> tokens;
  final bool valid;
  final String? errorCode;
}

class AdjacencyFixtureCase {
  AdjacencyFixtureCase(
    this.id,
    this.description,
    this.path,
    this.valid,
    this.errorCode,
    this.violationIndex,
  );

  final String id;
  final String description;
  final List<AxialCoordinate> path;
  final bool valid;
  final String? errorCode;
  final int? violationIndex;
}

List<EvaluatorFixtureCase> loadEvaluatorCases() {
  final List<EvaluatorFixtureCase> out = <EvaluatorFixtureCase>[];
  // v1 and target-swipe v2 intentionally have different result schemas.
  // Keep this frozen-equation loader scoped to its protocol directory; v2 is
  // asserted independently by v2_gameplay_fixture_test.dart.
  for (final File f in _jsonFilesUnder('evaluator/v1')) {
    for (final Map<String, dynamic> c in _cases(f)) {
      final Map<String, dynamic> exp = c['expected'] as Map<String, dynamic>;
      out.add(
        EvaluatorFixtureCase(
          c['id'] as String,
          c['description'] as String,
          _tokens(c),
          parseStatus(exp['status'] as String),
          exp['errorCode'] as String?,
          exp['leftHandValue'] as int?,
          exp['resultValue'] as int?,
        ),
      );
    }
  }
  return out;
}

List<GrammarFixtureCase> loadGrammarCases() {
  final List<GrammarFixtureCase> out = <GrammarFixtureCase>[];
  for (final File f in _jsonFilesUnder('grammar')) {
    for (final Map<String, dynamic> c in _cases(f)) {
      final Map<String, dynamic> exp = c['expected'] as Map<String, dynamic>;
      out.add(
        GrammarFixtureCase(
          c['id'] as String,
          c['description'] as String,
          _tokens(c),
          exp['valid'] as bool,
          exp['errorCode'] as String?,
        ),
      );
    }
  }
  return out;
}

List<AdjacencyFixtureCase> loadAdjacencyCases() {
  final List<AdjacencyFixtureCase> out = <AdjacencyFixtureCase>[];
  for (final File f in _jsonFilesUnder('adjacency')) {
    for (final Map<String, dynamic> c in _cases(f)) {
      final Map<String, dynamic> exp = c['expected'] as Map<String, dynamic>;
      final List<AxialCoordinate> path = (c['path'] as List<dynamic>).map((
        dynamic e,
      ) {
        final Map<String, dynamic> m = e as Map<String, dynamic>;
        return AxialCoordinate(m['q'] as int, m['r'] as int);
      }).toList();
      out.add(
        AdjacencyFixtureCase(
          c['id'] as String,
          c['description'] as String,
          path,
          exp['valid'] as bool,
          exp['errorCode'] as String?,
          exp['violationIndex'] as int?,
        ),
      );
    }
  }
  return out;
}
