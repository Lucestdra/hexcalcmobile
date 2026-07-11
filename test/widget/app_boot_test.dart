import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';
import 'package:hexcalc/main.dart';

Ruleset loadRs1() => Ruleset.fromJson(
  jsonDecode(
        File('test/contract/fixtures/rulesets/rs-v1.json').readAsStringSync(),
      )
      as Map<String, dynamic>,
);

Widget appUnderTest(Ruleset rs) => ProviderScope(
  overrides: [rulesetProvider.overrideWithValue(rs)],
  child: const HexCalcApp(),
);

void main() {
  testWidgets('home shows the wordmark and PLAY starts a run', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(appUnderTest(loadRs1()));
    await tester.pumpAndSettle();

    expect(find.text('HEX • CALC'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    await tester.tap(find.text('PLAY'));
    // Do NOT pumpAndSettle: the Flame game loop schedules frames forever.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    // The gameplay HUD is now visible.
    expect(find.text('TARGET'), findsOneWidget);
    expect(find.text('SCORE'), findsOneWidget);
    expect(find.text('TIME'), findsOneWidget);
  });
}
