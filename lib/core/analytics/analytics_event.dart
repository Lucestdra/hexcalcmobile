/// A typed analytics event: a product question, never implementation noise.
///
/// Events are constructed only through the named factories below so the catalog
/// stays closed and reviewable. Parameters are deliberately coarse — never a raw
/// equation path, email, token, or any PII (see `docs/analytics-events.md`).
class AnalyticsEvent {
  const AnalyticsEvent._(
    this.name, [
    this.parameters = const <String, Object>{},
  ]);

  final String name;
  final Map<String, Object> parameters;

  // ----- Lifecycle / session -----
  factory AnalyticsEvent.appOpened() => const AnalyticsEvent._('app_opened');

  // ----- Run funnel -----
  factory AnalyticsEvent.runStarted({required String mode}) =>
      AnalyticsEvent._('run_started', <String, Object>{'mode': mode});

  factory AnalyticsEvent.equationCorrect({required int comboCount}) =>
      AnalyticsEvent._('equation_correct', <String, Object>{
        'combo_count': comboCount,
      });

  factory AnalyticsEvent.equationIncorrect() =>
      const AnalyticsEvent._('equation_incorrect');

  factory AnalyticsEvent.targetMatched() =>
      const AnalyticsEvent._('target_matched');

  factory AnalyticsEvent.feverStarted() =>
      const AnalyticsEvent._('fever_started');

  factory AnalyticsEvent.feverCompleted() =>
      const AnalyticsEvent._('fever_completed');

  factory AnalyticsEvent.levelCompleted({required int level}) =>
      AnalyticsEvent._('level_completed', <String, Object>{'level': level});

  factory AnalyticsEvent.runCompleted({
    required int score,
    required int equations,
    required int bestCombo,
    required int level,
  }) => AnalyticsEvent._('run_completed', <String, Object>{
    'score': score,
    'equations': equations,
    'best_combo': bestCombo,
    'level': level,
  });

  // ----- Ranked -----
  factory AnalyticsEvent.rankedSubmissionQueued() =>
      const AnalyticsEvent._('ranked_submission_queued');

  factory AnalyticsEvent.rankedSubmissionVerified() =>
      const AnalyticsEvent._('ranked_submission_verified');

  factory AnalyticsEvent.rankedSubmissionRejected() =>
      const AnalyticsEvent._('ranked_submission_rejected');

  // ----- Leaderboard / daily -----
  factory AnalyticsEvent.leaderboardViewed() =>
      const AnalyticsEvent._('leaderboard_viewed');

  factory AnalyticsEvent.dailyChallengeStarted() =>
      const AnalyticsEvent._('daily_challenge_started');

  // ----- Navigation / settings -----
  factory AnalyticsEvent.settingsOpened() =>
      const AnalyticsEvent._('settings_opened');

  @override
  String toString() =>
      parameters.isEmpty ? name : '$name ${parameters.toString()}';
}
