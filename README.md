# HEX • CALC — Mobile

Flutter + Flame client for HEX • CALC. See `AGENTS.md` and `CLAUDE.md` for the
full working agreement.

## Repository layout (sibling checkout)

The backend and mobile apps are two **separate** git repositories checked out as
siblings. This repo copies the backend's gameplay fixtures verbatim.

```
LeonidasStudio/Hexcalc/
  backend/    <- canonical gameplay fixtures live here
  mobile/     <- this repo; test/contract/fixtures is a verbatim copy
```

## Toolchain

- Flutter is pinned to **3.38.7** via FVM (`.fvmrc`). Run commands as
  `fvm flutter ...`. If you have not run `fvm install`, a matching system Flutter
  3.38.7 works identically (`.fvmrc` only records the pin).
- Dart **3.10.7** (bundled with the pinned Flutter SDK).
- Flame **1.35.1** (pinned in `pubspec.lock`; verified compatible with the SDK).

## Current state (Phase 9)

- **Phase 1–2** — the deterministic gameplay core in pure Dart (`geometry`,
  `expression`, `drbg`, `board`, `board_generator_v1`, `ruleset`, `replay`),
  the byte-for-byte twin of the backend domain, validated against the same
  golden fixtures + manifest guard.
- **Phase 3** — the first playable offline slice: design tokens, the pure-Dart
  `GameController` state machine, the Flame board, and the Home → Gameplay →
  Result shell.
- **Phase 4** — game feel and shell:
  - success/error/fever **choreography** — pooled particles, energy waves,
    result pop, screen shake, HUD score travel — all with **reduced-motion**
    variants (no shake, no particles, instant score);
  - **audio** (flame_audio) with a procedurally-generated CC0 placeholder set
    and a **haptics** service, both settings-gated;
  - three **flavors** (`development`/`staging`/`production`) via typed
    `FlavorConfig` + `main_<flavor>.dart` entrypoints and Android product flavors;
  - **settings/accessibility** screen (music/SFX, haptics, reduced motion, neon
    + particle intensity) persisted in SharedPreferences;
  - **local run history** (Drift): personal best + recent runs on Home;
  - typed **analytics/crash/remote-config/push** seams with no-op + debug
    implementations (`docs/analytics-events.md` is the event catalog);
  - bundled **Space Grotesk / Space Mono** fonts (OFL, `assets/fonts/`) and
    golden tests.
- **Phase 7** — networking + auth integration (`lib/core/{api,networking,auth,errors}`):
  - a **Dio** stack with a correlation-ID header, a single-flight **refresh
    coordinator** (concurrent 401s await one refresh; a rejected refresh →
    recoverable signed-out; an offline refresh keeps tokens), and RFC 9457
    `ProblemDetails` → typed `AppError` mapping;
  - a typed API client (`lib/core/api/`) and DTOs mirroring the backend OpenAPI,
    guarded against drift by `test/contract/api_contract_test.dart`
    (see **Generated API client** below);
  - tokens in **flutter_secure_storage**; a Riverpod `AuthSessionNotifier` that
    runs a **non-blocking guest bootstrap** (offline play never waits, and a guest
    is retried when connectivity returns);
  - **auth screens** — sign in, register, forgot/reset password, and guest→account
    **link** — plus a **profile** screen, all with loading/error/offline states.
- **Phase 9** — offline outbox + ranked flow (`lib/core/sync/`, `lib/features/gameplay/`):
  - a durable **Drift outbox** (`outbox` table) + a **sync engine** that drains it
    with exponential backoff + jitter, pauses while offline and resumes on the
    reconnect edge, treats permanent 4xx as terminal (kept visible, never retried),
    is single-flight, and reconciles server state transactionally on ack;
  - the gameplay controller now records a **payloadVersion-1 event log** (equation
    cell paths + level + pause/resume), mapped to the backend contract and
    cross-checked against the shared `event-log/v1` fixtures by a Dart verifier twin;
  - **ranked**: request a server challenge (with a ruleset/generator **version gate**
    that blocks ranked — never normal — play on a mismatch), play the server seed,
    then queue a submit; a **ranked-result** screen shows the live verification state
    (pending → verified / rejected / failed) and never presents an unverified run as
    a confirmed rank;
  - **normal** runs also enqueue an idempotent history sync. Ranked submit + normal
    result both carry a per-item `Idempotency-Key`.

## Generated API client (deviation)

The plan calls for an openapi-generator (dart-dio) client under `lib/generated/api/`.
Two concrete blockers make that non-viable today, so the client in `lib/core/api/`
is **hand-authored and contract-guarded** instead:

1. The backend's .NET 10 OpenAPI is 3.1 and types integer fields as the multi-type
   `["integer","string"]` (e.g. `AuthTokens.expiresInSeconds`); openapi-generator's
   `dart`/`dart-dio` generators render these as broken empty wrapper classes.
2. `dart-dio` needs `build_runner`, which collides with this repo's
   `sqlite3_flutter_libs` native build hooks (the same issue Drift codegen hit).

`test/contract/api_contract_test.dart` parses the committed
`test/contract/openapi.v1.json` and fails if any endpoint, required field, or key
field type the client uses drifts from the spec — comparable drift protection to a
generated client (short of full round-trip type-safety). `tool/generate_api.sh`
re-syncs the spec and can be switched to emit the client once the toolchain handles
3.1 cleanly. Do not hand-edit under `lib/generated/api/` (kept for that future).

## Local end-to-end smoke (against a running backend)

With the backend running (`dotnet run --project src/HexCalc.Api` in the sibling
`backend/` repo) and its base URL set in `FlavorConfig.development.apiBaseUrl`
(default `http://10.0.2.2:8080` for the Android emulator → host loopback):

1. **Fresh install, offline** — turn on airplane mode, launch dev flavor. Home and
   Play work immediately (guest bootstrap is non-blocking; no session required).
2. **Guest on reconnect** — turn networking back on. A guest session is created in
   the background (Profile shows "Guest").
3. **Register → sign in** — Profile → Create account → register (enumeration-safe
   confirmation) → sign in with the same credentials.
4. **Link (merge)** — as a guest (fresh install), Profile → Link an account → enter
   the account's email/password → the guest merges into it (Profile shows "Signed
   in"); local run history is preserved.
5. **Refresh** — leave the app until the 15-minute access token expires, then open
   Profile; the profile still loads (the interceptor silently refreshed).
6. **Normal outbox** — play a normal run offline (airplane mode). The result screen
   shows immediately; a `normal_result` outbox item is queued. Turn networking back
   on — it syncs in the background (idempotent).
7. **Ranked** — Home → RANKED. It requests a server challenge (blocks with "update
   required" if the client ruleset/generator is stale), you play the server board,
   and the ranked-result screen shows **Verifying…** then **Verified** with the
   server score. Kill the app mid-verification and relaunch — the queued submit
   survives and completes. Force a reject (tamper) or an expiry to see the distinct
   non-ranked outcomes; an unverified run is never shown as a confirmed rank.

## Assets

- **Fonts** (`assets/fonts/`): Space Grotesk (OFL) + Space Mono (OFL), with
  their license files alongside. Bundling them makes text deterministic across
  platforms (so goldens are stable).
- **Audio** (`assets/audio/`): a placeholder CC0 sound set — simple synthesised
  WAV tones — generated by `dart run tool/gen_placeholder_audio.dart`
  (deterministic, reproducible). Replaced by a designed set in a later phase.

## Regenerating Drift code

The Drift schema lives in `lib/features/gameplay/persistence/app_database.dart`
and imports **only** `package:drift` — the native connection is isolated in
`database_connection.dart` (which imports `drift_flutter`). This split matters:
`build_runner` cannot AOT-compile its build script when a dependency ships a
native build hook (`sqlite3`/`objective_c` do). So codegen is run in a small
hook-free package, and the portable generated part file is copied back:

1. In a scratch package that depends only on `drift`/`drift_dev`/`build_runner`,
   copy `app_database.dart`, run `dart run build_runner build`.
2. Copy the produced `app_database.g.dart` back here (it references only
   `package:drift`, so it compiles unchanged).

The generated `*.g.dart` is committed and excluded from analysis. `flutter test`,
`flutter analyze`, and `flutter build` never invoke `build_runner`.

## Goldens

Golden tests (`test/golden/`) render with the bundled fonts, loaded in
`test/flutter_test_config.dart`, which also installs a **tolerant** comparator
(~1.5% pixel budget) so goldens generated on the dev machine (Windows) stay
robust on Linux CI. Regenerate with `flutter test --update-goldens`; images live
under `test/goldens/`.

## Commands

```bash
fvm flutter pub get
fvm dart format --output=none --set-exit-if-changed .   # verify formatting
fvm flutter analyze                                     # static analysis
fvm flutter test                                        # unit + widget + contract tests
./tool/sync_fixtures.sh                                 # re-sync gameplay fixtures
```

(Substitute plain `flutter`/`dart` if not using the FVM CLI; the pinned version
is identical.)

## Deterministic gameplay fixtures

`test/contract/fixtures/` is a verbatim copy of `backend/docs/gameplay/fixtures/`.
The Dart implementation must pass every case, and a guard test recomputes the
SHA-256 manifest to detect drift. Regenerate fixtures in the backend repo
(`dotnet run --project tools/FixtureGen`), then run `./tool/sync_fixtures.sh`
here. Never hand-edit fixtures. See `backend/docs/gameplay/fixtures/README.md`.

> Note: until the Phase 12 cross-repo CI guard lands, the mobile manifest guard
> proves the mobile fixture copy is **internally consistent** (fixtures match the
> local manifest) — it does not by itself prove parity with the backend canonical
> set. Byte-exact LF line endings are pinned via `.gitattributes` so the SHA-256
> guard survives Windows checkouts.
