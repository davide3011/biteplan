# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitePlan è un'app Android per meal planning, conversione crudo/cotto e lista della spesa, scritta in Flutter. Tutta la UI e la UX sono in **italiano**. L'obiettivo finale è un APK Android buildabile via Docker.

## Comandi

```bash
# Sviluppo (web server con hot reload)
cd docker/dev && docker compose up
# → http://localhost:5173
# Con il container attivo: docker compose attach dev  →  r = hot reload

# Test (dalla root del progetto — richiede immagine biteplan-build)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get --enforce-lockfile && flutter test"

# Test singolo file
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter test test/features/meal_planner/qr_test.dart"

# Build APK (headless, da host)
bash docker/build/build.sh                        # debug  → dist/biteplan-debug.apk
export BITEPLAN_KEYSTORE_PASS=password            # richiesto solo per --release
bash docker/build/build.sh --release              # release → dist/biteplan-release.apk
```

## Build e firma

- **Flutter pinnato**: versione `3.41.9` nei Dockerfile (`ARG FLUTTER_VERSION`); aggiornare anche `.flutter-version`
- **Gradle cache**: named volume Docker `gradle-cache`, isolata dall'host
- **Dipendenze**: `pubspec.lock` committato; la build usa `--enforce-lockfile` e fallisce se il lock non è allineato
- **Keystore**: `docker/biteplan.jks` è in `.gitignore`; da ottenere dall'autore o generare con `keytool`
- **Firma release**: password passata via `BITEPLAN_KEYSTORE_PASS` (mai hardcoded); alias keystore: `biteplan`
- **applicationId**: `com.davide.biteplan` — non cambiare, garantisce aggiornamento diretto dalla v1.2.1
- **versionCode**: letto da `pubspec.yaml` (`version: X.Y.Z+BUILD`); BUILD deve essere sempre crescente

## Architettura

```
lib/
├── main.dart
├── app.dart                          # MaterialApp, NavigationBar, AppBar con bottone info
├── core/
│   ├── constants/app_constants.dart  # kDayIds, kMealSlots, kStorageKey*, kAppVersion
│   └── theme/app_theme.dart
├── shared/
│   ├── services/storage_service.dart # wrapper SharedPreferences (load/save)
│   └── widgets/
├── features/
│   ├── meal_planner/
│   │   ├── models/meal_plan.dart         # MealPlan, DayPlan
│   │   ├── providers/meal_planner_provider.dart
│   │   ├── qr_codec.dart                 # buildQrPayload, parseMealPlanFromQr
│   │   └── presentation/
│   │       ├── pages/meal_planner_page.dart
│   │       ├── pages/qr_scan_page.dart
│   │       └── widgets/meal_card.dart, qr_share_sheet.dart
│   ├── converter/
│   │   ├── models/conversion_entry.dart  # rawToCooked, cookedToRaw (metodi sul model)
│   │   ├── providers/converter_provider.dart
│   │   └── presentation/pages/converter_page.dart
│   ├── shopping_list/
│   │   ├── models/shopping_item.dart     # quantity per aggregazione duplicati
│   │   ├── providers/shopping_list_provider.dart
│   │   └── presentation/
│   │       ├── pages/shopping_list_page.dart
│   │       └── widgets/shopping_item_tile.dart
│   └── guide/
│       └── presentation/
│           ├── pages/guide_page.dart          # 3 tab: Pasti, Converti, Spesa
│           └── widgets/info_bottom_sheet.dart # aperto dal bottone info in AppBar
└── assets/data/conversions.json       # 50+ alimenti × metodi cottura
```

**State management**: Provider (`ChangeNotifier`).  
**Persistenza**: `shared_preferences`, chiavi `meals` e `shopping_list` (JSON serializzato).  
**Conversione**: logica in `ConversionEntry` — `rawToCooked = raw * yieldFactor`, `cookedToRaw = cooked / yieldFactor`.  
**UI**: Material 3, seed color `Color(0xFF2d6a4f)`, tutto in italiano.  
**QR**: payload JSON `{ "v": 1, "meals": { ... } }`, limite 2953 byte (capacità QR con error correction L).

## Testing

130 test (unit + widget). Non richiedono device fisico.

```
test/
├── helpers/pump_app.dart              # estensione pumpApp per widget test
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
    ├── services/update_service_test.dart
    └── widgets/update_dialog_test.dart
```

I test usano `SharedPreferences.setMockInitialValues({})` per isolare lo storage.
