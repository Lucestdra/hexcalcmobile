import 'package:flutter/painting.dart';

/// HEX • CALC color tokens. No color literal may appear outside this layer.
/// See the mobile AGENTS.md "Visual Design System".
abstract final class AppColors {
  /// Near-black background (not pure black).
  static const Color background = Color(0xFF05070A);

  /// A slightly raised surface for panels/HUD.
  static const Color surface = Color(0xFF0B0F14);

  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFFAEB6BD);

  /// Inactive cell fill and border.
  static const Color inactiveCell = Color(0xFF151B20);
  static const Color inactiveBorder = Color(0xFF34434D);

  /// Electric blue neon — selection, success, active energy, focused CTA.
  static const Color neonBlue = Color(0xFF00BDF2);

  /// Controlled magenta — Fever only.
  static const Color feverMagenta = Color(0xFFFF2D9B);

  /// Restrained warning for wrong results (secondary, never the main palette).
  static const Color warning = Color(0xFFB2606A);
}
