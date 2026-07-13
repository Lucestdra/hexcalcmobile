import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/sync_controller.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/api/dtos.dart';
import '../../../core/audio/audio_service.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/haptics/haptics_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/settings/settings_controller.dart';
import '../../../core/utilities/correlation_id.dart';
import '../application/game_controller_v2.dart';
import '../application/game_mode_controller_v2.dart';
import '../application/game_phase.dart';
import '../application/game_session_config.dart';
import '../application/game_session_factory.dart';
import '../application/game_snapshot_v2.dart';
import '../application/run_event_log_v2.dart';
import '../domain/domain.dart';
import '../flame/game_feel.dart';
import '../flame/hex_board_game_v2.dart';
import '../persistence/run_history_repository.dart';
import '../persistence/sync_store.dart';
import 'game_feedback_dispatcher_v2.dart';
import 'game_hud.dart';
import 'game_hud_v2.dart';
import 'ranked_result_screen.dart';
import 'run_result_screen.dart';
import 'single_pointer_swipe_input.dart';

class GameplayScreenV2 extends ConsumerStatefulWidget {
  const GameplayScreenV2({required this.config, super.key});

  final GameSessionConfig config;

  @override
  ConsumerState<GameplayScreenV2> createState() => _GameplayScreenV2State();
}

class _GameplayScreenV2State extends ConsumerState<GameplayScreenV2> {
  late final MapDefinitionV2 _map;
  late final GameControllerV2 _controller;
  late final HexBoardGameV2 _game;
  late final GameFeedbackDispatcherV2 _dispatcher;
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
    final RulesetV2 ruleset = ref.read(rulesetV2Provider);
    final ModeCatalogV1 modeCatalog = ref.read(modeCatalogV1Provider);
    if (ruleset.rulesetVersion != widget.config.protocol.rulesetVersion ||
        modeCatalog.version != widget.config.protocol.modeCatalogVersion) {
      throw StateError('Session ruleset/mode catalog is not bundled');
    }
    _map = GameSessionFactory.resolveMap(
      config: widget.config,
      catalog: ref.read(mapCatalogV1Provider),
    );

    final AppSettings settings = ref.read(settingsProvider);
    _audio.applySettings(settings);
    _haptics.enabled = settings.hapticsEnabled;
    _controller = GameControllerV2(
      ruleset: ruleset,
      config: widget.config,
      map: _map,
      modeController: GameModeControllerFactoryV2.create(
        config: widget.config,
        map: _map,
        catalog: modeCatalog,
      ),
      onEvent: (event) => _dispatcher.handle(event),
    );
    _game = HexBoardGameV2(_controller, feel: GameFeel.fromSettings(settings));
    _dispatcher = GameFeedbackDispatcherV2(
      audio: _audio,
      haptics: _haptics,
      analytics: ref.read(analyticsProvider),
      game: _game,
      mode: widget.config.mode.wireName,
    );
    _controller.notifier.addListener(_onSnapshot);
    _controller.startRun();
  }

  void _onSnapshot() {
    if (_navigated || !_controller.notifier.value.finished) {
      return;
    }
    _navigated = true;
    unawaited(_finishRun(_controller.notifier.value));
  }

  Future<void> _finishRun(GameSnapshotV2 snapshot) async {
    final int playedAtMs = DateTime.now().millisecondsSinceEpoch;
    final String modeId = widget.config.mode.wireName;
    ref
        .read(analyticsProvider)
        .logEvent(
          AnalyticsEvent.runCompleted(
            score: snapshot.score,
            equations: snapshot.targetsSolved,
            bestCombo: snapshot.bestCombo,
            level: _map.order,
          ),
        );

    _history
        .recordRun(
          playedAtMs: playedAtMs,
          mode: modeId,
          score: snapshot.score,
          equations: 0,
          targetsSolved: snapshot.targetsSolved,
          bestCombo: snapshot.bestCombo,
          levelReached: _map.order,
          durationMs: _controller.runDurationMs ?? _controller.elapsedMs,
          rulesetVersion: widget.config.protocol.rulesetVersion,
          seed: widget.config.seed,
          protocolVersion: widget.config.protocol.protocolVersion,
          mapCatalogVersion: widget.config.protocol.mapCatalogVersion,
          mapId: _map.id,
          rating: snapshot.rating,
        )
        .ignore();

    if (widget.config.mode == V2GameMode.level) {
      try {
        await ref
            .read(mapProgressRepositoryProvider)
            .recordAttempt(
              catalogVersion: widget.config.protocol.mapCatalogVersion,
              mapId: _map.id,
              score: snapshot.score,
              rating: snapshot.rating ?? 0,
              playedAtMs: playedAtMs,
            );
      } catch (_) {
        // A failed local progress write must not strand the player on a finished
        // Flame surface. The result remains visible and a later attempt can save.
      }
    }

    final RunResultData localResult = RunResultData(
      score: snapshot.score,
      equationsSolved: 0,
      targetsSolved: snapshot.targetsSolved,
      bestCombo: snapshot.bestCombo,
      level: _map.order,
      rating: snapshot.rating,
      mapName: _map.name,
      modeId: modeId,
      replayLocation: switch (widget.config.mode) {
        V2GameMode.level => '/levels',
        V2GameMode.endless => '/endless-maps',
        _ => '/play-v2',
      },
    );

    String route = '/result';
    Object navExtra = localResult;
    try {
      final CompetitiveRunEnvelope? competitive = widget.config.competitiveRun;
      if (competitive != null) {
        await ref
            .read(syncStoreProvider)
            .enqueueRankedSubmit(
              runId: competitive.runId,
              mode: modeId,
              clientScore: snapshot.score,
              payloadVersion: kEventLogPayloadVersionV2,
              payload: <String, dynamic>{
                'runId': competitive.runId,
                'challengeToken': competitive.challengeToken,
                'eventLog': _controller.buildEventLog(),
              },
              idempotencyKey: newCorrelationId(),
              nowMs: playedAtMs,
            );
        ref
            .read(analyticsProvider)
            .logEvent(AnalyticsEvent.rankedSubmissionQueued());
        route = '/ranked-result';
        navExtra = RankedResultArgs(
          runId: competitive.runId,
          clientScore: snapshot.score,
          isDaily: widget.config.mode == V2GameMode.daily,
        );
        ref.read(outboxSyncControllerProvider.notifier).kick();
      } else if (widget.config.mode == V2GameMode.timeAttack) {
        await ref
            .read(syncStoreProvider)
            .enqueue(
              operationType: kOpNormalResult,
              payloadVersion: kEventLogPayloadVersionV2,
              payload: NormalRunResultRequest(
                rulesetVersion: widget.config.protocol.rulesetVersion,
                generatorVersion: widget.config.protocol.generatorVersion,
                seed: widget.config.seed,
                clientScore: snapshot.score,
                playedAtUtc: DateTime.now().toUtc(),
                protocolVersion: widget.config.protocol.protocolVersion,
                payloadVersion: widget.config.protocol.payloadVersion,
                mapCatalogVersion: widget.config.protocol.mapCatalogVersion,
                mapId: _map.id,
                modeCatalogVersion: widget.config.protocol.modeCatalogVersion,
                modeId: modeId,
                targetsSolved: snapshot.targetsSolved,
              ).toJson(),
              idempotencyKey: newCorrelationId(),
              nowMs: playedAtMs,
            );
        ref.read(outboxSyncControllerProvider.notifier).kick();
      }
    } catch (_) {
      route = '/result';
      navExtra = localResult;
    }

    if (!mounted) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.go(route, extra: navExtra);
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
    ref.listen<AppSettings>(settingsProvider, (
      AppSettings? previous,
      AppSettings next,
    ) {
      _audio.applySettings(next);
      _haptics.enabled = next.hapticsEnabled;
      _game.feel = GameFeel.fromSettings(next);
    });
    final bool reducedMotion = ref.watch(
      settingsProvider.select((AppSettings settings) => settings.reducedMotion),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: <Widget>[
          Positioned.fill(child: GameWidget(game: _game)),
          Positioned.fill(
            child: ValueListenableBuilder<GameSnapshotV2>(
              valueListenable: _controller.notifier,
              builder: (BuildContext context, GameSnapshotV2 snapshot, _) {
                return Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: SinglePointerSwipeInput(
                        enabled:
                            snapshot.phase != GamePhase.paused &&
                            !snapshot.finished,
                        onDown: _game.pressAt,
                        onMove: _game.extendAt,
                        onUp: _game.release,
                        onCancel: _game.cancel,
                      ),
                    ),
                    Positioned.fill(
                      child: GameHudV2(
                        snapshot: snapshot,
                        reducedMotion: reducedMotion,
                        onPause: _controller.togglePause,
                      ),
                    ),
                    if (snapshot.phase.isPaused)
                      Positioned.fill(
                        child: PauseOverlay(
                          onResume: _controller.togglePause,
                          onQuit: widget.config.mode == V2GameMode.endless
                              ? _controller.finishManually
                              : () => context.go('/modes'),
                          quitLabel: widget.config.mode == V2GameMode.endless
                              ? 'Finish run'
                              : 'Quit run',
                          onSettings: () => context.push('/settings'),
                        ),
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
