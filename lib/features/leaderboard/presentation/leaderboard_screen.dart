import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/api/dtos.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/errors/app_error.dart';
import '../application/freshness.dart';
import '../application/leaderboard_providers.dart';
import '../application/leaderboard_repository.dart';

/// The weekly leaderboard: the top 100 plus the player's own ±5 window, backed by
/// a Drift cache so saved standings show (with a freshness stamp) when offline.
/// Renders every async state — loading, content, empty, offline-cached, offline,
/// and recoverable error — and never presents an unverified run as a confirmed
/// rank (locally-pending runs are marked distinctly instead).
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    // Log once on view (a product-funnel question, no PII).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(analyticsProvider)
            .logEvent(AnalyticsEvent.leaderboardViewed());
      }
    });
  }

  Future<void> _refresh() async {
    ref.invalidate(weeklyLeaderboardProvider);
    try {
      await ref.read(weeklyLeaderboardProvider.future);
    } on AppError {
      // The error state is already rendered from the provider; swallow so the
      // pull-to-refresh spinner completes cleanly.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<LeaderboardData> async = ref.watch(
      weeklyLeaderboardProvider,
    );
    final int pending =
        ref.watch(pendingRankedCountProvider).asData?.value ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: const Text('LEADERBOARD', style: AppTypography.hudLabel),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => ref.invalidate(weeklyLeaderboardProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.neonBlue,
          backgroundColor: AppColors.surface,
          onRefresh: _refresh,
          child: async.when(
            loading: () => const _CenteredScrollable(
              child: CircularProgressIndicator(color: AppColors.neonBlue),
            ),
            error: (Object error, _) => _CenteredScrollable(
              child: _ErrorState(
                error: error,
                onRetry: () => ref.invalidate(weeklyLeaderboardProvider),
              ),
            ),
            data: (LeaderboardData data) =>
                _Content(data: data, pending: pending),
          ),
        ),
      ),
    );
  }
}

/// A scrollable wrapper so the loading/error/empty states still respond to
/// pull-to-refresh (an [AlwaysScrollableScrollPhysics] over a full-height box).
class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(child: child),
            ),
          ),
        );
      },
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.data, required this.pending});

  final LeaderboardData data;
  final int pending;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return _CenteredScrollable(
        child: _EmptyState(data: data, pending: pending),
      );
    }

    final List<LeaderboardEntryView> top = data.top.entries;
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              0,
            ),
            child: _Header(data: data, pending: pending),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverList.builder(
            itemCount: top.length,
            itemBuilder: (BuildContext context, int i) =>
                _EntryRow(entry: top[i]),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.pending});

  final LeaderboardData data;
  final int pending;

  @override
  Widget build(BuildContext context) {
    // The ±5 "around you" window only adds information for the rows that aren't
    // already in the visible top page — a player near the cutoff has a window
    // that overlaps the top list, so we drop those overlapping rows (rather than
    // toggling the whole section) to avoid rendering duplicates.
    final int topCount = data.top.entries.length;
    final List<LeaderboardEntryView> windowBelowTop = data.me.window
        .where((LeaderboardEntryView e) => e.rank > topCount)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (data.isFromCache) _StaleBanner(cachedAtMs: data.cachedAtMs),
        if (pending > 0) _PendingBanner(count: pending),
        _YouCard(me: data.me, pending: pending),
        if (windowBelowTop.isNotEmpty) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          const _SectionLabel('AROUND YOU'),
          const SizedBox(height: AppSpacing.xs),
          for (final LeaderboardEntryView e in windowBelowTop)
            _EntryRow(entry: e),
        ],
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel('TOP 100'),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) =>
      Text(text, style: AppTypography.hudLabel);
}

/// The player's own standing, emphasised in neon. Shows the confirmed rank, or an
/// honest "not ranked yet" / "being verified" when there is no verified score.
class _YouCard extends StatelessWidget {
  const _YouCard({required this.me, required this.pending});

  final MyWeeklyRankResponse me;
  final int pending;

  @override
  Widget build(BuildContext context) {
    final int? rank = me.rank;
    final String detail = rank != null
        ? 'of ${me.totalPlayers} this week'
        : pending > 0
        ? 'Your latest run is being verified'
        : 'Play a ranked run to get on the board';

    return Semantics(
      label: rank != null
          ? 'Your rank $rank of ${me.totalPlayers}'
          : 'You are not ranked yet',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: AppColors.neonBlue,
            width: AppStroke.medium,
          ),
        ),
        child: Row(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('YOU', style: AppTypography.hudLabel),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  detail,
                  style: AppTypography.body.copyWith(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              rank != null ? '#$rank' : '—',
              style: AppTypography.hudNumeric.copyWith(
                color: AppColors.neonBlue,
                fontSize: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One leaderboard row: rank · name · score. The current player's row is
/// emphasised so it is findable without relying on colour alone (a "You" tag).
class _EntryRow extends StatelessWidget {
  const _EntryRow({required this.entry});

  final LeaderboardEntryView entry;

  @override
  Widget build(BuildContext context) {
    final bool mine = entry.isCurrentPlayer;
    final Color rankColor = mine ? AppColors.neonBlue : AppColors.secondaryText;
    final String name = entry.displayName.isEmpty
        ? 'Player'
        : entry.displayName;

    return Semantics(
      // A single composed label so a screen reader announces one coherent row
      // ("Rank 3, Ada, score 1990") instead of three disconnected numbers.
      label:
          'Rank ${entry.rank}, $name${mine ? ' (you)' : ''}, score ${entry.score}',
      child: ExcludeSemantics(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs / 2),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: mine ? AppColors.surface : null,
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: mine
                ? Border.all(
                    color: AppColors.neonBlue.withValues(alpha: 0.6),
                    width: AppStroke.thin,
                  )
                : null,
          ),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 44,
                child: Text(
                  '${entry.rank}',
                  style: AppTypography.hudNumeric.copyWith(
                    fontSize: 18,
                    color: rankColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.body.copyWith(
                          color: AppColors.primaryText,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    if (mine) ...<Widget>[
                      const SizedBox(width: AppSpacing.sm),
                      const _YouTag(),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '${entry.score}',
                style: AppTypography.hudNumeric.copyWith(fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _YouTag extends StatelessWidget {
  const _YouTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs / 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadii.pill),
      ),
      child: Text(
        'YOU',
        style: AppTypography.hudLabel.copyWith(
          color: AppColors.neonBlue,
          fontSize: 10,
        ),
      ),
    );
  }
}

/// "Saved standings" freshness banner shown when the board is served from cache.
class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.cachedAtMs});

  final int? cachedAtMs;

  @override
  Widget build(BuildContext context) {
    final String age = cachedAtMs == null
        ? ''
        : ' · as of ${freshnessLabel(cachedAtMs!, DateTime.now().millisecondsSinceEpoch)}';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.inactiveBorder,
          width: AppStroke.thin,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.cloud_off_rounded,
            color: AppColors.secondaryText,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Saved standings$age. Pull to refresh.',
              style: AppTypography.body.copyWith(
                color: AppColors.secondaryText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Marks locally-pending ranked runs distinctly — they are not yet on the board.
class _PendingBanner extends StatelessWidget {
  const _PendingBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final String runs = count == 1 ? 'run' : 'runs';
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neonBlue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(
          color: AppColors.neonBlue.withValues(alpha: 0.4),
          width: AppStroke.thin,
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.hourglass_top_rounded,
            color: AppColors.neonBlue,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '$count $runs awaiting verification — not yet ranked.',
              style: AppTypography.body.copyWith(
                color: AppColors.primaryText,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.data, required this.pending});

  final LeaderboardData data;
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (data.isFromCache) _StaleBanner(cachedAtMs: data.cachedAtMs),
        if (pending > 0) _PendingBanner(count: pending),
        const Icon(
          Icons.leaderboard_outlined,
          color: AppColors.neonBlue,
          size: 48,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'No verified scores yet this week',
          style: AppTypography.title.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Play a ranked run to be the first on the board.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool offline = error is NetworkError;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(
          offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
          color: AppColors.neonBlue,
          size: 48,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          offline ? 'You\'re offline' : 'Couldn\'t load the leaderboard',
          style: AppTypography.title.copyWith(fontSize: 22),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          offline
              ? 'Connect to see this week\'s standings. Your saved standings will '
                    'show here once you\'ve loaded them online.'
              : error is AppError
              ? (error as AppError).message
              : 'Something went wrong.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: onRetry,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neonBlue,
            foregroundColor: AppColors.background,
          ),
          child: const Text('Try again'),
        ),
      ],
    );
  }
}
