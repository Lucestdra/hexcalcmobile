# Release readiness (Phase 12)

What is done, and the explicit steps/gaps that remain before a store release.

## Done in Phase 12

- **One-time onboarding** — a first-launch overlay (`lib/features/onboarding/`) with a
  persisted "seen" flag (`onboarding.seen` in SharedPreferences). Honors reduced motion
  (in-app setting *or* OS signal), uses design tokens, is color-independent, and emits
  `onboarding_started` / `onboarding_completed`. Widget-tested (shows on first launch,
  dismiss persists + hides, returning players never see it).
- **Accessibility sweep** — added `Semantics` to Home (header + merged "Personal best"
  label), Profile (merged header), and the run result (header + "Final score" label), on
  top of the existing settings-driven reduced-motion + color-independent gameplay cues.
  The onboarding CTA uses a ≥48px touch target.
- **Android release signing** — `android/app/build.gradle.kts` loads a real upload
  keystore from `android/key.properties` (git-ignored; template `key.properties.example`)
  and falls back to debug keys locally when it is absent.
- **Asset licensing** — documented in `docs/asset-licenses.md` (fonts OFL; audio + branding CC0).
- **Branded icon/splash source** — `assets/branding/` (neon hex + equals on near-black),
  with `flutter_launcher_icons` / `flutter_native_splash` configured in `pubspec.yaml`.

## Release steps (run at release, not committed here)

- **Stamp branded native icons/splash** — generation writes many binary native files, so
  it is a release step done once with final brand sign-off:
  ```bash
  dart run flutter_launcher_icons
  dart run flutter_native_splash:create
  ```
  Until then the native launcher icon/splash are the stock Flutter defaults; the branded
  source + config are in place.
- **Signed release build** — create an upload keystore, fill `android/key.properties`
  (see `key.properties.example`), then `flutter build appbundle --flavor production`.

## Known gaps (need a device / Xcode / design)

- **iOS per-flavor schemes/xcconfigs** — Android product flavors exist; iOS still has a
  single scheme. Adding dev/staging/production schemes requires Xcode.
- **On-device profile frame times** — the plan's mid-range-Android profile pass
  (`flutter run --profile --flavor staging`, DevTools frame chart) needs physical
  hardware; not run in this environment.
- **Licensed/designed audio** — the bundled tones are CC0 placeholders
  (`tool/gen_placeholder_audio.dart`); a designed set replaces them before release.
- **Automated E2E** — `integration_test/` is a stub; the end-to-end flow is the manual
  device runbook in the README. Automating it needs an emulator/device in CI.
- **Screen-reader gameplay mode** — explicitly out of MVP scope (the Flame board has no
  semantics); the app shell is navigable.
