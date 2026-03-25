#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_ROOT/dist"

FROM_HEAD=false
for arg in "$@"; do
  [[ "$arg" == "--head" ]] && FROM_HEAD=true
done

# ── Build Vite ────────────────────────────────────────────────────────────────
if $FROM_HEAD; then
  COMMIT_SHA=$(git -C "$PROJECT_ROOT" rev-parse --short HEAD)
  echo "==> Build Vite da HEAD ($COMMIT_SHA)..."
  TMPDIR=$(mktemp -d)
  trap 'rm -rf "$TMPDIR"' EXIT
  git -C "$PROJECT_ROOT" archive HEAD | tar -x -C "$TMPDIR"
  cd "$TMPDIR"
  npm ci --silent
  npm run build --silent
  DIST_DIR="$TMPDIR/dist"
  cd "$PROJECT_ROOT"
else
  echo "==> Build Vite dalla working directory..."
  cd "$PROJECT_ROOT"
  npm ci --silent
  npm run build --silent
fi

# ── Build immagine Docker ─────────────────────────────────────────────────────
echo "==> Build immagine Docker..."
docker build \
    -f "$SCRIPT_DIR/Dockerfile" \
    -t biteplan-builder \
    "$PROJECT_ROOT"

# ── Generazione APK (dist/ montato come volume) ───────────────────────────────
echo "==> Generazione APK..."
docker run --rm \
    -v "$DIST_DIR:/app/dist" \
    biteplan-builder

echo ""
echo "APK pronto in: $DIST_DIR/biteplan.apk"
