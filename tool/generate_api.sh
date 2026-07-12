#!/usr/bin/env bash
# Sync + (attempt to) generate the typed API client from the backend OpenAPI.
#
# Status (Phase 7): the typed client under lib/core/api/ is HAND-AUTHORED, guarded
# by test/contract/api_contract_test.dart, not produced by this script yet. Two
# concrete blockers, documented so this can be revisited:
#
#   1. The backend's .NET 10 OpenAPI is 3.1 and types integer fields as the
#      multi-type ["integer","string"] (e.g. AuthTokens.expiresInSeconds,
#      ProblemDetails.status). openapi-generator's dart / dart-dio generators
#      render these as broken empty wrapper classes, silently dropping the value.
#   2. dart-dio (the generator we would want, for Dio) requires built_value +
#      build_runner, which collides with this repo's sqlite3_flutter_libs native
#      build hooks ("dart compile does not support build hooks"), the same issue
#      the Drift codegen hit in Phase 4.
#
# When the toolchain handles OpenAPI 3.1 cleanly (or the spec emits plain integer
# types), switch lib/core/api over to the generated output and delete the
# hand-authored DTOs. The contract test makes that swap safe: it fails on any
# drift between the client and the committed spec.
#
# What this script does today: refresh the committed spec copy the contract test
# reads, and (best-effort) run the generator into a scratch dir for inspection.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SPEC_SRC="$REPO_ROOT/../backend/docs/api/openapi.v1.json"
SPEC_DEST="$REPO_ROOT/test/contract/openapi.v1.json"

if [[ ! -f "$SPEC_SRC" ]]; then
  echo "Backend spec not found at $SPEC_SRC (checkout the backend repo as a sibling)." >&2
  exit 1
fi

echo "Syncing OpenAPI spec -> $SPEC_DEST"
cp "$SPEC_SRC" "$SPEC_DEST"

# Best-effort generation for inspection (not wired into the build; see header).
if command -v npx >/dev/null 2>&1; then
  OUT="$REPO_ROOT/build/openapi-preview"
  echo "Generating a preview client into $OUT (dart generator)"
  npx --yes @openapitools/openapi-generator-cli generate \
    -i "$SPEC_SRC" -g dart -o "$OUT" \
    --additional-properties=pubName=hexcalc_api >/dev/null 2>&1 || \
    echo "openapi-generator preview failed (offline or unsupported schema) — see header."
else
  echo "npx not found; skipping preview generation."
fi

echo "Done. The active client is hand-authored in lib/core/api/ (contract-guarded)."
