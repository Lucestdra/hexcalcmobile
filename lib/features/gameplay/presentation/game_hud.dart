import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../application/game_phase.dart';
import '../application/game_snapshot.dart';

/// The heads-up display, built purely from an immutable [GameSnapshot].
class GameHud extends StatelessWidget {
  const GameHud({
    required this.snapshot,
    required this.onPause,
    this.reducedMotion = false,
    super.key,
  });

  final GameSnapshot snapshot;
  final VoidCallback onPause;

  /// When true, the score updates instantly instead of counting up (no travel).
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    final Color energy = snapshot.feverActive
        ? AppColors.feverMagenta
        : AppColors.neonBlue;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ScoreStat(score: snapshot.score, reducedMotion: reducedMotion),
                const Spacer(),
                _Stat(
                  label: 'TIME',
                  value: '${snapshot.timeRemainingSeconds}',
                  color: snapshot.timeRemainingSeconds <= 10
                      ? AppColors.feverMagenta
                      : AppColors.primaryText,
                ),
                const Spacer(),
                IconButton(
                  onPressed: onPause,
                  icon: const Icon(
                    Icons.pause_rounded,
                    color: AppColors.secondaryText,
                  ),
                  tooltip: 'Pause',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: energy.withValues(alpha: 0.6),
                  width: AppStroke.thin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'TARGET',
                    style: AppTypography.hudLabel.copyWith(color: energy),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${snapshot.target}',
                    style: AppTypography.hudNumeric.copyWith(fontSize: 26),
                  ),
                ],
              ),
            ),
            const Spacer(),
            _BottomBar(snapshot: snapshot, energy: energy),
          ],
        ),
      ),
    );
  }
}

/// The score stat with a count-up "travel" as it rises (instant under reduced
/// motion). Score is monotonic within a run, so this always counts upward.
class _ScoreStat extends StatelessWidget {
  const _ScoreStat({required this.score, required this.reducedMotion});

  final int score;
  final bool reducedMotion;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text('SCORE', style: AppTypography.hudLabel),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: score),
          duration: reducedMotion ? Duration.zero : AppMotion.success,
          curve: AppMotion.standard,
          builder: (BuildContext context, int value, _) {
            return Text('$value', style: AppTypography.hudNumeric);
          },
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: AppTypography.hudLabel),
        Text(
          value,
          style: AppTypography.hudNumeric.copyWith(
            color: color ?? AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.snapshot, required this.energy});

  final GameSnapshot snapshot;
  final Color energy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        if (snapshot.comboCount >= 2)
          _Pill(text: 'COMBO x${snapshot.comboCount}', color: energy),
        const Spacer(),
        if (snapshot.feverActive)
          const _Pill(text: 'FEVER', color: AppColors.feverMagenta)
        else
          _FeverMeter(
            energy: snapshot.feverEnergy,
            threshold: snapshot.feverThreshold,
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: color, width: AppStroke.thin),
      ),
      child: Text(
        text,
        style: AppTypography.hudLabel.copyWith(
          color: color,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _FeverMeter extends StatelessWidget {
  const _FeverMeter({required this.energy, required this.threshold});

  final int energy;
  final int threshold;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text('FEVER $energy/$threshold', style: AppTypography.hudLabel),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.pill),
            child: LinearProgressIndicator(
              value: threshold == 0 ? 0 : energy / threshold,
              minHeight: 5,
              backgroundColor: AppColors.inactiveCell,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.neonBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A translucent pause overlay.
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.onResume,
    required this.onQuit,
    this.onSettings,
    super.key,
  });

  final VoidCallback onResume;
  final VoidCallback onQuit;
  final VoidCallback? onSettings;

  @override
  Widget build(BuildContext context) {
    // Absorb background taps so board gestures cannot leak through while paused;
    // the buttons below still receive their own taps.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: AppColors.background.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('PAUSED', style: AppTypography.title.copyWith(fontSize: 28)),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: onResume, child: const Text('Resume')),
              const SizedBox(height: AppSpacing.sm),
              if (onSettings != null)
                TextButton(
                  onPressed: onSettings,
                  child: const Text('Settings'),
                ),
              TextButton(onPressed: onQuit, child: const Text('Quit run')),
            ],
          ),
        ),
      ),
    );
  }
}

extension GamePhaseHud on GamePhase {
  bool get isPaused => this == GamePhase.paused;
}
