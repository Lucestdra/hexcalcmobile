import 'package:flutter/widgets.dart';

import 'app_colors.dart';

/// Typography tokens. Space Grotesk (UI) and a mono family (score/timer/equation)
/// are bundled in a later phase; Phase 3 falls back to the platform families of
/// the same character so layout and sizing are already tokenized.
abstract final class AppTypography {
  static const String _display = 'SpaceGrotesk';
  static const String _mono = 'SpaceMono';

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
