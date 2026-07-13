import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/analytics/analytics_event.dart';
import '../data/onboarding_store.dart';

/// The onboarding persistence gateway. Overridden at bootstrap with the real
/// [PrefsOnboardingStore]; the default is a *seen* in-memory store so the overlay
/// never blocks an unconfigured host (tests opt in with `seen: false`).
final onboardingStoreProvider = Provider<OnboardingStore>((ref) {
  return InMemoryOnboardingStore();
});

/// Whether onboarding has been completed. `false` on first launch → the overlay is
/// shown over Home; [OnboardingController.complete] flips it (persist + analytics).
class OnboardingController extends Notifier<bool> {
  @override
  bool build() => ref.read(onboardingStoreProvider).hasSeenOnboarding();

  /// Marks onboarding complete. Idempotent: a repeat call is a no-op.
  Future<void> complete() async {
    if (state) {
      return;
    }
    state = true;
    await ref.read(onboardingStoreProvider).markSeen();
    ref.read(analyticsProvider).logEvent(AnalyticsEvent.onboardingCompleted());
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, bool>(OnboardingController.new);
