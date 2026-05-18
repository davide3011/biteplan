#!/bin/bash
set -e

# Aggiunge supporto web se mancante (crea solo web/, non tocca lib/)
if [[ ! -d /workspace/web ]]; then
  echo "→ Inizializzazione supporto web..."
  flutter create . --platforms=web
fi

# Aggiunge permesso CAMERA se assente (richiesto da mobile_scanner)
MANIFEST=/workspace/android/app/src/main/AndroidManifest.xml
if [[ -f "$MANIFEST" ]] && ! grep -q "CAMERA" "$MANIFEST"; then
  echo "→ Aggiunta permesso CAMERA in AndroidManifest.xml..."
  sed -i 's|<application|<uses-permission android:name="android.permission.CAMERA" />\n    <application|' "$MANIFEST"
fi

flutter pub get
exec flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5173
