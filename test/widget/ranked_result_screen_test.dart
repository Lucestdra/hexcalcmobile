import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/app/providers.dart';
import 'package:hexcalc/features/gameplay/persistence/sync_store.dart';
import 'package:hexcalc/features/gameplay/presentation/ranked_result_screen.dart';

RankedRunView _run(
  String status, {
  int? verifiedScore,
  String? rejectionReason,
}) => RankedRunView(
  runId: 'run-1',
  mode: 'ranked',
  status: status,
  clientScore: 105,
  verifiedScore: verifiedScore,
  rejectionReason: rejectionReason,
  failureCode: null,
  createdAtMs: 0,
  updatedAtMs: 0,
);

Future<void> _pump(WidgetTester tester, RankedRunView? run) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        rankedRunViewProvider(
          'run-1',
        ).overrideWith((ref) => Stream<RankedRunView?>.value(run)),
      ],
      child: const MaterialApp(
        home: RankedResultScreen(runId: 'run-1', clientScore: 105),
      ),
    ),
  );
  await tester.pump(); // let the stream deliver
}

void main() {
  testWidgets('pending shows an unverified score and a spinner', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _run(kRankedPending));

    expect(find.text('Verifying…'), findsOneWidget);
    expect(find.text('YOUR SCORE (UNVERIFIED)'), findsOneWidget);
    expect(find.text('105'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('verified shows the confirmed score and no spinner', (
    WidgetTester tester,
  ) async {
    await _pump(tester, _run(kRankedVerified, verifiedScore: 250));

    expect(find.text('Verified'), findsOneWidget);
    expect(find.text('VERIFIED SCORE'), findsOneWidget);
    expect(find.text('250'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('rejected shows a not-verified message, never a rank', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      _run(kRankedRejected, rejectionReason: 'non_adjacent_path'),
    );

    expect(find.text('Not verified'), findsOneWidget);
    expect(find.text('YOUR SCORE (UNVERIFIED)'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
