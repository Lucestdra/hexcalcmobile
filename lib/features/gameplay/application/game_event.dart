import '../domain/domain.dart';

/// A discrete, one-shot gameplay signal emitted by the [GameController] at the
/// moment something happens (not a per-frame state — that is [GameSnapshot]).
///
/// The presentation layer fans these out to audio, haptics, analytics, and the
/// Flame choreography. Keeping them here means the controller stays pure Dart and
/// never imports Flutter, Flame, or any service.
enum GameSignal {
  runStarted,
  cellSelected,
  pathBacktrack,
  equationCorrect,
  targetMatched,
  equationIncorrect,
  incompleteRewind,
  feverStarted,
  feverEnded,
  levelCompleted,
  runFinished,
}

/// A [GameSignal] plus the minimal payload an effect needs: [value] carries a
/// count (e.g. the selection length for a rising note, or the combo count), and
/// [cells] carries the committed equation path for spatial effects.
class GameEvent {
  const GameEvent(
    this.signal, {
    this.value = 0,
    this.cells = const <AxialCoordinate>[],
  });

  final GameSignal signal;
  final int value;
  final List<AxialCoordinate> cells;
}
