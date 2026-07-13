import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/analytics/analytics_event.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/settings/settings_controller.dart';
import '../application/onboarding_controller.dart';

/// A one-time, first-launch overlay that explains the core interaction. Shown over
/// Home until dismissed; the "seen" flag is persisted so it never returns. Honors
/// reduced motion (in-app setting *or* the OS signal) by skipping the fade, uses
/// only design tokens, and is color-independent (text, not color, carries meaning).
class OnboardingOverlay extends ConsumerStatefulWidget {
  const OnboardingOverlay({super.key});

  @override
  ConsumerState<OnboardingOverlay> createState() => _OnboardingOverlayState();
}

class _OnboardingOverlayState extends ConsumerState<OnboardingOverlay> {
  @override
  void initState() {
    super.initState();
    // Log once, after the first frame, when onboarding is first presented.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      ref.read(analyticsProvider).logEvent(AnalyticsEvent.onboardingStarted());
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion =
        ref.watch(settingsProvider.select((s) => s.reducedMotion)) ||
        MediaQuery.disableAnimationsOf(context);

    final Widget content = _content(context);

    if (reduceMotion) {
      return content;
    }
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppMotion.success,
      builder: (BuildContext context, double opacity, Widget? child) =>
          Opacity(opacity: opacity, child: child),
      child: content,
    );
  }

  Widget _content(BuildContext context) {
    return Stack(
      children: <Widget>[
        // Blocks interaction with Home beneath until dismissed.
        ModalBarrier(
          dismissible: false,
          color: AppColors.background.withValues(alpha: 0.92),
        ),
        Center(
          child: Semantics(
            container: true,
            label: 'How to play HEX CALC',
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                  border: Border.all(
                    color: AppColors.neonBlue.withValues(alpha: 0.4),
                    width: AppStroke.thin,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text('HOW TO PLAY', style: AppTypography.hudLabel),
                    const SizedBox(height: AppSpacing.md),
                    const _Tip(
                      'Swipe across adjacent hex cells to build an equation.',
                    ),
                    const _Tip('Make it read number, operator, … = result.'),
                    const _Tip('Match the target for a bigger bonus.'),
                    const _Tip(
                      'Score as much as you can before 60 seconds runs out.',
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: () => ref
                          .read(onboardingControllerProvider.notifier)
                          .complete(),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.neonBlue,
                        foregroundColor: AppColors.background,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('GOT IT'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Tip extends StatelessWidget {
  const _Tip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text('•  ', style: AppTypography.body),
          Expanded(child: Text(text, style: AppTypography.body)),
        ],
      ),
    );
  }
}
