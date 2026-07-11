import 'package:flutter/animation.dart';

/// Motion tokens. No magic durations in feature code.
/// Product timing from the mobile AGENTS.md "Motion Review Checklist".
abstract final class AppMotion {
  /// Press acknowledgement (60–90 ms).
  static const Duration press = Duration(milliseconds: 80);

  /// Correct-equation success sequence (350–550 ms).
  static const Duration success = Duration(milliseconds: 420);

  /// Error feedback (short shake + glow decay).
  static const Duration error = Duration(milliseconds: 260);

  /// Fever enter/exit transitions.
  static const Duration feverTransition = Duration(milliseconds: 320);

  /// Board level transition.
  static const Duration levelTransition = Duration(milliseconds: 480);

  /// Result cell pop scale range.
  static const double resultPopScaleMin = 1.05;
  static const double resultPopScaleMax = 1.10;

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutBack;
}
