import 'package:shared_preferences/shared_preferences.dart';

/// Persists whether the one-time onboarding overlay has been seen. Non-sensitive
/// preference data only (never tokens/PII) — like [SharedPreferences] settings.
abstract class OnboardingStore {
  bool hasSeenOnboarding();
  Future<void> markSeen();
}

/// The real store, backed by [SharedPreferences] (wired at bootstrap).
class PrefsOnboardingStore implements OnboardingStore {
  PrefsOnboardingStore(this._prefs);

  final SharedPreferences _prefs;
  static const String _kSeen = 'onboarding.seen';

  @override
  bool hasSeenOnboarding() => _prefs.getBool(_kSeen) ?? false;

  @override
  Future<void> markSeen() => _prefs.setBool(_kSeen, true);
}

/// In-memory store. Defaults to *seen* so that unconfigured contexts (tests, any
/// non-bootstrap host) never surface the overlay; pass `seen: false` to exercise it.
class InMemoryOnboardingStore implements OnboardingStore {
  InMemoryOnboardingStore({bool seen = true}) : _seen = seen;

  bool _seen;

  @override
  bool hasSeenOnboarding() => _seen;

  @override
  Future<void> markSeen() async => _seen = true;
}
