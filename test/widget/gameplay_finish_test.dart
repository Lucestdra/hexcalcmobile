import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/app/routing/app_router.dart';
import 'package:hexcalc/features/gameplay/domain/domain.dart';

/// rs-v1 with a short run duration so the run finishes quickly in a test.
Ruleset shortRuleset(int durationMs) {
  final Map<String, dynamic> j =
      jsonDecode(
            File(
              'test/contract/fixtures/rulesets/rs-v1.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;
  (j['run'] as Map<String, dynamic>)['durationMs'] = durationMs;
  return Ruleset.fromJson(j);
}

void main() {
  testWidgets('a finished run navigates from gameplay to the result screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 720));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [rulesetProvider.overrideWithValue(shortRuleset(800))],
        child: MaterialApp.router(
          routerConfig: createRouter(initialLocation: '/play'),
        ),
      ),
    );

    // The gameplay HUD is up first.
    await tester.pump();
    expect(find.text('TARGET'), findsOneWidget);

    // Drive the Flame clock forward until the run finishes and navigation lands.
    for (
      int i = 0;
      i < 60 && find.text('RUN COMPLETE').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('RUN COMPLETE'), findsOneWidget);
    expect(find.text('Play again'), findsOneWidget);
  });
}
