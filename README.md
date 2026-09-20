# BitePlan

App Android per la gestione della dieta quotidiana — pianificazione pasti, conversione crudo/cotto e lista della spesa.

> Un'unica app per pianificare la settimana, sapere quanto pesare crudo o cotto e non dimenticare cosa comprare.

![License](https://img.shields.io/badge/license-EUPL--1.2-blue)
![Flutter](https://img.shields.io/badge/flutter-3.41.9-02569B?logo=flutter)
![Platform](https://img.shields.io/badge/platform-Android-3DDC84?logo=android)

## Overview

BitePlan nasce per unire in un'unica app tre attività che di solito richiedono strumenti
separati: pianificare i pasti della settimana, convertire i pesi degli alimenti tra crudo e
cotto (utile per chi segue una dieta con quantità espresse in una delle due forme), e tenere
una lista della spesa sincronizzata con quanto pianificato.

- **Problema risolto**: evitare di ricalcolare a mano le rese di cottura e di dimenticare
  ingredienti quando si fa la spesa.
- **Perché esiste**: progetto personale dell'autore, pensato per un uso quotidiano reale.
- **Limiti noti**: i coefficienti di resa sono medie indicative (vedi
  [docs/conversioni.md](docs/conversioni.md)); il piano pasti si condivide tra dispositivi
  solo via QR code, senza account né sincronizzazione cloud; nessuna build iOS.

## Features

### Piano pasti
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

## Architecture

Feature-first sotto `lib/features/`, ognuna con modelli, provider (state management) e
presentation; persistenza su `SharedPreferences`. Dettaglio del flusso dati per feature in
[docs/architettura.md](docs/architettura.md).

```text
biteplan/
├── lib/
│   ├── app.dart               # MaterialApp + navigazione
│   ├── core/                  # costanti, tema
│   ├── shared/                # servizi e widget condivisi
│   └── features/
│       ├── meal_planner/
│       ├── converter/
│       ├── shopping_list/
│       └── guide/
├── assets/data/conversions.json
├── android/                   # progetto nativo (MethodChannel in Kotlin)
├── test/                      # unit + widget test
├── integration_test/
├── docs/                      # guida utente, architettura, fonti conversioni
└── docker/                    # build APK headless, test riproducibili
```

## Requisiti e dipendenze

| Livello | Tecnologia |
|---|---|
| Framework | Flutter 3.41.9 / Dart 3.11.5 |
| State management | Provider |
| Persistenza | shared_preferences |
| QR code | qr_flutter + mobile_scanner |
| Build APK | Docker (headless) |

Requisiti host per lo sviluppo:

- **Linux x86_64** (Ubuntu/Debian o simili; funziona anche su **WSL2** se il kernel espone `/dev/kvm`)
- **KVM** per l'accelerazione hardware — senza, l'emulatore è inutilizzabile. Verifica con:
  ```bash
  ls /dev/kvm          # deve esistere
  groups | grep kvm    # l'utente deve essere nel gruppo kvm
  # se manca il gruppo: sudo usermod -aG kvm $USER  (poi rilogin)
  ```
- **Java 17+** (`sudo apt install openjdk-21-jdk`)
- Strumenti di base: `git curl unzip` — e ~15 GB di spazio libero

## Installazione

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

## Utilizzo

```bash
emulator -avd biteplan &
flutter run
# hot reload con "r", hot restart con "R"
```

Per l'uso dell'app una volta installata, vedi la [guida utente](docs/guida-utente.md).

### Installare e testare un APK già buildato

Una volta creato l'AVD `biteplan` (vedi sopra), per installare e provare un APK di debug
già buildato (es. `dist/biteplan-debug.apk` generato da `bash docker/build.sh`) senza
passare da `flutter run`:

```bash
emulator -avd biteplan &
adb wait-for-device
adb shell 'while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 1; done'

adb install -r dist/biteplan-debug.apk   # -r = reinstalla sovrascrivendo se già presente
adb shell monkey -p com.davide.biteplan -c android.intent.category.LAUNCHER 1

# log in tempo reale
adb logcat --pid=$(adb shell pidof -s com.davide.biteplan)

# disinstalla quando hai finito
adb uninstall com.davide.biteplan
```

> Per lo sviluppo iterativo (hot reload) usa `flutter run` — questa procedura serve a
> validare l'APK esatto che verrà distribuito.

## Test

```bash
flutter test                                            # tutta la suite (host)
flutter test test/features/meal_planner/qr_test.dart    # singolo file

# versione riproducibile via Docker (immagine biteplan-build, creata al primo bash docker/build.sh)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get --enforce-lockfile && flutter test"
```

Struttura di `test/` (rispecchia `lib/`):

```text
test/
├── helpers/pump_app.dart                 # estensione pumpApp per widget test
├── features/
│   ├── converter/{models,providers}/
│   ├── meal_planner/{models,providers,widgets}/ + qr_test.dart
│   └── shopping_list/{models,providers,widgets}/
└── shared/{services,widgets}/
```

## Build APK

```bash
bash docker/build.sh                        # debug   → dist/biteplan-debug.apk
export BITEPLAN_KEYSTORE_PASS=password      # richiesto solo per --release
bash docker/build.sh --release              # release → dist/biteplan-release.apk
```

Vedi [docker/README.md](docker/README.md) per i requisiti della firma release (keystore).

## Contribuire

Progetto personale mantenuto da un singolo autore, senza processo di contribuzione formale.
Segnalazioni di bug e proposte sono benvenute via [Issues](https://github.com/davide3011/biteplan/issues);
per modifiche più ampie apri prima una issue di discussione prima di lavorare a una PR.

## Documentazione

- [Guida utente](docs/guida-utente.md)
- [Architettura](docs/architettura.md)
- [Fonti e documentazione conversioni](docs/conversioni.md)
- [Changelog](CHANGELOG.md)

## Stato e licenza

Versione corrente: vedi [pubspec.yaml](pubspec.yaml) e [CHANGELOG.md](CHANGELOG.md).
Distribuito come APK firmato tramite le [release GitHub](https://github.com/davide3011/biteplan/releases);
l'app verifica automaticamente la disponibilità di aggiornamenti all'avvio.

Rilasciato sotto licenza [EUPL v1.2](LICENSE) — Davide Grilli.
