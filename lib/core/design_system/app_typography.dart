import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Typography tokens. Space Grotesk (UI) and Space Mono (score/timer/equation)
/// are bundled under `assets/fonts/` (OFL, see the license files there), so
/// rendering is now consistent across platforms — which also makes goldens
/// deterministic.
abstract final class AppTypography {
  /// UI/display family (Space Grotesk). Also set as the app-wide default font.
  static const String uiFamily = 'SpaceGrotesk';

  /// Monospace family (Space Mono) for score/timer/equation glyphs.
  static const String monoFamily = 'SpaceMono';

  static const String _display = uiFamily;
  static const String _mono = monoFamily;

  /// Large HUD numerics (score, timer) — monospace for stable digit width.
  static const TextStyle hudNumeric = TextStyle(
    fontFamily: _mono,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 1,
  );

  static const TextStyle hudLabel = TextStyle(
    fontFamily: _display,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.secondaryText,
    letterSpacing: 2,
  );

  static const TextStyle cellNumber = TextStyle(
    fontFamily: _mono,
    fontFamilyFallback: <String>['monospace'],
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: _display,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    letterSpacing: 6,
  );

  static const TextStyle body = TextStyle(
    fontFamily: _display,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
  );

  static const TextStyle button = TextStyle(
    fontFamily: _display,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.background,
    letterSpacing: 1,
  );
}
