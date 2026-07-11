/// The explicit gameplay state machine states (mobile AGENTS.md "State machine").
/// Avoids boolean soup: exactly one phase is active at a time.
enum GamePhase {
  /// No selection in progress; ready for input.
  idle,

  /// A finger path is being drawn.
  selecting,

  /// Evaluating a released path (transient).
  validating,

  /// Brief celebration after a correct equation.
  successFeedback,

  /// Brief feedback after a complete-but-wrong equation.
  errorFeedback,

  /// The board is being replaced after a level completes.
  levelTransition,

  /// Fever is igniting (short entering flourish).
  feverEntering,

  /// Fever is active and input is accepted.
  feverActive,

  /// Fever is winding down.
  feverExiting,

  /// The run is paused; the clock is frozen.
  paused,

  /// The 60-second run has ended.
  finished,
}

extension GamePhaseX on GamePhase {
  /// Phases from which a new selection may begin.
  bool get acceptsPress =>
      this == GamePhase.idle ||
      this == GamePhase.feverActive ||
      this == GamePhase.successFeedback ||
      this == GamePhase.errorFeedback;

  bool get isFinished => this == GamePhase.finished;
}
