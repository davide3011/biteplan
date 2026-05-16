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

if [[ ! -d "${PROJECT_ROOT}/android" ]]; then
  echo "→ Cartella android/ non trovata, eseguo flutter create..."
  docker run --rm \
    -v "${PROJECT_ROOT}:/workspace" \
    biteplan-build \
    bash -c "cd /workspace && flutter create --project-name biteplan --org com.biteplan --platforms=android ."
fi

mkdir -p "${PROJECT_ROOT}/dist"

if [[ "$RELEASE" == "true" ]]; then
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
    -v "${HOME}/.gradle:/root/.gradle" \
    biteplan-build \
    bash -c "cd /workspace && flutter pub get && flutter build apk --release"

  echo "→ Zipalign..."
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
    biteplan-build \
    bash -c "apksigner sign \
      --ks /keystore/biteplan.jks \
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
    -v "${HOME}/.gradle:/root/.gradle" \
    biteplan-build \
    bash -c "cd /workspace && flutter pub get && flutter build apk --debug"

  cp "${PROJECT_ROOT}/build/app/outputs/flutter-apk/app-debug.apk" \
     "${PROJECT_ROOT}/dist/biteplan-debug.apk"

  echo ""
  echo "✓ Debug APK: dist/biteplan-debug.apk"
fi
