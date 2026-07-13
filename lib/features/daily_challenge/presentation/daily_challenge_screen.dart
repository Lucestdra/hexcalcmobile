import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../core/api/dtos.dart';
import '../../../core/api/hexcalc_api.dart';
import '../../../core/auth/auth_session.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/errors/app_error.dart';
import '../../gameplay/domain/domain.dart';
import '../../gameplay/presentation/ranked_run_config.dart';
import '../application/daily_challenge_providers.dart';

/// The daily challenge entry: one server-issued, server-verified attempt per UTC
/// day, played through the same signed-challenge pipeline as ranked. Issuing an
/// attempt requires connectivity (offline is messaged honestly); once issued, the
/// play + submit tolerate connectivity loss via the outbox, exactly like ranked.
class DailyChallengeScreen extends ConsumerStatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  ConsumerState<DailyChallengeScreen> createState() =>
      _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends ConsumerState<DailyChallengeScreen> {
  bool _starting = false;

  Future<void> _startAttempt() async {
    if (_starting) {
      return;
    }
    setState(() => _starting = true);
    // Read every provider BEFORE the network await so nothing touches `ref` after
    // an await (the widget may be disposed by then).
    final HexcalcApi api = ref.read(hexcalcApiProvider);
    final String localRuleset = ref.read(rulesetProvider).rulesetVersion;
    const String localGenerator = BoardGeneratorV1.generatorVersion;
    final AnalyticsService analytics = ref.read(analyticsProvider);
    try {
      final DailyAttemptResponse attempt = await api.startDailyAttempt();
      if (!mounted) {
        return;
      }

      // Belt and suspenders: only play a challenge this client can replay. The
      // attempt was already consumed server-side, so refresh the card (it will
      // now read as attempted) rather than leave a stale "start" button.
      if (attempt.rulesetVersion != localRuleset ||
          attempt.generatorVersion != localGenerator) {
        ref.invalidate(dailyChallengeProvider);
        _showMessage('Update the app to play today\'s challenge.');
        return;
      }

      analytics.logEvent(AnalyticsEvent.dailyChallengeStarted());
      context.go(
        '/play-ranked',
        extra: RankedRunConfig(
          runId: attempt.runId,
          seed: attempt.seed,
          rulesetVersion: attempt.rulesetVersion,
          generatorVersion: attempt.generatorVersion,
          challengeToken: attempt.challengeToken,
          runDurationMs: attempt.runDurationMs,
          mode: 'daily',
        ),
      );
    } on ConflictError {
      // Already completed today (possibly on another device): reflect it honestly.
      if (mounted) {
        ref.invalidate(dailyChallengeProvider);
      }
      _showMessage('You\'ve already played today\'s challenge.');
    } on NetworkError {
      _showMessage(
        'You\'re offline. The daily challenge needs a connection to start.',
      );
    } on AppError catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) {
        setState(() => _starting = false);
      }
    }
  }

  void _showMessage(String text) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Set the text colour explicitly: overriding only the (near-black)
          // background would otherwise leave the M3 default dark-on-dark content
          // colour, making the message illegible.
          content: Text(
            text,
            style: AppTypography.body.copyWith(color: AppColors.primaryText),
          ),
          backgroundColor: AppColors.surface,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<DailyChallengeView> async = ref.watch(
      dailyChallengeProvider,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.secondaryText,
        elevation: 0,
        title: const Text('DAILY CHALLENGE', style: AppTypography.hudLabel),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Center(
            child: async.when(
              loading: () =>
                  const CircularProgressIndicator(color: AppColors.neonBlue),
              error: (Object error, _) => _ErrorState(
                error: error,
                onRetry: () => ref.invalidate(dailyChallengeProvider),
              ),
              data: (DailyChallengeView card) => _Card(
                card: card,
                starting: _starting,
                onPlay: _startAttempt,
                localRuleset: ref.read(rulesetProvider).rulesetVersion,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.card,
    required this.starting,
    required this.onPlay,
    required this.localRuleset,
  });

  final DailyChallengeView card;
  final bool starting;
  final VoidCallback onPlay;
  final String localRuleset;

  bool get _supported =>
      card.rulesetVersion == localRuleset &&
      card.generatorVersion == BoardGeneratorV1.generatorVersion;

  @override
  Widget build(BuildContext context) {
    if (!_supported) {
      return _Message(
        icon: Icons.system_update_rounded,
        title: 'Update required',
        detail:
            'Today\'s challenge uses a newer version. Update the app to play it '
            '— normal play still works.',
        action: _Action('Back to home', () => context.go('/')),
      );
    }

    if (card.attempted) {
      return _Message(
        icon: Icons.check_circle_outline_rounded,
        title: 'Played today',
        detail:
            'You\'ve made your one scored attempt for '
            '${_formatDate(card.challengeDateUtc)}. Come back tomorrow for a new '
            'challenge.',
        action: _Action('View leaderboard', () => context.go('/leaderboard')),
        secondary: _Action('Back to home', () => context.go('/')),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.today_rounded, color: AppColors.neonBlue, size: 48),
        const SizedBox(height: AppSpacing.lg),
        Text(
          'Today\'s challenge',
          style: AppTypography.title.copyWith(fontSize: 26),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(_formatDate(card.challengeDateUtc), style: AppTypography.hudLabel),
        const SizedBox(height: AppSpacing.md),
        Text(
          'One scored attempt today. Plays like ranked — your score is verified '
          'by the server after you play.',
          style: AppTypography.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(
          onPressed: starting ? null : onPlay,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.neonBlue,
            foregroundColor: AppColors.background,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
          ),
          child: starting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.background,
                  ),
                )
              : const Text('START DAILY RUN'),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('Back to home'),
        ),
      ],
    );
  }
}

/// Formats a date-only UTC value as `YYYY-MM-DD` (locale-independent).
String _formatDate(DateTime dateUtc) {
  final DateTime d = dateUtc.toUtc();
  final String mm = d.month.toString().padLeft(2, '0');
  final String dd = d.day.toString().padLeft(2, '0');
  return '${d.year}-$mm-$dd';
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.error, required this.onRetry});

  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final bool offline = error is NetworkError;
    return _Message(
      icon: offline ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
      title: offline ? 'You\'re offline' : 'Couldn\'t load the challenge',
      detail: offline
          ? 'The daily challenge needs a connection. Normal play works offline.'
          : error is AppError
          ? (error as AppError).message
          : 'Something went wrong.',
      action: _Action('Try again', onRetry),
      secondary: _Action('Back to home', () => context.go('/')),
    );
  }
}

class _Action {
  const _Action(this.label, this.onPressed);
  final String label;
  final VoidCallback onPressed;
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.detail,
    this.action,
    this.secondary,
  });

  final IconData icon;
  final String title;
  final String detail;
  final _Action? action;
  final _Action? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, color: AppColors.neonBlue, size: 48),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          style: AppTypography.title.copyWith(fontSize: 24),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          detail,
          style: AppTypography.body.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: action!.onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.neonBlue,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(action!.label),
          ),
        ],
        if (secondary != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          TextButton(
            onPressed: secondary!.onPressed,
            child: Text(secondary!.label),
          ),
        ],
      ],
    );
  }
}
