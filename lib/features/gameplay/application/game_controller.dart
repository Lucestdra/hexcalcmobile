import 'package:flutter/foundation.dart';

import '../domain/domain.dart';
import 'game_phase.dart';
import 'game_snapshot.dart';

/// The pure-Dart gameplay controller: owns the board, the current selection path,
/// the run clock, and the authoritative event log. Scoring/combo/Fever come from
/// the shared [ReplayEngine] on the event log, so the live HUD score always equals
/// what the backend would verify. No Flutter widgets, no Flame — just [ValueNotifier].
class GameController {
  GameController({required this.ruleset, required this.seed});

  final Ruleset ruleset;
  final String seed;

  // Transient feedback-phase durations (ms). Kept here so the application layer
  // stays pure Dart; the presentation layer maps phases to motion tokens.
  static const int _successFeedbackMs = 420;
  static const int _errorFeedbackMs = 260;
  static const int _feverEnterMs = 320;
  static const int _feverExitMs = 320;
  static const int _levelTransitionMs = 480;

  final ValueNotifier<GameSnapshot> notifier = ValueNotifier<GameSnapshot>(
    GameSnapshot.empty,
  );

  late Board _board;
  final Map<AxialCoordinate, BoardCell> _cellByCoord =
      <AxialCoordinate, BoardCell>{};
  final List<AxialCoordinate> _path = <AxialCoordinate>[];
  final List<RunEvent> _events = <RunEvent>[];

  GamePhase _phase = GamePhase.idle;
  int _phaseUntilMs = 0;
  int _levelIndex = 0;
  int _elapsedMs = 0;
  bool _paused = false;

  bool _feverDisplay = false;
  int _feverEndsAtMs = 0;
  bool? _lastCorrect;
  int _equationsSolved = 0;
  int _bestCombo = 0;
  bool _hasLastCorrect = false;
  int _lastCorrectTMs = 0;

  // Display signals tracked so the per-frame tick emits only on meaningful change.
  int _lastEmittedSecond = -1;
  bool _lastEmittedFever = false;
  bool _lastEmittedComboOpen = false;

  ReplayOutcome _replay = const ReplayOutcome(
    ReplayResult(
      totalScore: 0,
      comboCount: 0,
      consecutiveCorrect: 0,
      feverEnergy: 0,
      feverActive: false,
      level: 0,
      equationsThisLevel: 0,
    ),
    <int>[],
  );

  Board get board => _board;
  List<AxialCoordinate> get path => List<AxialCoordinate>.unmodifiable(_path);
  GamePhase get phase => _phase;
  int get runDurationMs => ruleset.run.durationMs;

  BoardCell? cellAt(AxialCoordinate c) => _cellByCoord[c];

  /// (Re)starts a run from level 0.
  void startRun() {
    _levelIndex = 0;
    _board = BoardGeneratorV1.generate(seed, ruleset.rulesetVersion, 0);
    _rebuildCellMap();
    _path.clear();
    _events.clear();
    _elapsedMs = 0;
    _paused = false;
    _feverDisplay = false;
    _feverEndsAtMs = 0;
    _lastCorrect = null;
    _equationsSolved = 0;
    _bestCombo = 0;
    _hasLastCorrect = false;
    _lastCorrectTMs = 0;
    _lastEmittedSecond = -1;
    _lastEmittedFever = false;
    _lastEmittedComboOpen = false;
    _replay = ReplayEngine.replay(ruleset, _events);
    _phase = GamePhase.idle;
    _emit();
  }

  /// True while the combo can still be continued (within the ruleset window of
  /// the last correct equation). Drives the HUD combo pill decay.
  bool get _comboWindowOpen =>
      _hasLastCorrect &&
      (_elapsedMs - _lastCorrectTMs) <= ruleset.combo.windowMs;

  /// Begins a selection at a number cell.
  void pressCell(AxialCoordinate coord) {
    if (_paused || !_phase.acceptsPress) {
      return;
    }
    final BoardCell? cell = _cellByCoord[coord];
    if (cell == null || cell.kind != CellKind.number) {
      return;
    }
    _path
      ..clear()
      ..add(coord);
    _phase = GamePhase.selecting;
    _emit();
  }

  /// Extends (or backtracks) the selection to an adjacent cell during a drag.
  void extendToCell(AxialCoordinate coord) {
    if (_phase != GamePhase.selecting) {
      return;
    }

    // Backtrack: dragging back onto the previous cell pops the last selection.
    if (_path.length >= 2 && coord == _path[_path.length - 2]) {
      _path.removeLast();
      _emit();
      return;
    }

    if (_path.contains(coord)) {
      return; // no-repeat
    }
    if (!Hex.areAdjacent(_path.last, coord)) {
      return; // only physical neighbors
    }
    final BoardCell? cell = _cellByCoord[coord];
    if (cell == null) {
      return;
    }

    final List<Token> tokens = <Token>[
      for (final AxialCoordinate c in _path) _cellByCoord[c]!.toToken(),
      cell.toToken(),
    ];
    if (classifyPrefix(tokens) == PrefixClass.dead) {
      return; // would not lead to a valid equation
    }

    _path.add(coord);
    _emit();
  }

  /// Releases the finger: validate the committed path.
  void release() {
    if (_phase != GamePhase.selecting) {
      return;
    }

    final List<Token> tokens = <Token>[
      for (final AxialCoordinate c in _path) _cellByCoord[c]!.toToken(),
    ];
    final PrefixClass cls = classifyPrefix(tokens);

    if (cls == PrefixClass.complete) {
      final EquationResult eval = EquationEvaluator.evaluate(tokens);
      if (eval.status == EquationStatus.valid) {
        _record(
          correct: true,
          matchedTarget: eval.leftHandValue == _board.target,
        );
      } else {
        _record(correct: false, matchedTarget: false);
      }
    } else {
      // Incomplete: quick rewind, no penalty.
      _path.clear();
      _phase = _restingPhase();
      _emit();
    }
  }

  void _record({required bool correct, required bool matchedTarget}) {
    final List<Operator> operators = <Operator>[
      for (final AxialCoordinate c in _path)
        if (_cellByCoord[c]!.kind == CellKind.operator)
          _cellByCoord[c]!.operator!,
    ];

    _events.add(
      RunEvent(
        tMs: _elapsedMs,
        correct: correct,
        matchedTarget: matchedTarget,
        operators: operators,
      ),
    );

    final int prevLevel = _replay.finalState.level;
    _replay = ReplayEngine.replay(ruleset, _events);
    _path.clear();
    _lastCorrect = correct;

    if (correct) {
      _equationsSolved++;
      _hasLastCorrect = true;
      _lastCorrectTMs = _elapsedMs;
      if (_replay.finalState.comboCount > _bestCombo) {
        _bestCombo = _replay.finalState.comboCount;
      }

      final bool ignited = _replay.finalState.feverActive && !_feverDisplay;
      final bool leveled = _replay.finalState.level > prevLevel;

      if (ignited) {
        _feverDisplay = true;
        _feverEndsAtMs = _elapsedMs + ruleset.fever.durationMs;
      }
      if (leveled) {
        _levelIndex = _replay.finalState.level;
        _board = BoardGeneratorV1.generate(
          seed,
          ruleset.rulesetVersion,
          _levelIndex,
        );
        _rebuildCellMap();
      }

      if (ignited) {
        _setTransient(GamePhase.feverEntering, _feverEnterMs);
      } else if (leveled) {
        _setTransient(GamePhase.levelTransition, _levelTransitionMs);
      } else {
        _setTransient(GamePhase.successFeedback, _successFeedbackMs);
      }
    } else {
      _setTransient(GamePhase.errorFeedback, _errorFeedbackMs);
    }

    _emit();
  }

  /// Advances the run clock by [dtMs]. Driven by the Flame update loop (or tests).
  void tick(int dtMs) {
    if (_phase == GamePhase.finished || _paused) {
      return;
    }

    _elapsedMs += dtMs;
    if (_elapsedMs > runDurationMs) {
      _elapsedMs = runDurationMs;
    }

    if (_feverDisplay && _elapsedMs >= _feverEndsAtMs) {
      _feverDisplay = false;
      if (_phase == GamePhase.feverActive) {
        _setTransient(GamePhase.feverExiting, _feverExitMs);
      }
    }

    if (_isTransient(_phase) && _elapsedMs >= _phaseUntilMs) {
      _phase = _restingAfter(_phase);
    }

    if (_elapsedMs >= runDurationMs) {
      _phase = GamePhase.finished;
    }

    _emitOnTick();
  }

  /// Pauses/resumes; the clock is frozen while paused.
  void togglePause() {
    if (_phase == GamePhase.finished) {
      return;
    }
    if (_paused) {
      _paused = false;
      _phase = _restingPhase();
    } else {
      _paused = true;
      _path.clear(); // drop any in-progress selection so it does not linger
      _phase = GamePhase.paused;
    }
    _emit();
  }

  void dispose() => notifier.dispose();

  // ----- internals -----

  void _rebuildCellMap() {
    _cellByCoord.clear();
    for (final BoardCell cell in _board.cells) {
      _cellByCoord[cell.coord] = cell;
    }
  }

  void _setTransient(GamePhase phase, int durationMs) {
    _phase = phase;
    _phaseUntilMs = _elapsedMs + durationMs;
  }

  static bool _isTransient(GamePhase p) =>
      p == GamePhase.successFeedback ||
      p == GamePhase.errorFeedback ||
      p == GamePhase.feverEntering ||
      p == GamePhase.feverExiting ||
      p == GamePhase.levelTransition ||
      p == GamePhase.validating;

  GamePhase _restingPhase() =>
      _feverDisplay ? GamePhase.feverActive : GamePhase.idle;

  GamePhase _restingAfter(GamePhase p) {
    if (p == GamePhase.feverEntering) {
      return _feverDisplay ? GamePhase.feverActive : GamePhase.idle;
    }
    return _restingPhase();
  }

  int get _displayedSecond => ((runDurationMs - _elapsedMs) / 1000).ceil();

  GameSnapshot _buildSnapshot() {
    final r = _replay.finalState;
    final int required =
        ruleset.level.equationsToComplete +
        ruleset.level.growthPerLevel * r.level;
    // The combo pill decays as soon as the continuation window lapses, even
    // before the next equation event recomputes the authoritative replay.
    final int displayCombo = _comboWindowOpen ? r.comboCount : 0;
    return GameSnapshot(
      phase: _phase,
      score: r.totalScore,
      timeRemainingMs: runDurationMs - _elapsedMs,
      comboCount: displayCombo,
      feverActive: _feverDisplay,
      feverEnergy: r.feverEnergy,
      feverThreshold: ruleset.fever.threshold,
      level: r.level,
      equationsThisLevel: r.equationsThisLevel,
      equationsRequiredThisLevel: required,
      target: _board.target,
      pathLength: _path.length,
      lastEquationCorrect: _lastCorrect,
      equationsSolved: _equationsSolved,
      bestCombo: _bestCombo,
    );
  }

  void _emit() {
    _lastEmittedSecond = _displayedSecond;
    _lastEmittedFever = _feverDisplay;
    _lastEmittedComboOpen = _comboWindowOpen;
    notifier.value = _buildSnapshot();
  }

  /// On the per-frame tick, only emit when a HUD-visible signal changes — the
  /// displayed second, the phase, the Fever state, or combo-window lapse — so we
  /// avoid per-frame Flutter rebuilds while never showing stale state.
  void _emitOnTick() {
    if (_displayedSecond != _lastEmittedSecond ||
        notifier.value.phase != _phase ||
        _feverDisplay != _lastEmittedFever ||
        _comboWindowOpen != _lastEmittedComboOpen) {
      _emit();
    }
  }
}
