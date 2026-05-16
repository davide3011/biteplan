# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitePlan è un'app Android per meal planning, conversione crudo/cotto e lista della spesa. Il progetto è in **riscrittura completa da Vue 3 + Capacitor a Flutter**. Segui `sop.md` come piano di lavoro: ogni sezione del SOP corrisponde a una fase da completare in ordine. L'obiettivo finale è un APK Android buildabile via Docker. Tutta la UI e la UX sono in **italiano**.

## Stato attuale

Il codice Vue 3 esistente (`src/`, `tests/`, `vite.config.mjs`, ecc.) è il riferimento funzionale da portare in Flutter — non va esteso. Il nuovo codice Flutter va creato da zero seguendo `sop.md`.

## Roadmap (da sop.md)

1. Struttura progetto Flutter (`lib/`, `pubspec.yaml`, asset JSON)
2. Container dev: Docker + Xvfb + noVNC su porta 6080 (`docker/dev/`)
3. Container build headless APK (`docker/build/`)
4. `StorageService` — persistenza con `shared_preferences`
5. `ConversionService` — rawToCooked / cookedToRaw + asset `lib/data/conversions.json`
6. Modelli dati: `MealPlan`, `DayPlan`, `ShoppingItem`
7. Pagina Meal Planner (accordion per giorno, 3 pasti, add/remove voci)
8. Pagina Converter (ricerca alimento → selezione metodo → calcolo bidirezionale)
9. Pagina Shopping List (checklist, import da meal planner, svuota)
10. `BottomNavigationBar` (Pasti | Converti | Spesa), portrait lock, Material 3

## Comandi (quando il progetto Flutter esisterà)

```bash
# Sviluppo via container noVNC
cd docker/dev && docker compose up
# → http://localhost:6080  (desktop GUI nel browser)
# Nel terminale noVNC: cd /workspace && flutter pub get && flutter run

# Build APK
bash docker/build/build.sh           # debug
bash docker/build/build.sh --release # release firmato → dist/
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

## Riferimento funzionale (Vue → Flutter)

| Vue (attuale) | Flutter (target) |
|---|---|
| `src/pages/MealPlanner.vue` | `lib/pages/meal_planner_page.dart` |
| `src/pages/Converter.vue` | `lib/pages/converter_page.dart` |
| `src/pages/ShoppingList.vue` | `lib/pages/shopping_list_page.dart` |
| `src/utils/storage.js` | `lib/services/storage_service.dart` |
| `src/utils/conversion.js` | `lib/services/conversion_service.dart` |
| `src/data/conversions.json` | `lib/data/conversions.json` (asset) |
