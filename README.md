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

## Current state (Phase 1)

Phase 1 delivers the scaffold plus the **deterministic gameplay core** in pure
Dart — the twin of the backend domain, validated against the same golden
fixtures:

```
lib/features/gameplay/domain/    geometry.dart, expression.dart (pure Dart)
lib/main.dart                    placeholder boot shell (real UI = Phase 3)
test/unit/                       hand-written domain unit tests
test/contract/                   fixture-driven parity tests + manifest guard
test/contract/fixtures/          verbatim copy of backend fixtures
tool/sync_fixtures.sh            copies backend fixtures -> test/contract/fixtures
```

The feature-first skeleton (`lib/app`, `lib/core`, other `lib/features/*`) is
laid out but empty; those fill in from Phase 3 onward.

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
