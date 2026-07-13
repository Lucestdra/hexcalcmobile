import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';

/// Entry point for the shared v2 engine. Modes only choose run policy; the board,
/// swipe, evaluator, targets, scoring, and feedback remain one implementation.
class ModeSelectionScreen extends StatelessWidget {
  const ModeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: const Text('CHOOSE MODE', style: AppTypography.hudLabel),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: <Widget>[
            _ModeCard(
              icon: Icons.timer_outlined,
              title: 'Time Attack',
              detail: 'Solve as many targets as you can in 60 seconds.',
              onTap: () => context.go('/play-v2'),
            ),
            _ModeCard(
              icon: Icons.map_outlined,
              title: 'Level Mode',
              detail: 'Progress through maps and earn up to three stars.',
              onTap: () => context.push('/levels'),
            ),
            _ModeCard(
              icon: Icons.all_inclusive_rounded,
              title: 'Endless',
              detail: 'No timer. Keep solving until you choose to finish.',
              onTap: () => context.push('/endless-maps'),
            ),
            _ModeCard(
              icon: Icons.emoji_events_outlined,
              title: 'Ranked',
              detail: 'A verified 60-second run for the weekly leaderboard.',
              onTap: () => context.push('/ranked'),
            ),
            _ModeCard(
              icon: Icons.today_outlined,
              title: 'Daily Challenge',
              detail: 'One fixed verified map and one scored attempt each day.',
              onTap: () => context.push('/daily'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Semantics(
        button: true,
        label: '$title. $detail',
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadii.lg),
              border: Border.all(
                color: AppColors.inactiveBorder,
                width: AppStroke.thin,
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(icon, color: AppColors.neonBlue, size: 34),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: AppTypography.body.copyWith(
                          color: AppColors.primaryText,
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        detail,
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
