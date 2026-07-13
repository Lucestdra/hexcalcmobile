import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/features/gameplay/persistence/sync_store.dart';
import 'package:hexcalc/features/gameplay/presentation/ranked_status.dart';

RankedRunView _run(
  String status, {
  int? verifiedScore,
  String? rejectionReason,
  String? failureCode,
}) => RankedRunView(
  runId: 'r',
  mode: 'ranked',
  status: status,
  clientScore: 100,
  verifiedScore: verifiedScore,
  rejectionReason: rejectionReason,
  failureCode: failureCode,
  createdAtMs: 0,
  updatedAtMs: 0,
);

void main() {
  test(
    'a missing/pending run is non-terminal and shows an unverified message',
    () {
      expect(rankedStatusText(null).isTerminal, isFalse);
      final RankedStatusText pending = rankedStatusText(_run(kRankedPending));
      expect(pending.isTerminal, isFalse);
      expect(pending.headline, 'Verifying…');
    },
  );

  test('a verified run shows the confirmed score and is terminal', () {
    final RankedStatusText t = rankedStatusText(
      _run(kRankedVerified, verifiedScore: 246),
    );
    expect(t.isTerminal, isTrue);
    expect(t.headline, 'Verified');
    expect(t.detail, contains('246'));
  });

  test('a rejected run is terminal and never implies a rank', () {
    final RankedStatusText t = rankedStatusText(
      _run(kRankedRejected, rejectionReason: 'non_adjacent_path'),
    );
    expect(t.isTerminal, isTrue);
    expect(t.headline, 'Not verified');
    expect(t.detail, contains('won\'t be ranked'));
  });

  test('a failed run maps distinct failure codes to distinct messages', () {
    expect(
      rankedStatusText(
        _run(kRankedFailed, failureCode: 'game.challenge_expired'),
      ).detail,
      contains('expired'),
    );
    expect(
      rankedStatusText(
        _run(kRankedFailed, failureCode: 'game.run_already_submitted'),
      ).detail,
      contains('already submitted'),
    );
    expect(
      rankedStatusText(
        _run(kRankedFailed, failureCode: 'game.invalid_challenge'),
      ).detail,
      contains('validated'),
    );
    // An unknown code still yields a safe, non-blaming message.
    final RankedStatusText other = rankedStatusText(
      _run(kRankedFailed, failureCode: 'something.else'),
    );
    expect(other.isTerminal, isTrue);
    expect(other.detail, isNotEmpty);
  });
}
