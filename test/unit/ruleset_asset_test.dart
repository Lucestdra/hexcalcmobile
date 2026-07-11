import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The bundled runtime ruleset must stay byte-identical to the canonical fixture,
/// so the app plays under exactly the ruleset the backend verifies against.
void main() {
  test('bundled assets/gameplay/rs-v1.json matches the canonical fixture', () {
    final List<int> asset = File(
      'assets/gameplay/rs-v1.json',
    ).readAsBytesSync();
    final List<int> fixture = File(
      'test/contract/fixtures/rulesets/rs-v1.json',
    ).readAsBytesSync();
    expect(asset, fixture);
  });
}
