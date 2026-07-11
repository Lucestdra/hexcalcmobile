# CLAUDE.md — HEX • CALC Mobile Working Agreement

## Mission

Build a premium, responsive, deterministic Flutter + Flame experience that makes equation creation feel immediate and satisfying while preserving mathematical readability.

Read `AGENTS.md` before changing architecture, gameplay rules, design tokens, networking, persistence, analytics, or motion.

---

## First Read Order

Inspect:

1. `AGENTS.md`
2. `README.md`
3. `.fvmrc` or FVM configuration
4. `pubspec.yaml`
5. `pubspec.lock`
6. flavor/bootstrap files
7. design-system tokens
8. gameplay rules and golden fixtures
9. generated API client configuration
10. tests for the feature being changed

Pinned repository configuration overrides assumptions.

---

## Product Invariants

- Portrait-first.
- One finger is sufficient.
- A path follows adjacent hex cells only.
- A cell cannot repeat in one equation.
- Backtracking removes the latest selected cell.
- `=` and result are part of the path.
- Standard operator precedence.
- Every valid equation scores.
- Target match gives a larger bonus.
- Board refresh occurs at level completion.
- Normal gameplay works offline.
- Ranked/daily uses server-issued challenge metadata.
- Competitive score is not locally authoritative.
- Numbers remain readable in Fever.
- No ads, purchases, subscriptions, premium currency, or pay-to-win.

Stop and ask for an explicit decision before changing any invariant.

---

## Expected Architecture

```text
lib/
  app/
  core/
  features/
    gameplay/
      domain/
      application/
      presentation/
      flame/
      persistence/
  generated/api/
assets/
test/
integration_test/
```

Flutter is the app shell. Flame is the gameplay surface.

Do not turn the entire application into a Flame game. Do not implement the gameplay grid as a large tree of animated Flutter widgets without profiling.

---

## Working Style

### Before coding

Determine:

- Is this Flutter UI, Flame gameplay, shared domain logic, networking, or persistence?
- What is the player’s primary action?
- What should happen offline?
- What happens with reduced motion?
- Does it affect the deterministic contract?
- Does it affect analytics or consent?
- Is it on the frame hot path?
- What tests prove it?

### During coding

- use design tokens;
- keep frame-level state out of Riverpod rebuilds;
- keep widgets free of direct network/DAO calls;
- preserve typed errors;
- implement all UI states;
- add semantics;
- keep animation interruptible;
- avoid allocations in `update()` and pointer paths.

### After coding

Run format, analyze, relevant tests, and profile gameplay changes.

---

## Command Playbook

Use repository scripts where available. Typical commands:

```bash
fvm flutter --version
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed .
fvm flutter analyze
fvm flutter test
```

Code generation:

```bash
fvm dart run build_runner build --delete-conflicting-outputs
```

Golden tests:

```bash
fvm flutter test test/golden
```

Integration tests:

```bash
fvm flutter test integration_test
```

Profile run:

```bash
fvm flutter run --profile --flavor staging
```

Do not hand-edit generated files. Do not state that a test passed unless executed.

---

## Feature Delivery Template

A feature should include:

```text
domain model/rules
application controller
data source/repository when needed
presentation states
loading/empty/error/offline behavior
analytics contract
tests
```

Avoid adding a repository abstraction to a purely local presentational feature.

---

## Gameplay Implementation Checklist

### Geometry

- axial coordinates;
- six-neighbor function;
- precomputed cell centers;
- deterministic hit testing;
- safe hit slop;
- no pixel-distance adjacency logic;
- tablet scaling tested;
- finger does not fully obscure path.

### Pointer handling

- immediate press feedback;
- pointer move accepts only valid next cell;
- duplicate cell rejected;
- reverse to previous cell pops path;
- cancel/interrupt cleans up;
- pointer release validates complete grammar;
- incomplete path rewinds;
- no accidental multi-touch state corruption.

### Expression

- canonical token model;
- exact integer evaluator;
- standard precedence;
- exact division;
- locale-independent parsing;
- equals exactly once;
- result exactly one cell;
- shared golden fixtures with backend.

### State machine

Explicit states should exist for:

```text
idle
selecting
validating
successFeedback
errorFeedback
levelTransition
feverEntering
feverActive
feverExiting
paused
finished
```

Avoid boolean soup.

---

## Motion Review Checklist

Every animation must answer:

- what state changed?
- can the player act during it?
- how is it interrupted?
- what is the reduced-motion version?
- is it on the hot path?
- does it stay readable?
- does it fit the duration token?

Default product timing:

- press response: 60–90 ms;
- success sequence: 350–550 ms;
- result pop: 1.05–1.10 scale;
- screen shake: rare;
- no long unskippable celebration.

Do not animate expensive layout every frame.

---

## Visual Review Checklist

- background is near-black, not generic pure-black everywhere;
- numbers/operators are white;
- secondary text is gray;
- inactive cells are low-contrast;
- selected/success state uses `#00BDF2`;
- magenta is controlled and Fever-specific;
- target, timer, score, combo have clear hierarchy;
- effects do not obscure unselected cells;
- spacing uses tokens;
- safe areas are respected;
- tablet layout remains centered;
- screen does not resemble a stock template.

Critical states must be reviewed as screenshots/goldens.

---

## Accessibility Review Checklist

- reduced motion;
- haptics off;
- music and SFX separate;
- particle/neon intensity control;
- color-independent cues;
- semantic labels;
- meaningful focus order;
- adequate touch targets;
- no essential meaning through animation only;
- dynamic type for non-gameplay UI;
- no claim of full screen-reader gameplay without testing.

---

## Riverpod Rules

- use `Notifier`/`AsyncNotifier`;
- immutable state;
- no `BuildContext` in providers;
- no direct Dio or Drift calls from widgets;
- avoid giant global providers;
- one-off effects are explicit;
- provider tests cover business state;
- frame-level gameplay data stays in Flame/controller;
- bridge only score, timer, combo, level, pause, and other meaningful snapshots.

---

## API Client Rules

- generated OpenAPI client is source-generated output;
- Dio is configured in one core networking layer;
- access token is injected centrally;
- refresh is single-flight;
- concurrent 401 requests wait for the same refresh;
- failed refresh transitions to a recoverable signed-out state;
- correlation ID is propagated;
- critical writes use idempotency keys;
- typed `ProblemDetails` maps to app errors;
- unsafe writes are not automatically retried;
- request cancellation follows screen/task lifecycle.

---

## Offline Outbox Rules

An outbox item should have:

```text
localId
operationType
payloadVersion
payload
idempotencyKey
createdAt
attemptCount
nextAttemptAt
lastErrorCode
status
```

Behavior:

- persist before considering local operation durable;
- use exponential backoff with jitter;
- pause retries when offline;
- do not retry permanent 4xx failures forever;
- keep rejected ranked runs visible to the player;
- reconcile server state transactionally;
- remove/compact acknowledged items safely;
- test app termination between each state.

---

## Authentication Review Checklist

- guest starts without friction;
- email/password flows are localized;
- password reset exists;
- tokens use secure storage;
- logout can preserve offline non-sensitive data;
- guest merge is explained;
- merge failure does not delete progress;
- existing-account login cannot duplicate or steal identity;
- Google/Apple extension points do not pollute MVP screens;
- auth errors avoid account enumeration.

---

## Analytics Event Standard

Maintain a documented event catalog.

Events should be product questions, not implementation noise.

Examples:

```text
onboarding_started
onboarding_completed
guest_session_created
run_started
equation_submitted
equation_correct
equation_incorrect
target_matched
fever_started
fever_completed
level_completed
run_completed
ranked_submission_queued
ranked_submission_verified
ranked_submission_rejected
leaderboard_viewed
account_link_started
account_link_completed
```

Rules:

- no raw equation path in general analytics;
- no email/token/PII;
- avoid sending the same event to every provider;
- Firebase for acquisition/notification/high-level events;
- PostHog for product funnels and experiments;
- Crashlytics/Sentry for diagnostics, not product analytics;
- consent respected.

---

## Error UX Standard

Every asynchronous screen supports:

```text
initial
loading
content
empty
offlineCached
recoverableError
fatalError
```

Messages:

- explain what happened;
- preserve player work;
- offer a direct retry or next action;
- do not blame the player;
- do not reveal backend internals.

Ranked verification rejection must distinguish:

- expired challenge;
- invalid run;
- unsupported client/ruleset;
- duplicate submission;
- service unavailable.

---

## Test Expectations

### Gameplay changes

Require:

- unit tests;
- golden fixtures;
- pointer-path tests;
- state-machine tests;
- profile review if rendering/motion changed.

### UI changes

Require:

- widget tests for state behavior;
- golden updates reviewed intentionally;
- localization keys;
- semantics;
- dark/neon design review;
- tablet/safe-area check.

### Networking changes

Require:

- DTO mapping tests;
- refresh concurrency test;
- error mapping;
- retry/idempotency behavior;
- offline outbox interaction.

### Bug fixes

Add a failing regression test first when feasible.

---

## Performance Review

For gameplay changes, inspect profile/release behavior:

- UI frame time;
- raster frame time;
- pointer latency;
- allocations per frame;
- particle count;
- blur/saveLayer cost;
- memory across repeated runs;
- audio start latency.

Do not rely on debug-mode smoothness.

Optimization priorities:

1. input latency;
2. grid readability;
3. stable frame pacing;
4. memory stability;
5. visual richness.

---

## Flavor and Configuration Rules

Three flavors:

```text
development
staging
production
```

No environment URL or key should be selected through ad hoc conditionals in feature code.

Configuration must be typed and injected during bootstrap.

Never ship:

- development API URL in production;
- debug logging with sensitive payloads;
- staging Firebase config in production;
- unrestricted production Remote Config defaults;
- production Sentry/PostHog keys in source if avoidable.

---

## Asset Rules

- bundle critical fonts and sounds;
- compress audio appropriately;
- preload hot-path assets;
- document attribution/license;
- avoid oversized Lottie;
- use Rive only when stateful animation justifies it;
- define fallbacks for missing/failed assets;
- do not block gameplay on nonessential asset loading.

---

## Pull Request Standard

Describe:

- player-visible behavior;
- architecture touched;
- offline behavior;
- accessibility behavior;
- motion/performance impact;
- API/generated-client impact;
- analytics changes;
- tests executed;
- screenshots/goldens;
- remaining risk.

---

## Prohibited Shortcuts

- per-frame Riverpod rebuilds;
- default `Random` for canonical boards;
- `double` scoring;
- direct Dio calls in widgets;
- direct Drift calls in Flame components;
- token storage in SharedPreferences;
- hardcoded strings/colors/spacing;
- unbounded particles;
- long blocking animations;
- color-only feedback;
- unverified score shown as confirmed rank;
- hand-edited generated API code;
- ad/payment/monetization SDKs.

---

## Final Response Format for Coding Tasks

```text
Summary
- What changed and player impact

Verification
- Exact commands/tests/profile checks

Visual and Accessibility
- Motion, reduced motion, semantics, screenshots

Data and Contract Impact
- API, local schema, analytics, or none

Risk
- Remaining risk or “none known”
```

Never claim a performance target without profile evidence.
