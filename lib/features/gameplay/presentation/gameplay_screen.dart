import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../application/game_controller.dart';
import '../application/game_snapshot.dart';
import '../flame/hex_board_game.dart';
import 'game_hud.dart';
import 'run_result_screen.dart';

/// The playable run: a Flame board with the HUD overlaid. Pointer gestures are
/// captured here and forwarded to the board game (shared hit-test metrics).
class GameplayScreen extends ConsumerStatefulWidget {
  const GameplayScreen({super.key});

  @override
  ConsumerState<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends ConsumerState<GameplayScreen> {
  late final GameController _controller;
  late final HexBoardGame _game;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    final String seed = 'run-${DateTime.now().microsecondsSinceEpoch}';
    _controller = GameController(ruleset: ref.read(rulesetProvider), seed: seed)
      ..startRun();
    _game = HexBoardGame(_controller);
    _controller.notifier.addListener(_onSnapshot);
  }

  void _onSnapshot() {
    if (_navigated || !_controller.notifier.value.finished) {
      return;
    }
    _navigated = true;
    final GameSnapshot s = _controller.notifier.value;
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
              onPanCancel: _game.release,
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
                      onPause: _controller.togglePause,
                    ),
                    if (snapshot.phase.isPaused)
                      PauseOverlay(
                        onResume: _controller.togglePause,
                        onQuit: () => context.go('/'),
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
