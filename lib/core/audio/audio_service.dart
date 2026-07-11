import '../settings/app_settings.dart';

/// The distinct one-shot sounds the game triggers.
enum Sfx { uiTap, correct, target, invalid, fever }

/// The audio seam. The real implementation ([FlameAudioService]) drives
/// flame_audio; tests and headless contexts use [NoopAudioService]. The service
/// owns the current volumes so callers never pass them per-play.
abstract interface class AudioService {
  Future<void> preload();
  void applySettings(AppSettings settings);

  /// Plays a fixed one-shot effect.
  void play(Sfx sfx);

  /// Plays a rising path note whose pitch grows with [selectionLength] (1-based).
  void playPathNote(int selectionLength);

  void dispose();
}

/// Ignores everything. Used in tests/widget contexts where no audio device or
/// platform channel is available.
class NoopAudioService implements AudioService {
  const NoopAudioService();

  @override
  Future<void> preload() async {}

  @override
  void applySettings(AppSettings settings) {}

  @override
  void play(Sfx sfx) {}

  @override
  void playPathNote(int selectionLength) {}

  @override
  void dispose() {}
}
