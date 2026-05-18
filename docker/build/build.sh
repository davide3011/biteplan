#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
RELEASE=false

for arg in "$@"; do
  [[ "$arg" == "--release" ]] && RELEASE=true
done

echo "→ Build immagine biteplan-build..."
docker build -t biteplan-build "${SCRIPT_DIR}"

mkdir -p "${PROJECT_ROOT}/dist"

if [[ "$RELEASE" == "true" ]]; then
  if [[ -z "${BITEPLAN_KEYSTORE_PASS}" ]]; then
    echo "ERRORE: variabile BITEPLAN_KEYSTORE_PASS non impostata"
    echo "Usa: export BITEPLAN_KEYSTORE_PASS=tuapassword"
    exit 1
  fi

  KEYSTORE="${SCRIPT_DIR}/../biteplan.jks"
  if [[ ! -f "$KEYSTORE" ]]; then
    echo "ERRORE: keystore non trovato in docker/biteplan.jks"
    echo "Generalo con:"
    echo "  keytool -genkey -v -keystore docker/biteplan.jks -alias biteplan -keyalg RSA -keysize 2048 -validity 10000"
    exit 1
  fi

  echo "→ Building release APK..."
  docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    -v "gradle-cache:/root/.gradle" \
    biteplan-build \
    bash -c "cd /workspace && flutter pub get --enforce-lockfile && flutter pub run flutter_launcher_icons && flutter build apk --release"

  echo "→ Zipalign..."
  rm -f "${PROJECT_ROOT}/dist/biteplan-aligned.apk"
  docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    biteplan-build \
    bash -c "zipalign -v -p 4 \
      /workspace/build/app/outputs/flutter-apk/app-release.apk \
      /workspace/dist/biteplan-aligned.apk"

  echo "→ Firma APK..."
  docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    -v "$(realpath "${KEYSTORE%/*}"):/keystore:ro" \
    -e BITEPLAN_KEYSTORE_PASS \
    biteplan-build \
    bash -c "apksigner sign \
      --ks /keystore/biteplan.jks \
      --ks-pass \"pass:\${BITEPLAN_KEYSTORE_PASS}\" \
      --out /workspace/dist/biteplan-release.apk \
      /workspace/dist/biteplan-aligned.apk && \
      rm -f /workspace/dist/biteplan-aligned.apk && \
      apksigner verify --verbose /workspace/dist/biteplan-release.apk"

  echo ""
  echo "✓ Release APK: dist/biteplan-release.apk"

else
  echo "→ Building debug APK..."
  docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    -v "gradle-cache:/root/.gradle" \
    biteplan-build \
    bash -c "cd /workspace && flutter pub get --enforce-lockfile && flutter pub run flutter_launcher_icons && flutter build apk --debug"

  cp "${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-debug.apk" \
     "${PROJECT_ROOT}/dist/biteplan-debug.apk"

  echo ""
  echo "✓ Debug APK: dist/biteplan-debug.apk"
fi
