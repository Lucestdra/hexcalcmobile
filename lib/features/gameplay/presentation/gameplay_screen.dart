import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/haptics/haptics_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../application/game_controller.dart';
import '../application/game_snapshot.dart';
import '../flame/game_feel.dart';
import '../flame/hex_board_game.dart';
import '../persistence/run_history_repository.dart';
import 'game_feedback_dispatcher.dart';
import 'game_hud.dart';
import 'run_result_screen.dart';

/// The playable run: a Flame board with the HUD overlaid. Pointer gestures are
/// captured here and forwarded to the board game (shared hit-test metrics), and
/// the controller's discrete signals are fanned out to audio/haptics/analytics
/// and the choreography via [GameFeedbackDispatcher].
class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late final GameController _controller;
  late final HexBoardGame _game;
  late final GameFeedbackDispatcher _dispatcher;
  late final AudioService _audio;
  late final HapticsService _haptics;
  late final RunHistoryRepository _history;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _haptics = ref.read(hapticsServiceProvider);
    _history = ref.read(runHistoryRepositoryProvider);

    final AppSettings settings = ref.read(settingsProvider);
    _audio.applySettings(settings);
    _haptics.enabled = settings.hapticsEnabled;

    final String seed = 'run-${DateTime.now().microsecondsSinceEpoch}';
    _controller = GameController(
      ruleset: ref.read(rulesetProvider),
      seed: seed,
      onEvent: (event) => _dispatcher.handle(event),
    );
    _game = HexBoardGame(_controller, feel: GameFeel.fromSettings(settings));
    _dispatcher = GameFeedbackDispatcher(
      audio: _audio,
      haptics: _haptics,
      analytics: ref.read(analyticsProvider),
      game: _game,
    );

    _controller.notifier.addListener(_onSnapshot);
    _controller.startRun();
  }

  void _onSnapshot() {
    if (_navigated || !_controller.notifier.value.finished) {
      return;
    }
    _navigated = true;
    final GameSnapshot s = _controller.notifier.value;

    ref
        .read(analyticsProvider)
        .logEvent(
          AnalyticsEvent.runCompleted(
            score: s.score,
            equations: s.equationsSolved,
            bestCombo: s.bestCombo,
            level: s.level,
          ),
        );

    // Persist the run locally (non-authoritative history). Fire-and-forget: a
    // failed write must never block the result screen.
    _history
        .recordRun(
          playedAtMs: DateTime.now().millisecondsSinceEpoch,
          mode: 'normal',
          score: s.score,
          equations: s.equationsSolved,
          bestCombo: s.bestCombo,
          levelReached: s.level,
          durationMs: _controller.runDurationMs,
          rulesetVersion: _controller.ruleset.rulesetVersion,
          seed: _controller.seed,
        )
        .ignore();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(
          '/result',
          extra: RunResultData(
            score: s.score,
            equationsSolved: s.equationsSolved,
            bestCombo: s.bestCombo,
            level: s.level,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.notifier.removeListener(_onSnapshot);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Keep live services and the Flame surface in step with settings changes.
    ref.listen<AppSettings>(settingsProvider, (
      AppSettings? prev,
      AppSettings next,
    ) {
      _audio.applySettings(next);
      _haptics.enabled = next.hapticsEnabled;
      _game.feel = GameFeel.fromSettings(next);
    });
    final bool reducedMotion = ref.watch(
      settingsProvider.select((AppSettings s) => s.reducedMotion),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (DragStartDetails d) =>
                  _game.pressAt(d.localPosition),
              onPanUpdate: (DragUpdateDetails d) =>
                  _game.extendAt(d.localPosition),
              onPanEnd: (DragEndDetails d) => _game.release(),
              onPanCancel: _game.cancel,
            ),
          ),
          Positioned.fill(
            child: ValueListenableBuilder<GameSnapshot>(
              valueListenable: _controller.notifier,
              builder: (BuildContext context, GameSnapshot snapshot, _) {
                return Stack(
                  children: <Widget>[
                    GameHud(
                      snapshot: snapshot,
                      reducedMotion: reducedMotion,
                      onPause: _controller.togglePause,
                    ),
                    if (snapshot.phase.isPaused)
                      PauseOverlay(
                        onResume: _controller.togglePause,
                        onQuit: () => context.go('/'),
                        onSettings: () => context.push('/settings'),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
