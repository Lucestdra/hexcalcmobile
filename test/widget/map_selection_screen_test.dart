import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/routing/app_router.dart';
import 'package:hexcalc/features/gameplay/persistence/map_progress_repository.dart';

import '../support/harness.dart';

void main() {
  testWidgets('Level maps unlock sequentially and show best stars', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      await testScope(
        mapProgress: const <String, MapProgress>{
          'open-hex': MapProgress(
            catalogVersion: 'maps-v1',
            mapId: 'open-hex',
            bestRating: 2,
            bestScore: 700,
            attempts: 1,
            completedAtMs: 1,
          ),
        },
        child: MaterialApp.router(
          routerConfig: createRouter(initialLocation: '/levels'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('SELECT LEVEL'), findsOneWidget);
    expect(find.text('Open Hex'), findsOneWidget);
    expect(find.text('Center Ring'), findsOneWidget);
    expect(find.text('★★☆'), findsOneWidget);

    final InkWell second = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Center Ring'),
        matching: find.byType(InkWell),
      ),
    );
    final InkWell third = tester.widget<InkWell>(
      find.ancestor(
        of: find.text('Twin Gates'),
        matching: find.byType(InkWell),
      ),
    );
    expect(second.onTap, isNotNull);
    expect(third.onTap, isNull);
  });
}
