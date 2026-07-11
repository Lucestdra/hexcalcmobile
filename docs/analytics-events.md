# HEX • CALC — Analytics Event Catalog

Analytics events are **product questions**, not implementation noise. This catalog
is the single source of truth for what we emit. Every event is constructed through
a named factory on `AnalyticsEvent` (`lib/core/analytics/analytics_event.dart`) —
the set is closed and reviewed here.

## Privacy rules (enforced by construction)

- **No PII**: never an email, token, display name, or device identifier.
- **No raw gameplay**: never the equation path, the cells, or the seed. Only
  coarse counts (combo length, level, score).
- **No cross-provider spam**: routing lives in `MultiplexAnalytics`; feature code
  emits one event and does not care which providers receive it.
- **Consent-gated**: until a real provider is wired and consent is granted, the
  active implementation is `NoopAnalytics` (production) or `DebugAnalytics`
  (development/staging), both side-effect-free off-device.

## Current status (Phase 4)

Only the **no-op** and **debug-console** implementations exist. Real SDKs
(Firebase for acquisition, PostHog for product funnels, Crashlytics/Sentry for
diagnostics — never product analytics) are wired in a later phase behind the same
`AnalyticsService` interface, with no change to the call sites below.

## Catalog

| Event | Parameters | When | Emitted from |
|-------|------------|------|--------------|
| `app_opened` | — | App bootstrap completes | `bootstrap()` |
| `guest_session_created` | — | A guest identity is minted (backend phase) | _reserved_ |
| `run_started` | `mode` (`normal`\|`ranked`\|`daily`) | A run begins | `GameFeedbackDispatcher` (on `runStarted`) |
| `equation_correct` | `combo_count` | A valid equation is committed | dispatcher (`equationCorrect`) |
| `equation_incorrect` | — | A complete-but-wrong equation is committed | dispatcher (`equationIncorrect`) |
| `target_matched` | — | A correct equation equals the board target | dispatcher (`targetMatched`) |
| `fever_started` | — | Fever ignites | dispatcher (`feverStarted`) |
| `fever_completed` | — | Fever ends | dispatcher (`feverEnded`) |
| `level_completed` | `level` | The board advances a level | dispatcher (`levelCompleted`) |
| `run_completed` | `score`, `equations`, `best_combo`, `level` | The 60s run ends | `GameplayScreen` (finish) |
| `settings_opened` | — | The settings screen is opened | `SettingsScreen` |

### Reserved (wired in later phases)

`onboarding_started`, `onboarding_completed`, `guest_session_created`,
`ranked_submission_queued`, `ranked_submission_verified`,
`ranked_submission_rejected`, `leaderboard_viewed`, `account_link_started`,
`account_link_completed`.

These appear in the working agreement's standard list and will be added to
`AnalyticsEvent` as their features land (auth, ranked, leaderboard). They are
listed here so the catalog stays the canonical map even before the code exists.
