import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../application/game_snapshot_v2.dart';

class GameHudV2 extends StatelessWidget {
  const GameHudV2({
    required this.snapshot,
    required this.onPause,
    this.reducedMotion = false,
    super.key,
  });

  final GameSnapshotV2 snapshot;
  final VoidCallback onPause;
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
              children: <Widget>[
                _HudValue(label: 'SCORE', value: '${snapshot.score}'),
                const Spacer(),
                if (snapshot.timeRemainingSeconds case final int seconds)
                  _HudValue(
                    label: 'TIME',
                    value: '$seconds',
                    color: seconds <= 10
                        ? AppColors.feverMagenta
                        : AppColors.primaryText,
                  )
                else
                  const _HudValue(label: 'MODE', value: '∞'),
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
            const SizedBox(height: AppSpacing.sm),
            Text(
              snapshot.mapName.toUpperCase(),
              style: AppTypography.hudLabel.copyWith(
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppRadii.pill),
                border: Border.all(
                  color: energy.withValues(alpha: 0.65),
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
            const SizedBox(height: AppSpacing.sm),
            AnimatedSwitcher(
              duration: reducedMotion ? Duration.zero : AppMotion.press,
              child: Text(
                snapshot.expression.isEmpty ? ' ' : snapshot.expression,
                key: ValueKey<String>(snapshot.expression),
                style: AppTypography.hudNumeric.copyWith(fontSize: 22),
                textAlign: TextAlign.center,
              ),
            ),
            const Spacer(),
            Row(
              children: <Widget>[
                if (snapshot.targetQuota case final int quota)
                  _StatusPill(
                    text: '${snapshot.targetsSolved}/$quota TARGETS',
                    color: energy,
                  )
                else
                  _StatusPill(
                    text: '${snapshot.targetsSolved} SOLVED',
                    color: energy,
                  ),
                const Spacer(),
                if (snapshot.feverActive)
                  const _StatusPill(
                    text: 'FEVER',
                    color: AppColors.feverMagenta,
                  )
                else if (snapshot.comboCount >= 2)
                  _StatusPill(
                    text: 'COMBO x${snapshot.comboCount}',
                    color: energy,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HudValue extends StatelessWidget {
  const _HudValue({required this.label, required this.value, this.color});

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

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.text, required this.color});

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
      child: Text(text, style: AppTypography.hudLabel.copyWith(color: color)),
    );
  }
}
