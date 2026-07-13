import 'package:flutter/foundation.dart';

import '../domain/domain.dart';
import 'game_event.dart';
import 'game_mode_controller_v2.dart';
import 'game_phase.dart';
import 'game_session_config.dart';
import 'game_snapshot_v2.dart';
import 'run_event_log_v2.dart';

/// Shared target-swipe engine for every v2 mode.
///
/// Mode policy is limited to duration, quota/rating, and manual completion. Hex
/// input, expression evaluation, scoring, deterministic refill, and event-log
/// capture are identical for all modes.
class GameControllerV2 {
  GameControllerV2({
    required this.ruleset,
    required this.config,
    required this.map,
    GameModeControllerV2? modeController,
    this.onEvent,
  }) : modeController =
           modeController ??
           GameModeControllerFactoryV2.create(config: config, map: map),
       notifier = ValueNotifier<GameSnapshotV2>(
         _emptySnapshot(ruleset: ruleset, config: config, map: map),
       );

  final RulesetV2 ruleset;
  final GameSessionConfig config;
  final MapDefinitionV2 map;
  final GameModeControllerV2 modeController;
  final void Function(GameEvent event)? onEvent;
  final ValueNotifier<GameSnapshotV2> notifier;

  static const int _successFeedbackMs = 420;
  static const int _errorFeedbackMs = 260;

  late BoardStateV2 _board;
  SwipeChainV2? _chain;
  final List<LoggedV2RunEvent> _loggedEvents = <LoggedV2RunEvent>[];
  ScoreStateV2 _score = const ScoreStateV2();
  GamePhase _phase = GamePhase.idle;
  int _phaseUntilMs = 0;
  int _elapsedMs = 0;
  bool _paused = false;
  bool _pendingLevelFinish = false;
  bool? _lastChainCorrect;
  int _targetsSolved = 0;
  int _bestCombo = 0;

  int? _lastEmittedSecond;
  bool _lastEmittedFever = false;
  bool _lastEmittedComboOpen = false;

  BoardStateV2 get board => _board;
  List<AxialCoordinate> get path =>
      List<AxialCoordinate>.unmodifiable(_chain?.path ?? const []);
  int get elapsedMs => _elapsedMs;
  int? get runDurationMs => modeController.durationMs;
  int? get targetQuota => modeController.targetQuota;
  List<LoggedV2RunEvent> get loggedEvents =>
      List<LoggedV2RunEvent>.unmodifiable(_loggedEvents);

  Map<String, dynamic> buildEventLog() => buildEventLogPayloadV2(
    clientTotalScore: _score.totalScore,
    events: _loggedEvents,
  );

  BoardTileV2? cellAt(AxialCoordinate coordinate) => _board.tileAt(coordinate);

  void startRun() {
    _board = BoardGeneratorV2.generate(seed: config.seed, map: map);
    _chain = null;
    _loggedEvents.clear();
    _score = const ScoreStateV2();
    _phase = GamePhase.idle;
    _phaseUntilMs = 0;
    _elapsedMs = 0;
    _paused = false;
    _pendingLevelFinish = false;
    _lastChainCorrect = null;
    _targetsSolved = 0;
    _bestCombo = 0;
    _lastEmittedSecond = null;
    _lastEmittedFever = false;
    _lastEmittedComboOpen = false;
    _emit();
    _signal(const GameEvent(GameSignal.runStarted));
  }

  void pressCell(AxialCoordinate coordinate) {
    if (_paused || _pendingLevelFinish || !_phase.acceptsPress) {
      return;
    }
    final BoardTileV2? tile = _board.tileAt(coordinate);
    if (tile == null || tile.kind != BoardTileKindV2.number) {
      return;
    }
    _chain = SwipeChainV2.start(_board, coordinate);
    _phase = GamePhase.selecting;
    _emit();
    _signal(const GameEvent(GameSignal.cellSelected, value: 1));
  }

  void extendToCell(AxialCoordinate coordinate) {
    final SwipeChainV2? current = _chain;
    if (_phase != GamePhase.selecting || current == null) {
      return;
    }
    final SwipeAppendResultV2 result = current.append(coordinate);
    if (!result.changed) {
      return;
    }
    _chain = result.chain;
    _emit();
    _signal(
      result.outcome == SwipeAppendOutcomeV2.backtracked
          ? const GameEvent(GameSignal.pathBacktrack)
          : GameEvent(GameSignal.cellSelected, value: result.chain.path.length),
    );
  }

  /// Drops a cancelled or incomplete selection without scoring or event logging.
  void cancelSelection() {
    if (_phase != GamePhase.selecting) {
      return;
    }
    _rewindIncomplete();
  }

  /// Commits a complete release. Only complete releases enter payload v2.
  void release() {
    final SwipeChainV2? chain = _chain;
    if (_phase != GamePhase.selecting || chain == null) {
      return;
    }
    final SwipeReleaseResultV2 release = chain.release();
    if (!release.isComplete) {
      _rewindIncomplete();
      return;
    }

    final List<AxialCoordinate> committed = List<AxialCoordinate>.of(
      chain.path,
    );
    final int revision = _board.revision;
    _loggedEvents.add(
      LoggedV2RunEvent.chain(
        tMs: _elapsedMs,
        boardRevision: revision,
        path: committed,
      ),
    );
    _chain = null;

    if (release.matchesTarget) {
      _accept(committed);
    } else {
      _reject(committed);
    }
  }

  void _accept(List<AxialCoordinate> committed) {
    final List<Operator> operators = <Operator>[
      for (final AxialCoordinate coordinate in committed)
        if (_board.tileAt(coordinate) case final BoardTileV2 tile
            when tile.kind == BoardTileKindV2.operator)
          tile.operator!,
    ];
    final bool feverWasActive = _displayFever;
    final ScoreUpdateV2 scoreUpdate = ScoringV2.accepted(
      ruleset: ruleset,
      state: _score,
      tMs: _elapsedMs,
      operators: operators,
    );
    _score = scoreUpdate.state;
    _bestCombo = _bestCombo < _score.comboCount
        ? _score.comboCount
        : _bestCombo;

    final ChainReleaseResultV2 transition = BoardEngineV2.submit(
      state: _board,
      path: committed,
      map: map,
      seed: config.seed,
    );
    if (!transition.consumed) {
      throw StateError(
        'A target-matching validated chain failed board transition: '
        '${transition.status}',
      );
    }
    _board = transition.board;
    _targetsSolved++;
    _lastChainCorrect = true;
    _phase = GamePhase.successFeedback;
    _phaseUntilMs = _elapsedMs + _successFeedbackMs;

    final bool completedMode = modeController.completesAfterSolve(
      _targetsSolved,
    );
    if (completedMode) {
      _pendingLevelFinish = true;
    }

    _emit();
    _signal(
      GameEvent(
        GameSignal.equationCorrect,
        value: _score.comboCount,
        cells: committed,
      ),
    );
    _signal(GameEvent(GameSignal.targetMatched, cells: committed));
    if (!feverWasActive && _displayFever) {
      _signal(const GameEvent(GameSignal.feverStarted));
    }
    if (completedMode) {
      _signal(GameEvent(GameSignal.levelCompleted, value: map.order));
    }
  }

  void _reject(List<AxialCoordinate> committed) {
    _score = ScoringV2.rejected(
      ruleset: ruleset,
      state: _score,
      tMs: _elapsedMs,
    ).state;
    _lastChainCorrect = false;
    _phase = GamePhase.errorFeedback;
    _phaseUntilMs = _elapsedMs + _errorFeedbackMs;
    _emit();
    _signal(GameEvent(GameSignal.equationIncorrect, cells: committed));
  }

  void _rewindIncomplete() {
    _chain = null;
    _phase = _restingPhase;
    _emit();
    _signal(const GameEvent(GameSignal.incompleteRewind));
  }

  /// Advances both timed and Endless runs; Endless still needs a deterministic
  /// event timestamp for scoring and replay, it simply has no deadline.
  void tick(int dtMs) {
    if (_phase == GamePhase.finished || _paused || dtMs <= 0) {
      return;
    }
    final bool feverBefore = _displayFever;
    _elapsedMs += dtMs;
    final int? duration = runDurationMs;
    if (duration != null && _elapsedMs > duration) {
      _elapsedMs = duration;
    }

    bool finishAfterFeedback = false;
    if (_phase == GamePhase.successFeedback ||
        _phase == GamePhase.errorFeedback) {
      if (_elapsedMs >= _phaseUntilMs) {
        finishAfterFeedback = _pendingLevelFinish;
        _phase = _restingPhase;
      }
    }

    if (duration != null && _elapsedMs >= duration) {
      _finish();
      return;
    }
    if (finishAfterFeedback) {
      _finish();
      return;
    }

    _emitOnTick();
    if (feverBefore && !_displayFever) {
      _signal(const GameEvent(GameSignal.feverEnded));
    }
  }

  void togglePause() {
    if (_phase == GamePhase.finished) {
      return;
    }
    if (_paused) {
      _paused = false;
      _phase = _restingPhase;
    } else {
      _paused = true;
      _chain = null;
      _phase = GamePhase.paused;
    }
    _emit();
  }

  /// The only normal completion action for Endless. Other modes finish from
  /// their timer/quota policies and ignore this call.
  void finishManually() {
    if (modeController.allowsManualFinish && _phase != GamePhase.finished) {
      _finish();
    }
  }

  void _finish() {
    if (_phase == GamePhase.finished) {
      return;
    }
    _chain = null;
    _paused = false;
    _pendingLevelFinish = false;
    _phase = GamePhase.finished;
    _emit();
    _signal(const GameEvent(GameSignal.runFinished));
  }

  bool get _displayFever =>
      _score.feverActive && _elapsedMs < _score.feverEndsAtMs;

  bool get _comboWindowOpen {
    final int? last = _score.lastAcceptedAtMs;
    return last != null && _elapsedMs - last <= ruleset.combo.windowMs;
  }

  GamePhase get _restingPhase =>
      _displayFever ? GamePhase.feverActive : GamePhase.idle;

  int? get _displayedSecond {
    final int? duration = runDurationMs;
    return duration == null ? null : ((duration - _elapsedMs) / 1000).ceil();
  }

  int? get _rating => modeController.rating(
    targetsSolved: _targetsSolved,
    score: _score.totalScore,
  );

  GameSnapshotV2 _buildSnapshot() {
    final int? duration = runDurationMs;
    return GameSnapshotV2(
      phase: _phase,
      mode: config.mode,
      mapId: map.id,
      mapName: map.name,
      score: _score.totalScore,
      timeRemainingMs: duration == null ? null : duration - _elapsedMs,
      comboCount: _comboWindowOpen ? _score.comboCount : 0,
      feverActive: _displayFever,
      feverEnergy: _score.feverEnergy,
      feverThreshold: ruleset.fever.threshold,
      target: _board.target,
      expression: _chain?.formattedExpression ?? '',
      pathLength: _chain?.path.length ?? 0,
      boardRevision: _board.revision,
      targetsSolved: _targetsSolved,
      targetQuota: targetQuota,
      bestCombo: _bestCombo,
      rating: _rating,
      levelCompleted: _targetsSolved >= (targetQuota ?? 1 << 30),
      lastChainCorrect: _lastChainCorrect,
    );
  }

  void _emit() {
    _lastEmittedSecond = _displayedSecond;
    _lastEmittedFever = _displayFever;
    _lastEmittedComboOpen = _comboWindowOpen;
    notifier.value = _buildSnapshot();
  }

  void _emitOnTick() {
    if (_displayedSecond != _lastEmittedSecond ||
        _displayFever != _lastEmittedFever ||
        _comboWindowOpen != _lastEmittedComboOpen ||
        notifier.value.phase != _phase) {
      _emit();
    }
  }

  void _signal(GameEvent event) => onEvent?.call(event);

  void dispose() => notifier.dispose();

  static GameSnapshotV2 _emptySnapshot({
    required RulesetV2 ruleset,
    required GameSessionConfig config,
    required MapDefinitionV2 map,
  }) {
    final int? duration =
        config.durationMs ??
        ModeCatalogV1.definition(config.mode.wireName).durationFor(map);
    return GameSnapshotV2(
      phase: GamePhase.idle,
      mode: config.mode,
      mapId: map.id,
      mapName: map.name,
      score: 0,
      timeRemainingMs: duration,
      comboCount: 0,
      feverActive: false,
      feverEnergy: 0,
      feverThreshold: ruleset.fever.threshold,
      target: 0,
      expression: '',
      pathLength: 0,
      boardRevision: 0,
      targetsSolved: 0,
      targetQuota: ModeCatalogV1.definition(
        config.mode.wireName,
      ).targetQuotaFor(map),
      bestCombo: 0,
      rating: config.mode == V2GameMode.level ? 0 : null,
      levelCompleted: false,
      lastChainCorrect: null,
    );
  }
}
