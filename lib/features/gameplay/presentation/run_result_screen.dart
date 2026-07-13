import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design_system/design_system.dart';

/// The data handed to the result screen when a run finishes.
class RunResultData {
  const RunResultData({
    required this.score,
    required this.equationsSolved,
    required this.bestCombo,
    required this.level,
  });

  final int score;
  final int equationsSolved;
  final int bestCombo;
  final int level;
}

/// The end-of-run summary.
class RunResultScreen extends StatelessWidget {
  const RunResultScreen({required this.data, super.key});

  final RunResultData data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Semantics(
                  header: true,
                  child: Text(
                    'RUN COMPLETE',
                    style: AppTypography.hudLabel.copyWith(
                      color: AppColors.neonBlue,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Semantics(
                  label: 'Final score: ${data.score}',
                  child: ExcludeSemantics(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '${data.score}',
                          style: AppTypography.hudNumeric.copyWith(
                            fontSize: 72,
                          ),
                        ),
                        const Text(
                          'FINAL SCORE',
                          style: AppTypography.hudLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _ResultRow(
                  label: 'Equations',
                  value: '${data.equationsSolved}',
                ),
                _ResultRow(label: 'Best combo', value: 'x${data.bestCombo}'),
                _ResultRow(label: 'Level reached', value: '${data.level + 1}'),
                const SizedBox(height: AppSpacing.xxl),
                FilledButton(
                  onPressed: () => context.go('/play'),
                  child: const Text('Play again'),
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

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(width: 160, child: Text(label, style: AppTypography.body)),
          Text(
            value,
            style: AppTypography.body.copyWith(color: AppColors.primaryText),
          ),
        ],
      ),
    );
  }
}
