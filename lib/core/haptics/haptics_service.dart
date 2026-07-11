import 'package:flutter/services.dart';

/// Haptic intensity levels the game asks for.
enum HapticLevel { light, medium, heavy, selection }

/// Wraps [HapticFeedback] behind a single on/off gate. When disabled in settings,
/// no platform haptic is ever requested.
class HapticsService {
  HapticsService({this.enabled = true});

  /// When false, [fire] is a no-op and no platform haptic is requested.
  bool enabled;

  void fire(HapticLevel level) {
    if (!enabled) {
      return;
    }
    switch (level) {
      case HapticLevel.light:
        HapticFeedback.lightImpact();
      case HapticLevel.medium:
        HapticFeedback.mediumImpact();
      case HapticLevel.heavy:
        HapticFeedback.heavyImpact();
      case HapticLevel.selection:
        HapticFeedback.selectionClick();
    }
  }
}
