#!/usr/bin/env bash
# Copies the canonical gameplay golden fixtures from the sibling backend repo
# into this repo verbatim (including manifest.sha256). The two repos are separate
# git repositories; this is the deliberate, drift-guarded sync mechanism.
#
# Usage:  ./tool/sync_fixtures.sh [path-to-backend-fixtures-dir]
#
# Default source: ../backend/docs/gameplay/fixtures  (sibling checkout).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MOBILE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SRC="${1:-$MOBILE_ROOT/../backend/docs/gameplay/fixtures}"
DEST="$MOBILE_ROOT/test/contract/fixtures"

if [[ ! -d "$SRC" ]]; then
  echo "ERROR: backend fixtures not found at: $SRC" >&2
  echo "Pass the fixtures directory explicitly, or check out the backend repo as a sibling." >&2
  exit 1
fi

if [[ ! -f "$SRC/manifest.sha256" ]]; then
  echo "ERROR: $SRC has no manifest.sha256 (did FixtureGen run?)." >&2
  exit 1
fi

echo "Syncing fixtures"
echo "  from: $SRC"
echo "  to:   $DEST"

# Replace every generated contract directory + manifest; keep any local README.
# Contract dirs are every immediate subdirectory of the source fixtures folder.
mkdir -p "$DEST"
for dir in "$SRC"/*/; do
  name="$(basename "$dir")"
  rm -rf "${DEST:?}/$name"
  cp -R "$dir" "$DEST/$name"
done
cp "$SRC/manifest.sha256" "$DEST/manifest.sha256"

# Record the backend commit the fixtures came from. This provenance file is what
# the Phase 12 cross-repo CI guard pins against, so a missing one is worth a loud
# warning (e.g. the backend has no commits yet).
if command -v git >/dev/null 2>&1 && git -C "$SRC" rev-parse HEAD >/dev/null 2>&1; then
  git -C "$SRC" rev-parse HEAD > "$DEST/BACKEND_REF"
  echo "  backend ref: $(cat "$DEST/BACKEND_REF")"
else
  rm -f "$DEST/BACKEND_REF"
  echo "  WARNING: could not record BACKEND_REF (backend has no commits or is not a git repo)." >&2
  echo "           Cross-repo provenance is unavailable until the backend is committed." >&2
fi

count=$(find "$DEST" -name '*.json' | wc -l | tr -d ' ')
echo "Done. $count fixture files present."
