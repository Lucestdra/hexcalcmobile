import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/haptics/haptics_service.dart';
import '../application/game_event.dart';
import '../flame/hex_board_game.dart';

/// Fans a controller [GameEvent] out to audio, haptics, analytics, and the Flame
/// choreography. This is the one place that knows "a correct equation sounds like
/// X, buzzes like Y, logs Z, and looks like W" — the controller stays ignorant of
/// all of it. Pure routing, so it is unit-testable with fake services.
class GameFeedbackDispatcher {
  GameFeedbackDispatcher({
    required this.audio,
    required this.haptics,
    required this.analytics,
    required this.game,
  });

  final AudioService audio;
  final HapticsService haptics;
  final AnalyticsService analytics;
  final HexBoardGame game;

  void handle(GameEvent event) {
    switch (event.signal) {
      case GameSignal.runStarted:
        analytics.logEvent(AnalyticsEvent.runStarted(mode: 'normal'));
      case GameSignal.cellSelected:
        audio.playPathNote(event.value);
        haptics.fire(HapticLevel.selection);
      case GameSignal.pathBacktrack:
        haptics.fire(HapticLevel.light);
      case GameSignal.equationCorrect:
        audio.play(Sfx.correct);
        haptics.fire(HapticLevel.medium);
        analytics.logEvent(
          AnalyticsEvent.equationCorrect(comboCount: event.value),
        );
        game.playCorrect(
          event.cells,
          fever: game.controller.notifier.value.feverActive,
        );
      case GameSignal.targetMatched:
        audio.play(Sfx.target);
        analytics.logEvent(AnalyticsEvent.targetMatched());
        game.playTargetMatched(event.cells);
      case GameSignal.equationIncorrect:
        audio.play(Sfx.invalid);
        haptics.fire(HapticLevel.heavy);
        analytics.logEvent(AnalyticsEvent.equationIncorrect());
        game.playIncorrect(event.cells);
      case GameSignal.incompleteRewind:
        haptics.fire(HapticLevel.light);
      case GameSignal.feverStarted:
        audio.play(Sfx.fever);
        haptics.fire(HapticLevel.heavy);
        analytics.logEvent(AnalyticsEvent.feverStarted());
        game.playFeverStart();
      case GameSignal.feverEnded:
        analytics.logEvent(AnalyticsEvent.feverCompleted());
      case GameSignal.levelCompleted:
        analytics.logEvent(AnalyticsEvent.levelCompleted(level: event.value));
        game.playLevelUp();
      case GameSignal.runFinished:
        // The run summary (save + navigation + run_completed) is owned by the
        // screen, which has the final snapshot. Nothing to do here.
        break;
    }
  }
}
