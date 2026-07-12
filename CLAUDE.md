# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitePlan è un'app Android per meal planning, conversione crudo/cotto e lista della spesa, scritta in Flutter. Tutta la UI e la UX sono in **italiano**. Il rilascio avviene come APK Android buildato via Docker.

## Ruolo atteso

Quando viene richiesta una modifica o una nuova funzionalità, segui questo flusso:

1. **Analizza prima di implementare**: valuta se la richiesta ha senso — fattibilità, complessità reale, impatto su architettura/UX/persistenza. Se esiste un modo migliore di implementarla, proponilo; se la richiesta è mal posta o ha un costo sproporzionato al beneficio, dillo esplicitamente con l'alternativa. Motiva i giudizi con riferimenti concreti al codice.
2. **Implementa da esperto**: se la richiesta va bene (o dopo l'eventuale discussione), implementala seguendo le convenzioni del progetto (feature-first, Provider, tutto in italiano).
3. **Suggerisci i test, non scriverli**: al termine indica quali test coprirebbero la modifica (casi e file dove andrebbero), ma implementali solo se richiesto esplicitamente.

## Comandi

```bash
# Sviluppo (host, no Docker)
emulator -avd biteplan &          # AVD dedicato, Pixel 6 / Android 14 (google_apis x86_64)
flutter run                       # hot reload con "r", hot restart con "R"

# Analisi statica
flutter analyze                   # lint: package:flutter_lints/flutter.yaml

# Test rapidi (host)
flutter test                                            # tutta la suite
flutter test test/features/meal_planner/qr_test.dart    # singolo file

# Test riproducibili (Docker, immagine biteplan-build — usati come riferimento)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get --enforce-lockfile && flutter test"

# Integration test (richiede emulatore avviato)
flutter test integration_test/app_test.dart

# Build APK (headless, via Docker)
bash docker/build.sh                        # debug  → dist/biteplan-debug.apk
export BITEPLAN_KEYSTORE_PASS=password      # richiesto solo per --release
bash docker/build.sh --release              # release → dist/biteplan-release.apk
```

## Sviluppo locale

- **Flutter host**: installato in `~/flutter` (tag `3.41.9`, stessa versione pinnata nel Dockerfile), nel `PATH` via `~/.bashrc`. Docker non si usa più per il dev; resta per test di riferimento e build APK (isolamento, `--enforce-lockfile`, firma release).
- **Emulatore**: Android SDK in `/home/davide/android-sdk`; accelerazione hardware via `/dev/kvm` (WSL2 con KVM abilitato).
- **AVD `biteplan`**: dedicato a questo progetto (Pixel 6, Android 14, google_apis/x86_64). Non riutilizzare AVD di altri progetti (es. `palladium_wallet`).
- **Permessi**: le build Docker girano come root nel volume montato — se `.dart_tool/` o `build/` risultano di proprietà root, serve `sudo chown -R davide:davide .dart_tool build` prima di usare flutter da host.

## Build e firma

- **Flutter pinnato**: versione `3.41.9` in `docker/Dockerfile` (`ARG FLUTTER_VERSION`); aggiornare anche `.flutter-version` e l'install host
- **Dipendenze**: `pubspec.lock` committato; la build usa `--enforce-lockfile` e fallisce se il lock non è allineato
- **Keystore**: `docker/biteplan.jks` è in `.gitignore`; da ottenere dall'autore o generare con `keytool`. Password via `BITEPLAN_KEYSTORE_PASS` (mai hardcoded); alias: `biteplan`
- **applicationId**: `com.davide.biteplan` — non cambiare, garantisce aggiornamento diretto dalla v1.2.1
- **versionCode**: letto da `pubspec.yaml` (`version: X.Y.Z+BUILD`); BUILD deve essere sempre crescente

## Architettura

Feature-first sotto `lib/features/` (meal_planner, converter, shopping_list, guide), ognuna con `models/`, `providers/`, `presentation/`. Codice trasversale in `lib/shared/` e `lib/core/`.

```
lib/
├── app.dart                          # MaterialApp + NavigationBar; in initState chiama UpdateService.checkUpdate() e mostra showUpdateDialog()
├── core/constants/app_constants.dart # kDayIds, kMealSlots, kStorageKey*, kAppVersion
├── shared/
│   ├── services/storage_service.dart      # wrapper SharedPreferences (load/save)
│   ├── services/update_service.dart       # checkUpdate() → GitHub API; isNewer(), parseTagName() (@visibleForTesting)
│   ├── services/url_launcher_service.dart # MethodChannel 'com.davide.biteplan/launcher' → Intent.ACTION_VIEW
│   └── widgets/update_dialog.dart         # showUpdateDialog() — "Più tardi" / "Scarica"
├── features/
│   ├── meal_planner/                 # MealPlan/DayPlan, qr_codec.dart (buildQrPayload, parseMealPlanFromQr), pagine planner + scan QR
│   ├── converter/                    # ConversionEntry con rawToCooked/cookedToRaw, dati da assets/data/conversions.json
│   ├── shopping_list/                # ShoppingItem con quantity per aggregazione duplicati
│   └── guide/                        # guide_page (3 tab) + info_bottom_sheet
└── assets/data/conversions.json      # 50+ alimenti × metodi cottura
```

**State management**: Provider (`ChangeNotifier`), uno per feature, registrati in `main.dart` con `MultiProvider`.
**Persistenza**: `shared_preferences`, chiavi `meals` e `shopping_list` (JSON serializzato).
**Conversione**: logica in `ConversionEntry` — `rawToCooked = raw * yieldFactor`, `cookedToRaw = cooked / yieldFactor`.
**UI**: Material 3, seed color `Color(0xFF2d6a4f)`, tutto in italiano.
**QR**: payload JSON `{ "v": 1, "meals": { ... } }`, limite 2953 byte (capacità QR con error correction L).
**Update checker**: `UpdateService.checkUpdate()` usa `dart:io` `HttpClient` (nessun package aggiuntivo); disabilitato su web (`kIsWeb`). Il `MethodChannel` `com.davide.biteplan/launcher` è implementato in `android/app/src/main/kotlin/com/davide/biteplan/MainActivity.kt`.

## Testing

130 test unit + widget in `test/` (rispecchia la struttura di `lib/`), più un integration test in `integration_test/app_test.dart`. I test unit/widget non richiedono device.

- Storage isolato con `SharedPreferences.setMockInitialValues({})`
- Widget test: estensione `pumpApp` in `test/helpers/pump_app.dart`
- MethodChannel nei test: `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler` — vedi `test/shared/widgets/update_dialog_test.dart`
