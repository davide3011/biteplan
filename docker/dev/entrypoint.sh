#!/bin/bash
set -e

# Aggiunge supporto web se mancante (crea solo web/, non tocca lib/)
if [[ ! -d /workspace/web ]]; then
  echo "→ Inizializzazione supporto web..."
  flutter create . --platforms=web
fi

flutter pub get
exec flutter run -d web-server --web-hostname=0.0.0.0 --web-port=5173
