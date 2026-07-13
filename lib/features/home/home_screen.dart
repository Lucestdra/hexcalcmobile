import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/providers.dart';
import '../../core/design_system/design_system.dart';
import '../gameplay/persistence/app_database.dart';
import '../gameplay/persistence/run_history_repository.dart';
import '../leaderboard/application/leaderboard_providers.dart';
import '../onboarding/application/onboarding_controller.dart';
import '../onboarding/presentation/onboarding_overlay.dart';

/// Home: wordmark, personal best, Play, recent runs, and a settings entry.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RunStats> stats = ref.watch(runStatsProvider);
    final AsyncValue<List<RunSummary>> recent = ref.watch(recentRunsProvider);
    final int personalBest = stats.asData?.value.personalBest ?? 0;
    final bool onboardingSeen = ref.watch(onboardingControllerProvider);

    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(
                          Icons.person_rounded,
                          color: AppColors.secondaryText,
                        ),
                        tooltip: 'Profile',
                        onPressed: () => context.push('/profile'),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_rounded,
                          color: AppColors.secondaryText,
                        ),
                        tooltip: 'Settings',
                        onPressed: () => context.push('/settings'),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Center(
                    child: Semantics(
                      header: true,
                      child: const Text(
                        'HEX • CALC',
                        style: AppTypography.title,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Center(
                    child: Text(
                      'swipe the math',
                      style: AppTypography.body.copyWith(
                        color: AppColors.neonBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  _PersonalBest(score: personalBest),
                  const SizedBox(height: AppSpacing.sm),
                  const _RankTeaser(),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => context.go('/play'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.neonBlue,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                    child: const Text('PLAY'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _SecondaryButton(
                          label: 'RANKED',
                          onPressed: () => context.push('/ranked'),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _SecondaryButton(
                          label: 'DAILY',
                          onPressed: () => context.push('/daily'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _RecentRuns(recent: recent),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
        if (!onboardingSeen) const OnboardingOverlay(),
      ],
    );
  }
}

/// A neon secondary action used for the RANKED / DAILY entries.
class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.neonBlue,
        side: BorderSide(
          color: AppColors.neonBlue.withValues(alpha: 0.5),
          width: AppStroke.thin,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      ),
      child: Text(label),
    );
  }
}

/// A best-effort weekly-rank teaser that doubles as the leaderboard entry point.
/// Shows the player's rank when known, otherwise a neutral "View" — it never
/// blocks or errors the home screen (the underlying provider swallows failures).
class _RankTeaser extends ConsumerWidget {
  const _RankTeaser();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int? rank = ref.watch(weeklyRankTeaserProvider).asData?.value;
    return InkWell(
      onTap: () => context.push('/leaderboard'),
      borderRadius: BorderRadius.circular(AppRadii.lg),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: AppColors.inactiveBorder,
            width: AppStroke.thin,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            const Text('WEEKLY RANK', style: AppTypography.hudLabel),
            Row(
              children: <Widget>[
                Text(
                  rank != null ? '#$rank' : 'View',
                  style: AppTypography.hudNumeric.copyWith(
                    color: AppColors.neonBlue,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.secondaryText,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalBest extends StatelessWidget {
  const _PersonalBest({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.4),
          width: AppStroke.thin,
        ),
      ),
      child: Semantics(
        label: 'Personal best: $score',
        child: ExcludeSemantics(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              const Text('PERSONAL BEST', style: AppTypography.hudLabel),
              Text('$score', style: AppTypography.hudNumeric),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentRuns extends StatelessWidget {
  const _RecentRuns({required this.recent});

  final AsyncValue<List<RunSummary>> recent;

  @override
  Widget build(BuildContext context) {
    final List<RunSummary> runs = recent.asData?.value ?? const <RunSummary>[];
    if (runs.isEmpty) {
      return Text(
        recent.isLoading ? 'Loading history…' : 'No runs yet — play one!',
        style: AppTypography.hudLabel,
        textAlign: TextAlign.center,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('RECENT RUNS', style: AppTypography.hudLabel),
        const SizedBox(height: AppSpacing.xs),
        for (final RunSummary r in runs)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '${r.equations} eq · x${r.bestCombo}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${r.score}',
                  style: AppTypography.body.copyWith(
                    color: AppColors.primaryText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
