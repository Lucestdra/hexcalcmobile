import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/design_system.dart';

/// The minimal Phase 3 home: wordmark + a single Play affordance.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Spacer(),
              const Text('HEX • CALC', style: AppTypography.title),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'swipe the math',
                style: AppTypography.body.copyWith(color: AppColors.neonBlue),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () => context.go('/play'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.neonBlue,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xxl,
                    vertical: AppSpacing.md,
                  ),
                ),
                child: const Text('PLAY'),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}
