import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

import 'fixture_support.dart';

String operatorName(Operator op) {
  switch (op) {
    case Operator.add:
      return 'add';
    case Operator.subtract:
      return 'subtract';
    case Operator.multiply:
      return 'multiply';
    case Operator.divide:
      return 'divide';
  }
}

/// Regenerates every board in boards/gen-v1 with the Dart generator and asserts
/// it matches the backend-generated fixture field-for-field — the cross-platform
/// board-generation parity proof.
void main() {
  final Directory dir = Directory('${fixturesDir().path}/boards/gen-v1');
  final List<File> files =
      dir
          .listSync()
          .whereType<File>()
          .where((File f) => f.path.endsWith('.json'))
          .toList()
        ..sort((File a, File b) => a.path.compareTo(b.path));

  for (final File file in files) {
    final Map<String, dynamic> root =
        jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
    final String seed = root['seed'] as String;
    final List<dynamic> boards = root['boards'] as List<dynamic>;

    for (final dynamic boardDyn in boards) {
      final Map<String, dynamic> fb = boardDyn as Map<String, dynamic>;
      final int levelIndex = fb['levelIndex'] as int;

      test('board $seed level $levelIndex matches golden', () {
        final bool isFallback = fb['usedFallback'] as bool;
        final Board board = isFallback
            ? BoardGeneratorV1.generateFallback(levelIndex)
            : BoardGeneratorV1.generate(seed, 'rs-v1', levelIndex);

        expect(board.radius, fb['boardRadius']);
        expect(board.target, fb['target']);
        expect(board.attemptsUsed, fb['attemptsUsed']);
        expect(board.usedFallback, fb['usedFallback']);

        final List<dynamic> fcells = fb['cells'] as List<dynamic>;
        expect(board.cells.length, fcells.length);
        for (int i = 0; i < fcells.length; i++) {
          final Map<String, dynamic> fc = fcells[i] as Map<String, dynamic>;
          final BoardCell cell = board.cells[i];
          expect(cell.coord.q, fc['q'], reason: 'cell $i q');
          expect(cell.coord.r, fc['r'], reason: 'cell $i r');
          switch (fc['kind'] as String) {
            case 'number':
              expect(cell.kind, CellKind.number);
              expect(cell.value, fc['value']);
            case 'operator':
              expect(cell.kind, CellKind.operator);
              expect(operatorName(cell.operator!), fc['operator']);
            case 'equals':
              expect(cell.kind, CellKind.equals);
          }
        }

        final List<dynamic> fsamples = fb['sampleSolutions'] as List<dynamic>;
        expect(board.sampleSolutions.length, fsamples.length);
        for (int i = 0; i < fsamples.length; i++) {
          final List<dynamic> fpath = fsamples[i] as List<dynamic>;
          final List<AxialCoordinate> path = board.sampleSolutions[i];
          expect(path.length, fpath.length);
          for (int j = 0; j < fpath.length; j++) {
            final Map<String, dynamic> fco = fpath[j] as Map<String, dynamic>;
            expect(path[j].q, fco['q']);
            expect(path[j].r, fco['r']);
          }
        }
      });
    }
  }
}
