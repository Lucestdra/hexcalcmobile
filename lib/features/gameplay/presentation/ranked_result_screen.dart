import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/design_system.dart';
import '../persistence/sync_store.dart';
import 'ranked_status.dart';

/// Route arguments for the ranked-result screen (passed as GoRouter `extra`).
class RankedResultArgs {
  const RankedResultArgs({required this.runId, required this.clientScore});

  final String runId;
  final int clientScore;
}

/// Shows a submitted ranked run's verification status, updating live as the outbox
/// drains: pending → verified / rejected / failed. The client score is only ever
/// shown as unverified until the server confirms it.
class RankedResultScreen extends ConsumerWidget {
  const RankedResultScreen({
    required this.runId,
    required this.clientScore,
    super.key,
  });

  final String runId;
  final int clientScore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<RankedRunView?> runAsync = ref.watch(
      rankedRunViewProvider(runId),
    );
    final RankedRunView? run = runAsync.asData?.value;
    final RankedStatusText status = rankedStatusText(run);
    // Only present a confirmed rank when the server actually returned a verified
    // score — a verified status with a null score never shows the local total as
    // "verified".
    final bool verified =
        run?.status == kRankedVerified && run?.verifiedScore != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'RANKED RUN',
                  style: AppTypography.hudLabel.copyWith(
                    color: AppColors.neonBlue,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (!status.isTerminal)
                  const Padding(
                    padding: EdgeInsets.only(bottom: AppSpacing.lg),
                    child: CircularProgressIndicator(color: AppColors.neonBlue),
                  ),
                Semantics(
                  liveRegion: true,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        status.headline,
                        style: AppTypography.title.copyWith(fontSize: 28),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        status.detail,
                        style: AppTypography.body.copyWith(
                          color: AppColors.secondaryText,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  '${verified ? run!.verifiedScore! : clientScore}',
                  style: AppTypography.hudNumeric.copyWith(fontSize: 64),
                ),
                Text(
                  verified ? 'VERIFIED SCORE' : 'YOUR SCORE (UNVERIFIED)',
                  style: AppTypography.hudLabel,
                ),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: () => context.go('/ranked'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.neonBlue,
                    foregroundColor: AppColors.background,
                  ),
                  child: const Text('Play ranked again'),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
