# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitePlan è un'app Android per meal planning, conversione crudo/cotto e lista della spesa. Il progetto è in **riscrittura completa da Vue 3 + Capacitor a Flutter**. Segui `sop.md` come piano di lavoro: ogni sezione del SOP corrisponde a una fase da completare in ordine. L'obiettivo finale è un APK Android buildabile via Docker. Tutta la UI e la UX sono in **italiano**.

## Stato attuale

Il codice Dart Flutter è stato scritto e si trova in `lib/`. Il codice Vue 3 è stato rimosso.

**Passo successivo obbligatorio**: eseguire `flutter create .` nel container dev (noVNC) per generare lo scaffolding Android (`android/`, `ios/`, `test/`). Senza questo passo il progetto non è buildabile.

## Roadmap (da sop.md)

1. ✅ Struttura progetto Flutter (`lib/`, `pubspec.yaml`, `assets/data/conversions.json`)
2. ✅ `StorageService`, `ConversionService`, modelli dati
3. ✅ Tutte e 3 le pagine + widget + provider
4. ✅ `BottomNavigationBar`, portrait lock, Material 3
5. ✅ Container dev: Docker + Xvfb + noVNC (`docker/dev/`)
6. ✅ Container build headless APK (`docker/build/`)
7. ⬜ Eseguire `flutter create .` nel container + `flutter pub get`
8. ⬜ Configurare icona con `flutter pub run flutter_launcher_icons`

## Comandi

```bash
# Avvia container dev con GUI noVNC
cd docker/dev && docker compose up
# → http://localhost:6080/vnc.html

# Prima volta nel container (dal terminale noVNC):
flutter create --project-name biteplan --org com.biteplan .
flutter pub get && flutter pub run flutter_launcher_icons

# Sviluppo nel container:
flutter run -d linux      # app desktop nella GUI
flutter run -d chrome     # app web

# Test (nel container o con Flutter installato localmente):
flutter test                       # unit + widget
flutter test integration_test/    # e2e (richiede device/emulatore)

# Build APK (headless, da host):
bash docker/build/build.sh           # debug → dist/biteplan-debug.apk
bash docker/build/build.sh --release # release firmato → dist/biteplan-release.apk
```

## Architettura target (Flutter)

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, routing, BottomNavigationBar
├── pages/
│   ├── meal_planner_page.dart
│   ├── converter_page.dart
│   └── shopping_list_page.dart
├── widgets/
│   ├── meal_card.dart
│   └── checkbox_item.dart
├── models/
│   ├── meal_plan.dart
│   └── shopping_item.dart
├── services/
│   ├── storage_service.dart
│   └── conversion_service.dart
└── data/
    └── conversions.json        # 50+ alimenti × metodi cottura, yield = cotto/crudo
```

**Stato**: Provider o Riverpod (nessuno store esterno pesante).  
**Persistenza**: `shared_preferences`, chiavi `meals` e `shopping_list` (JSON serializzato).  
**Conversione**: `rawToCooked(raw, yield) = raw * yield` / `cookedToRaw(cooked, yield) = cooked / yield`.  
**UI**: Material 3, seed color `Color(0xFF2d6a4f)`, touch target minimo 48×48 dp.

## Testing

```
test/
├── unit/
│   ├── models/          # DayPlan, MealPlan, ConversionEntry, ShoppingItem
│   └── providers/       # MealPlannerProvider, ShoppingListProvider
└── widget/              # MealCard, ShoppingItemTile

integration_test/
└── app_test.dart        # navigazione, shopping list, converter, meal planner
```

- **Unit/widget**: `flutter test` — non richiedono dispositivo, usano `SharedPreferences.setMockInitialValues({})` per isolare lo storage
- **Integration**: `flutter test integration_test/` — richiedono emulatore o device fisico
