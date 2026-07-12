# BitePlan

App Android per la gestione della dieta quotidiana — pianificazione pasti, conversione crudo/cotto e lista della spesa.

## Funzionalità

### Piano Pasti
- Pianificazione settimanale su 7 giorni × 3 pasti (colazione, pranzo, cena)
- Card accordion per giorno, giorno corrente aperto di default
- Aggiunta e rimozione di voci per ogni pasto
- Generazione automatica della lista della spesa con aggregazione duplicati (es. "zucchine (x2)")
- Condivisione del piano via QR code tra dispositivi
- Persistenza automatica su SharedPreferences

### Convertitore crudo/cotto
- Conversione bidirezionale del peso (crudo → cotto e cotto → crudo)
- Ricerca alimento in tempo reale
- Oltre 50 voci tra cereali, legumi, verdure, carni, pesce e uova
- Fino a 4 metodi di cottura per alimento: bollitura, padella, forno, friggitrice ad aria
- Coefficienti di resa documentati con fonti — vedi [docs/conversioni.md](docs/conversioni.md)

### Lista della spesa
- Checklist con aggiunta manuale o importazione dai pasti pianificati
- Separazione visiva tra elementi da completare e completati
- Rimozione singola e svuota lista con conferma

### Controllo aggiornamenti
- All'avvio controlla silenziosamente l'ultima release su GitHub
- Se disponibile una versione più recente, mostra un dialog con link diretto al download dell'APK

## Stack

| Livello | Tecnologia |
|---|---|
| Framework | Flutter 3.41.9 / Dart 3.11.5 |
| State management | Provider |
| Persistenza | shared_preferences |
| QR code | qr_flutter + mobile_scanner |
| Build APK | Docker (headless) |

## Sviluppo

Sviluppo locale con Flutter installato sull'host e un emulatore Android dedicato — no Docker.

```bash
emulator -avd biteplan &
flutter run
# hot reload con "r", hot restart con "R"
```

Vedi [docker/README.md](docker/README.md) per test e build APK via Docker.

### Requisiti host

- **Linux x86_64** (Ubuntu/Debian o simili; funziona anche su **WSL2** se il kernel espone `/dev/kvm`)
- **KVM** per l'accelerazione hardware — senza, l'emulatore è inutilizzabile. Verifica con:
  ```bash
  ls /dev/kvm          # deve esistere
  groups | grep kvm    # l'utente deve essere nel gruppo kvm
  # se manca il gruppo: sudo usermod -aG kvm $USER  (poi rilogin)
  ```
- **Java 17+** (`sudo apt install openjdk-21-jdk`)
- Strumenti di base: `git curl unzip` — e ~15 GB di spazio libero

### Installazione passo passo

**1. Flutter** (versione pinnata `3.41.9`, la stessa di `.flutter-version`):

```bash
git clone --depth 1 --branch 3.41.9 https://github.com/flutter/flutter.git ~/flutter
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
flutter --version   # al primo avvio scarica il Dart SDK
```

**2. Android SDK command-line tools:**

```bash
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip && mv cmdline-tools latest
rm commandlinetools-linux-11076708_latest.zip

cat >> ~/.bashrc <<'EOF'
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
EOF
source ~/.bashrc
```

**3. Pacchetti SDK e licenze:**

```bash
sdkmanager "platform-tools" "emulator" \
  "platforms;android-34" "build-tools;34.0.0" \
  "system-images;android-34;google_apis;x86_64"
yes | sdkmanager --licenses
```

**4. AVD dedicato al progetto** (Pixel 6, Android 14):

```bash
echo "no" | avdmanager create avd -n biteplan \
  -k "system-images;android-34;google_apis;x86_64" -d pixel_6
```

**5. Verifica e primo avvio:**

```bash
flutter doctor        # "Android toolchain" deve risultare ✓
emulator -avd biteplan &
# attendi il boot (1-2 min al primo avvio), poi dalla root del progetto:
flutter run
```

> **Nota WSL2**: serve un kernel con KVM abilitato (WSL2 recenti lo hanno di serie —
> verifica con `ls /dev/kvm`). La finestra dell'emulatore compare tramite WSLg.

## Test

La suite copre unit test e widget test. Richiede l'immagine Docker `biteplan-build`
(creata automaticamente al primo `bash docker/build.sh`).

```bash
# Tutti i test (dalla root del progetto)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get && flutter test"

# Un singolo file
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter test test/features/meal_planner/qr_test.dart"
```

### Struttura

```
test/
├── helpers/
│   └── pump_app.dart                     # estensione pumpApp per widget test
├── features/
│   ├── converter/
│   │   ├── models/conversion_entry_test.dart
│   │   └── providers/converter_provider_test.dart
│   ├── meal_planner/
│   │   ├── models/meal_plan_test.dart
│   │   ├── providers/meal_planner_provider_test.dart
│   │   ├── widgets/meal_card_test.dart
│   │   └── qr_test.dart
│   └── shopping_list/
│       ├── models/shopping_item_test.dart
│       ├── providers/shopping_list_provider_test.dart
│       └── widgets/shopping_item_tile_test.dart
└── shared/
    ├── services/
    │   └── update_service_test.dart      # parsing versione e confronto semver
    └── widgets/
        └── update_dialog_test.dart       # widget test dialog aggiornamento
```

## Build APK

```bash
bash docker/build.sh           # debug  → dist/biteplan-debug.apk
bash docker/build.sh --release # release → dist/biteplan-release.apk
```

Vedi [docker/README.md](docker/README.md) per i requisiti della firma release.

## Documentazione

- [Guida utente](docs/guida-utente.md)
- [Fonti e documentazione conversioni](docs/conversioni.md)
- [Changelog](CHANGELOG.md)

## Licenza

[EUPL v1.2](LICENSE) — Davide Grilli
