import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/settings/settings_controller.dart';
import 'package:hexcalc/features/settings/settings_screen.dart';

import '../support/harness.dart';

void main() {
  testWidgets('opening settings logs settings_opened', (
    WidgetTester tester,
  ) async {
    final RecordingAnalytics analytics = RecordingAnalytics();
    await tester.pumpWidget(
      await testScope(
        analytics: analytics,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(analytics.contains('settings_opened'), isTrue);
  });

  testWidgets('toggling reduced motion updates the settings state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      await testScope(child: const MaterialApp(home: SettingsScreen())),
    );
    await tester.pumpAndSettle();

    final ProviderContainer container = ProviderScope.containerOf(
      tester.element(find.byType(SettingsScreen)),
    );
    expect(container.read(settingsProvider).reducedMotion, isFalse);

    await tester.tap(find.text('Reduced motion'));
    await tester.pumpAndSettle();

    expect(container.read(settingsProvider).reducedMotion, isTrue);
  });
}
