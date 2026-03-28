#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PROJECT_ROOT/dist"

FROM_HEAD=false
RELEASE=false
for arg in "$@"; do
  [[ "$arg" == "--head"    ]] && FROM_HEAD=true
  [[ "$arg" == "--release" ]] && RELEASE=true
done

# ── Keystore (solo in modalità release) ───────────────────────────────────────
KEYSTORE_PATH="${KEYSTORE_PATH:-$SCRIPT_DIR/biteplan.jks}"

if $RELEASE; then
  if [[ ! -f "$KEYSTORE_PATH" ]]; then
    echo "Errore: keystore non trovato in $KEYSTORE_PATH"
    echo "Generalo con:"
    echo "  keytool -genkey -v -keystore docker/biteplan.jks -alias biteplan -keyalg RSA -keysize 2048 -validity 10000"
    exit 1
  fi

  if [[ -z "${KEYSTORE_PASS:-}" ]]; then
    read -rsp "Password keystore: " KEYSTORE_PASS; echo
  fi
  if [[ -z "${KEY_PASS:-}" ]]; then
    read -rsp "Password chiave:   " KEY_PASS; echo
  fi
fi

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

# ── Generazione APK ───────────────────────────────────────────────────────────
echo "==> Generazione APK${RELEASE:+ release}..."

DOCKER_ARGS=(
  --rm
  -v "$DIST_DIR:/app/dist"
)

if $RELEASE; then
  DOCKER_ARGS+=(
    -e BUILD_TYPE=release
    -e KEYSTORE_PASS="$KEYSTORE_PASS"
    -e KEY_PASS="$KEY_PASS"
    -v "$KEYSTORE_PATH:/app/biteplan.jks:ro"
  )
fi

docker run "${DOCKER_ARGS[@]}" biteplan-builder

echo ""
echo "APK pronto in: $DIST_DIR/biteplan.apk"
