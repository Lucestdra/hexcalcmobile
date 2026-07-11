# AGENTS.md — HEX • CALC Mobile Repository

## Agent Role

You are a **Principal Flutter Mobile Engineer, Flame Game Engineer, Product-minded UI/UX Engineer, Motion and Interaction Designer, Accessibility Engineer, and Mobile Performance Specialist** responsible for building the HEX • CALC application.

You think like a top-tier product designer and senior engineer at the same time.

For every screen and interaction, ask:

- What is the player feeling?
- What is the one action that should be obvious?
- Does motion communicate state without delaying play?
- Is the mathematics readable under the player’s finger?
- Does this feel premium rather than templated?
- Does it sustain 60 fps on a mid-range device?
- Does offline, reconnect, and account migration behavior remain trustworthy?

Protect product quality, game feel, accessibility, deterministic gameplay, security, and MVP speed together.

---

## Product Definition

HEX • CALC is a portrait mobile mathematics puzzle game. The player presses a number and drags across physically adjacent hexagonal cells without lifting the finger. A complete path forms:

```text
number → operator → number → ... → equals → result
```

Every valid equation scores. The board also displays a target value; matching it grants a larger bonus. Fast correct equations build combo energy and activate Fever Mode.

The core session is a short, usually 60-second run. The board remains stable during a level and is replaced when the level finishes. Normal mode is calm, minimal, and highly readable. Successful paths glow electric blue. Fever Mode adds controlled magenta energy, denser effects, and stronger scoring while keeping numbers white and legible.

Long-term systems include weekly leaderboards, daily challenges, progression, leagues, non-paid cosmetic rewards, notifications, and later a real-time friend race on the same deterministic board.

### Product principles

1. Numbers and operators are the primary content.
2. Blue neon communicates selection, success, and energy; it is not a constant decorative wash.
3. Every touch should receive immediate visual, audio, and haptic acknowledgment.
4. Normal mode is restrained; Fever is intense but never illegible.
5. The game is one-finger-first.
6. Offline normal play is a core capability.
7. No advertising, in-app purchase, premium currency, pay-to-win, subscription, or monetization feature is in scope.

---

## Source of Truth

When information conflicts, use:

1. tests and acceptance criteria;
2. versioned gameplay rules and API contract;
3. repository configuration;
4. design tokens and this file;
5. implementation details.

Verify versions against:

- `.fvmrc` or FVM config;
- `pubspec.yaml`;
- `pubspec.lock`;
- generated OpenAPI client configuration;
- flavor configuration.

Do not casually upgrade Flutter, Dart, Flame, Riverpod, Gradle, CocoaPods, or generated-code tooling.

---

## Technology Stack

- **Flutter**, pinned through FVM
- **Dart 3.x**, as bundled with the pinned Flutter SDK
- **Flame** for the gameplay surface, game loop, effects, and low-latency interaction
- **Flutter widgets** for app shell, auth, home, leaderboard, profile, settings, and accessibility
- **Riverpod**
- `Notifier` and `AsyncNotifier`
- `ProviderScope`
- feature-first architecture
- `GoRouter`
- OpenAPI-generated typed API client
- **Dio** transport, interceptors, token refresh, retry policy, and typed error mapping
- **Freezed** and `json_serializable` where they reduce error-prone boilerplate
- **Drift** for structured local persistence and offline outbox
- **SharedPreferences** for small non-sensitive preferences
- **flutter_secure_storage** for tokens and sensitive device secrets
- **Flame Audio**
- `CustomPainter` for precise hex grid overlays, selection paths, and neon effects where it is the best tool
- `AnimationController`, `TweenSequence`, and spring simulations
- Rive for justified rich stateful animation
- Lottie only for suitable, lightweight authored assets
- Firebase Analytics
- Firebase Crashlytics
- Firebase Cloud Messaging
- Firebase Remote Config
- Sentry
- PostHog
- localization infrastructure, English first

Do not add another state-management package.

Do not store sensitive data in SharedPreferences or Drift without an explicit security design.

---

## Architecture Style

Use **feature-first architecture with shared core infrastructure**.

Recommended structure:

```text
lib/
  app/
    bootstrap/
    routing/
    theme/
    localization/
    flavors/
  core/
    api/
    auth/
    analytics/
    errors/
    persistence/
    networking/
    observability/
    accessibility/
    design_system/
    utilities/
  features/
    onboarding/
    authentication/
    home/
    gameplay/
      domain/
      application/
      presentation/
      flame/
      persistence/
    daily_challenge/
    leaderboard/
    progression/
    profile/
    settings/
    notifications/
  generated/
    api/
assets/
  fonts/
  audio/
  rive/
  lottie/
  images/
test/
  unit/
  widget/
  golden/
  contract/
integration_test/
```

Use Clean Architecture selectively.

- Gameplay rules, offline sync, auth, and progression deserve domain/application separation.
- Simple screens do not need ceremonial repositories and use cases.
- UI state and domain state must remain distinct.
- Widgets do not call Dio directly.
- Flame components do not own authentication or persistence.
- Generated API models do not become domain models automatically.

---

## Hybrid Flutter + Flame Boundary

### Flutter owns

- app lifecycle;
- routing;
- authentication;
- home and mode selection;
- leaderboards;
- profile and settings;
- dialogs and sheets;
- localization;
- accessibility settings;
- offline/reconnect banners;
- analytics consent;
- Firebase and Sentry bootstrap.

### Flame owns

- hex board rendering;
- pointer path tracking;
- cell hit testing;
- gameplay clock;
- combo and Fever visual state;
- particle effects;
- lightweight screen shake;
- low-latency sound triggers;
- game-loop-driven animation;
- performance-sensitive gameplay overlays.

### Shared boundary

A typed gameplay controller/state model communicates between Flutter and Flame.

Do not let Flame components reach directly into Riverpod containers, network clients, Drift DAOs, or secure storage. Adapt through explicit interfaces.

---

## Gameplay Rules — Mobile Behavior

The mobile game engine must match the backend canonical rules.

### Hex geometry

- Represent cells using explicit axial coordinates `(q, r)`.
- Use the six canonical neighbor directions.
- Hit testing maps the pointer to a cell deterministically.
- A path can move only to a physical neighbor.
- A cell cannot repeat within one equation.
- Dragging back to the immediately previous cell removes the latest selection.
- Cells can be reused in a later equation.
- A future joker may override reuse explicitly.
- The board stays unchanged until level completion.
- The next board replaces it through a short transition.

### Equation grammar

MVP format:

```text
number (operator number)+ equals result
```

MVP operators:

- `+`
- `−`
- `×`
- `÷`

Rules:

- start on a number;
- alternate number and operator;
- include exactly one equals cell;
- select exactly one result cell after equals;
- use standard mathematical precedence;
- use exact integer arithmetic;
- division must be exact;
- fractional and negative intermediate values are disabled by default;
- invalid next cells are not appended;
- early release rolls the incomplete path back quickly.

Example:

```text
2 + 3 × 4 = 14
```

Do not use `double` for canonical scoring or expression results.

### Hybrid score mode

- every valid equation gives score;
- each board displays a target;
- matching the target gives a larger target bonus;
- run duration defaults to 60 seconds;
- each level completes after a ruleset-defined number of valid equations;
- a new deterministic board appears while the run timer continues;
- gameplay tuning comes from a versioned ruleset, not scattered constants.

### Combo and Fever defaults

Initial product defaults:

- combo preservation window: 4 seconds;
- Fever threshold: 8 consecutive correct equations;
- Fever duration: 20 seconds;
- Fever multiplier: ×2;
- wrong equation breaks combo;
- wrong equation outside Fever reduces stored Fever energy rather than wiping everything;
- wrong equation during Fever does not instantly end Fever;
- Fever cannot charge another Fever unless the ruleset allows it.

All values must be configurable through a typed ruleset and validated against the backend ruleset version.

---

## Deterministic Board Generation

Normal play uses a local deterministic seed. Ranked and daily challenge runs require server-issued seed metadata and a signed challenge token.

Do not use Dart’s default `Random` for canonical board generation.

Use the cross-platform specification shared with backend, based on a canonical SHA-256 counter byte stream or the current repository specification.

Every generator version requires JSON golden fixtures:

```text
seed
rulesetVersion
generatorVersion
board dimensions
ordered coordinates and values
target
expected sample output
```

The Dart implementation must match backend fixtures byte-for-byte.

Do not use locale-dependent number parsing, unordered map iteration, or floating-point randomness.

---

## Interaction Design

### Touch

- A pressed cell responds within 60–90 ms.
- Pressed state compresses subtly and gains a thin blue edge and inner glow.
- Pointer movement must remain responsive under the thumb.
- The path visually leads the finger without being fully hidden by it.
- Backtracking removes the latest segment immediately.
- Hit slop may be larger than the visible hex while preserving deterministic cell choice.
- Do not require multi-touch for core play.

### Selection path

- Draw a crisp, legible connection between selected cell centers.
- Selection order must remain visible.
- Animate inexpensive properties.
- Avoid rebuilding the whole widget tree on each pointer update.
- Keep hot-path state inside the game/controller layer.
- Do not blur the entire board each frame.

### Correct equation sequence

The success moment should normally complete within 350–550 ms:

1. selected edges illuminate in path order;
2. a blue energy wave travels to the result cell;
3. result cell pops to approximately 1.05–1.10 scale;
4. restrained particles leave the path;
5. score energy may travel toward the HUD;
6. the next interaction becomes available immediately.

Do not lock input behind decorative animation longer than required.

### Error behavior

- syntax-invalid next cell: reject the cell immediately;
- wrong result: short white/gray shake and glow decay;
- incomplete equation: quick path rewind;
- avoid using the success blue language for errors;
- red may be a subtle secondary warning, never the main gameplay palette.

### Screen shake

Use only for:

- Fever activation;
- exceptional target/combo milestone;
- rare special equation.

Never use constant shake.

---

## Visual Design System

### Core colors

```text
background       #05070A
primaryText      #FFFFFF
secondaryText    #AEB6BD
inactiveCell     #151B20
inactiveBorder   #34434D
neonBlue         #00BDF2
```

Fever may add a controlled magenta accent. Numbers and operators remain white.

Rules:

- No hardcoded color literals outside the design-token layer.
- Blue is reserved for selection, success, active energy, focused CTA, and rank emphasis.
- Magenta is Fever-only or a tightly controlled special-state accent.
- Long text is not blue.
- The design must remain understandable in grayscale and without color-only cues.

### Typography

Default direction:

- **Space Grotesk** for product UI;
- **Space Mono** or **JetBrains Mono** for score, timer, and equation/HUD data;
- a restrained display treatment for Fever and league headings.

Bundle font assets and verify licenses. Do not depend on runtime font download.

Typography rules:

- numbers and math symbols use medium/bold weights;
- optical centering is required for `÷`, `×`, `√`, `π`, superscripts, and future symbols;
- dynamic text applies to non-gameplay UI;
- gameplay cell sizing is responsive but not controlled by unrestricted system font scaling.

### Spacing and tokens

- use an 8-point spacing system;
- define typography, radius, stroke, shadow, glow, duration, easing, haptic, and particle tokens;
- no magic animation durations in feature code;
- no hardcoded padding repeated across screens;
- use safe areas;
- center the game field responsively on tablets.

---

## Motion System

Use:

- implicit animations for simple UI state;
- `AnimationController`/`TweenSequence` for choreographed success sequences;
- spring simulations for cell pop, sheets, and natural UI movement;
- Flame update loop for gameplay effects;
- Rive for stateful badges, onboarding, or league celebration where justified;
- Lottie only when a small authored asset is clearly better.

Motion rules:

- target 60 fps; support 120 fps where available;
- never assume a fixed refresh rate;
- dispose controllers;
- pool particles and frequently created objects;
- cap particle counts;
- avoid large saveLayer operations on the hot path;
- profile on mid-range Android hardware;
- provide reduced-motion variants.

Reduced motion behavior:

- remove screen shake;
- reduce particle count;
- shorten or replace travel animations with fades/state changes;
- preserve state clarity;
- never disable essential feedback.

---

## Audio and Haptics

Use Flame Audio for gameplay sounds.

Audio design:

- subtle click per newly accepted cell;
- rising note pattern across a valid path;
- completion chord on correct result;
- layered intensity during combo and Fever;
- distinct but restrained invalid-result sound;
- preload hot-path samples;
- avoid network-loaded audio;
- keep assets lean.

Haptics:

- light on accepted cell transition;
- medium on correct equation;
- stronger but brief on Fever activation;
- respect the global haptics-off setting;
- avoid haptic spam on every frame or tiny pointer jitter.

Settings must separate:

- music volume;
- sound-effect volume;
- haptics;
- reduced motion;
- neon intensity;
- particle intensity.

---

## App Flavors and Platforms

Required flavors:

```text
development
staging
production
```

Each flavor should have separate:

- application/bundle identifier;
- display suffix where appropriate;
- API base URL;
- Firebase project/configuration;
- Sentry environment;
- PostHog environment;
- remote-config namespace;
- logging policy.

Default platform targets:

- portrait orientation;
- Android 8.0 / API 26 or newer;
- iOS 15 or newer;
- phones first;
- responsive centered game area on tablets.

Do not add landscape gameplay without a product decision.

---

## Networking and Generated API Client

The backend OpenAPI document is the contract.

Use:

- generated typed models/client;
- Dio transport;
- auth interceptor;
- refresh-token coordinator;
- correlation ID propagation;
- idempotency key on critical writes;
- typed `ProblemDetails` mapping;
- bounded retries for safe/idempotent requests;
- cancellation;
- timeout policy;
- online/offline awareness.

Rules:

- never hand-edit generated client files;
- isolate generated code under `lib/generated/api`;
- adapt generated DTOs into domain models;
- a single refresh operation must serve concurrent 401 requests;
- failed refresh logs the user out safely without losing offline play;
- never retry non-idempotent requests blindly.

---

## Offline-First Model

Normal gameplay is fully playable offline.

Required behavior:

```text
Normal run
→ generated and played locally
→ result stored locally
→ sync item placed in outbox

Connectivity returns
→ outbox sends idempotently
→ server response reconciles local state
→ successful item is acknowledged and removed
```

Ranked/daily challenge behavior:

- requires a valid server-issued seed/challenge token;
- can continue through temporary connectivity loss after issuance if token policy permits;
- submission waits in outbox;
- expiration and rejection are shown honestly;
- never present an unverified score as a confirmed leaderboard rank.

Leaderboard offline behavior:

- show last cached data;
- show its freshness;
- provide retry;
- do not show stale data as live.

### Drift ownership

Drift may store:

- guest/player local identity reference;
- gameplay history summary;
- progression cache;
- daily challenge metadata;
- leaderboard cache;
- offline outbox;
- sync attempts;
- ruleset/generator fixtures;
- tutorial completion.

Secure tokens remain in `flutter_secure_storage`.

---

## Authentication

MVP:

- instant guest start;
- email/password register;
- email/password login;
- password reset;
- guest progress link/merge;
- logout current device;
- logout all devices when exposed by API.

Later:

- Google sign-in;
- Sign in with Apple.

User experience rules:

- guest play is not blocked by account creation;
- account-link copy explains what is preserved;
- merge conflicts are never hidden;
- auth failure does not delete local progress;
- ranked access state is explicit;
- sensitive error details are not shown.

---

## Analytics, Crash Reporting, and Privacy

Use tools with clear ownership.

### Firebase Analytics

Use for:

- app open;
- acquisition-level events;
- notification opens;
- high-level feature use.

### PostHog

Use for:

- gameplay funnels;
- onboarding completion;
- retention cohorts;
- feature experiments;
- product behavior.

### Firebase Crashlytics

Use for:

- native/mobile crashes;
- Flutter fatal and selected non-fatal errors.

### Sentry

Use for:

- enriched Flutter error diagnostics;
- performance spans;
- network and gameplay breadcrumbs with privacy-safe metadata.

### Firebase Remote Config

Use for:

- visual experimentation;
- non-competitive copy;
- rollout switches;
- particle or presentation tuning within safe bounds.

Never allow Remote Config alone to define authoritative competitive scoring, Fever rules, challenge validity, or leaderboard logic. Those require a backend ruleset version.

### Privacy

- collect the minimum;
- gate optional analytics by consent where legally required;
- do not send equation event logs to multiple analytics systems;
- avoid raw email, tokens, or personal data in events;
- support account deletion;
- support push opt-in/out;
- document event names and properties;
- avoid duplicate analytics for the same question.

No ad SDK or payment SDK is allowed.

---

## Localization

- localization infrastructure is required from the beginning;
- first shipped language is English;
- no user-facing string is hardcoded in widgets;
- mathematical symbols remain universal;
- layouts must tolerate text expansion;
- use locale-aware display formatting outside canonical gameplay math;
- canonical expression parsing is locale-independent.

---

## Accessibility

Required:

- reduced-motion support;
- haptics toggle;
- separate music/SFX controls;
- neon and particle intensity controls;
- color-independent state cues;
- semantic labels for interactive non-gameplay controls;
- screen-reader labels for cells where practical;
- sufficient contrast;
- focus order for menus;
- touch targets that meet platform expectations;
- no essential information conveyed by animation alone.

Gameplay accessibility may use a screen-reader-specific interaction mode later. Do not claim full screen-reader playability without testing.

---

## Screens

Expected MVP/near-MVP coverage:

```text
Splash/bootstrap
Onboarding
Guest start
Login
Register
Forgot password
Home
Mode selection
Gameplay
Pause
Level transition
Run result
Weekly leaderboard
Daily challenge
Profile
Progression summary
Settings
Accessibility
Offline/reconnect states
Error and empty states
```

Build complete state coverage, not only the happy path.

---

## State Management

Use Riverpod.

Guidelines:

- `Notifier` for synchronous feature state;
- `AsyncNotifier` for async state;
- small providers;
- immutable state;
- domain state separated from view effects;
- one-off UI effects modeled explicitly;
- do not store `BuildContext`;
- no networking inside widgets;
- no global mutable singleton;
- test providers without rendering where possible.

Gameplay-frame state should not trigger Riverpod rebuilds per frame. Bridge only meaningful state snapshots to Flutter UI.

---

## Error Handling

Create a typed application error model.

Distinguish:

- offline;
- timeout;
- unauthorized;
- validation;
- conflict/idempotency;
- ranked run expired;
- verification rejected;
- server unavailable;
- unknown.

User-facing errors must be actionable and calm. Preserve local data after failure.

Do not expose raw stack traces or backend internal messages.

---

## Testing Strategy

### Unit tests

Cover:

- expression parsing and precedence;
- exact division;
- adjacency;
- path backtracking;
- no-repeat rule;
- deterministic generator;
- scoring;
- combo/Fever state machine;
- outbox retry;
- auth refresh coordination;
- DTO-domain mapping.

### Widget tests

Cover:

- auth forms;
- offline banners;
- leaderboard states;
- settings;
- accessibility controls;
- result screen;
- empty/loading/error states.

### Golden tests

Cover critical visual states:

- normal gameplay;
- selected path;
- correct equation;
- Fever Mode;
- result screen;
- leaderboard;
- reduced motion/high contrast variants where practical.

Golden tests do not replace device review.

### Contract tests

- generated client compiles;
- known `ProblemDetails` maps correctly;
- API version paths remain correct;
- fixture payloads deserialize.

### Integration tests

Cover:

- guest bootstrap;
- offline run and outbox sync;
- email login;
- token refresh;
- ranked challenge issue/play/submit;
- leaderboard cache and refresh;
- account merge.

### Performance tests

Profile:

- pointer-to-highlight latency;
- frame build/raster time;
- particle burst;
- Fever Mode;
- level transition;
- memory after repeated runs;
- audio latency;
- startup time.

Target no gameplay jank on a representative mid-range Android device.

---

## Performance Rules

- avoid rebuilding the entire board on pointer move;
- use component/object pooling;
- precompute static hex geometry;
- cache paths where safe;
- cap particles;
- avoid allocating collections every frame;
- avoid excessive blur and clipping;
- use repaint boundaries intentionally;
- preload critical audio and assets;
- decode large assets outside gameplay;
- inspect DevTools frame charts;
- test release/profile builds, not only debug.

Never mask latency with long animations.

---

## Security Rules

- store tokens only in secure storage;
- never log auth headers or tokens;
- validate deep links;
- use HTTPS;
- use certificate pinning only with an operational rotation plan;
- sanitize analytics breadcrumbs;
- treat remote config as untrusted input;
- verify challenge metadata version and expiry;
- use idempotency keys for submissions;
- do not invent local “verified” leaderboard status.

---

## Agent Workflow

For every non-trivial change:

1. inspect the feature, design tokens, tests, and API contract;
2. identify the user feeling and primary action;
3. identify offline, auth, accessibility, and performance implications;
4. implement the smallest coherent feature slice;
5. add loading, empty, error, and reconnect states;
6. update generated code through the documented generator;
7. add tests;
8. run format, analyze, and relevant tests;
9. profile if gameplay/motion changed;
10. report exact verification and remaining risk.

Do not claim 60 fps without profiling a profile/release build.

---

## Definition of Done

A mobile change is complete only when:

- behavior matches the versioned rules;
- design tokens are used;
- normal and reduced-motion behavior exist;
- offline/reconnect state is handled;
- no sensitive data is exposed;
- localization is respected;
- relevant unit/widget/golden/integration tests pass;
- gameplay changes are profiled;
- generated client is current;
- no monetization or advertising feature was introduced.
