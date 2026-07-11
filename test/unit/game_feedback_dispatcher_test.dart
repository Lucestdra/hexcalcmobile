import 'package:flutter_test/flutter_test.dart';
import 'package:hexcalc/core/audio/audio_service.dart';
import 'package:hexcalc/core/haptics/haptics_service.dart';
import 'package:hexcalc/core/settings/app_settings.dart';
import 'package:hexcalc/features/gameplay/application/game_controller.dart';
import 'package:hexcalc/features/gameplay/application/game_event.dart';
import 'package:hexcalc/features/gameplay/flame/hex_board_game.dart';
import 'package:hexcalc/features/gameplay/presentation/game_feedback_dispatcher.dart';

import '../support/harness.dart';

/// Records audio calls so the routing can be asserted.
class _RecordingAudio implements AudioService {
  final List<Sfx> played = <Sfx>[];
  final List<int> notes = <int>[];

  @override
  Future<void> preload() async {}
  @override
  void applySettings(AppSettings settings) {}
  @override
  void play(Sfx sfx) => played.add(sfx);
  @override
  void playPathNote(int selectionLength) => notes.add(selectionLength);
  @override
  void dispose() {}
}

void main() {
  late _RecordingAudio audio;
  late RecordingAnalytics analytics;
  late GameFeedbackDispatcher dispatcher;

  setUp(() {
    audio = _RecordingAudio();
    analytics = RecordingAnalytics();
    final GameController controller = GameController(
      ruleset: loadTestRuleset(),
      seed: 'alpha',
    )..startRun();
    // Metrics are null (no surface), so choreography calls are safe no-ops.
    final HexBoardGame game = HexBoardGame(controller);
    dispatcher = GameFeedbackDispatcher(
      audio: audio,
      haptics: HapticsService(enabled: false),
      analytics: analytics,
      game: game,
    );
  });

  test('a selected cell plays the rising path note for its length', () {
    dispatcher.handle(const GameEvent(GameSignal.cellSelected, value: 3));
    expect(audio.notes, <int>[3]);
  });

  test('a correct equation plays the chord and logs the funnel event', () {
    dispatcher.handle(const GameEvent(GameSignal.equationCorrect, value: 2));
    expect(audio.played, contains(Sfx.correct));
    expect(analytics.contains('equation_correct'), isTrue);
  });

  test('a target match plays the sparkle and logs the event', () {
    dispatcher.handle(const GameEvent(GameSignal.targetMatched));
    expect(audio.played, contains(Sfx.target));
    expect(analytics.contains('target_matched'), isTrue);
  });

  test('an incorrect equation plays the invalid cue and logs it', () {
    dispatcher.handle(const GameEvent(GameSignal.equationIncorrect));
    expect(audio.played, contains(Sfx.invalid));
    expect(analytics.contains('equation_incorrect'), isTrue);
  });

  test('fever ignition plays the sweep and logs fever_started', () {
    dispatcher.handle(const GameEvent(GameSignal.feverStarted));
    expect(audio.played, contains(Sfx.fever));
    expect(analytics.contains('fever_started'), isTrue);
  });

  test('run start logs run_started with the mode', () {
    dispatcher.handle(const GameEvent(GameSignal.runStarted));
    expect(analytics.contains('run_started'), isTrue);
  });
}
