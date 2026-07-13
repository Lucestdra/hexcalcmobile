import '../persistence/sync_store.dart';

/// A headline + detail for a ranked run's verification status. Pure and testable;
/// centralizes the code→text mapping so widgets never switch on raw status strings.
/// An unverified or rejected run is never presented as a confirmed rank.
class RankedStatusText {
  const RankedStatusText(this.headline, this.detail, {this.isTerminal = false});

  final String headline;
  final String detail;

  /// True once the outcome is final (verified/rejected/failed) — the UI can stop
  /// showing a spinner.
  final bool isTerminal;
}

RankedStatusText rankedStatusText(RankedRunView? run) {
  if (run == null) {
    return const RankedStatusText(
      'Submitting…',
      'Sending your run for verification.',
    );
  }
  switch (run.status) {
    case kRankedVerified:
      // Only claim a confirmed score when the server actually returned one; never
      // pass off the local client total as verified.
      final int? score = run.verifiedScore;
      return RankedStatusText(
        'Verified',
        score != null
            ? 'Your score of $score is confirmed.'
            : 'Your run was verified.',
        isTerminal: true,
      );
    case kRankedRejected:
      return RankedStatusText(
        'Not verified',
        _rejectionDetail(run.rejectionReason),
        isTerminal: true,
      );
    case kRankedFailed:
      return RankedStatusText(
        'Couldn\'t submit',
        _failureDetail(run.failureCode),
        isTerminal: true,
      );
    case kRankedPending:
    default:
      return const RankedStatusText(
        'Verifying…',
        'Your run is being checked. Your score isn\'t confirmed yet.',
      );
  }
}

// Every verifier reject reason means the run could not be trusted; the player does
// not need the internal token, just that it will not be ranked.
String _rejectionDetail(String? reason) =>
    'This run didn\'t pass server verification, so it won\'t be ranked.';

String _failureDetail(String? code) {
  switch (code) {
    case 'game.challenge_expired':
      return 'The challenge expired before your run reached the server.';
    case 'game.run_already_submitted':
      return 'This run was already submitted.';
    case 'game.invalid_challenge':
      return 'This run couldn\'t be validated by the server.';
    default:
      return 'The server couldn\'t accept this run. It won\'t be ranked.';
  }
}
