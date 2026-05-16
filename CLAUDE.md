# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

BitePlan is a mobile-first Vue 3 PWA for meal planning, raw↔cooked weight conversion, and shopping list management. It targets Android via Capacitor and is designed for a 480px-max viewport. All UI strings and documentation are in **Italian**.

## Commands

```bash
npm run dev          # Dev server at http://localhost:5173
npm run build        # Production build → dist/
npm run preview      # Preview built app

npm test             # Vitest unit + integration tests (watch mode)
npm run test:coverage  # Coverage report (v8 provider)
npm run test:e2e     # Playwright e2e (requires dev server running)
npm run test:e2e:ui  # Playwright interactive UI mode

# Single test file
npx vitest run tests/unit/conversion.test.js

# Android APK
bash docker/build.sh           # Debug APK
bash docker/build.sh --release # Signed release APK
```

E2E tests simulate iPhone 14 Pro viewport (393×852) with Italian locale.

## Architecture

**App.vue** is the root router — it conditionally renders three pages based on a `currentPage` ref (`meal`, `convert`, `shop`) and hosts the portrait-lock transform, `InfoPanel`, and `DocsPanel`.

**Three pages** in `src/pages/`:
- `MealPlanner.vue` — 7-day plan (Mon–Sun), 3 meal slots each (colazione/pranzo/cena), per-day accordion via `MealCard.vue`, QR share, and "generate shopping list" export
- `Converter.vue` — real-time food search → select food+method → bidirectional raw↔cooked calculation using yield coefficients from `src/data/conversions.json`
- `ShoppingList.vue` — checklist with add/remove/check, importable from meal planner

**State & persistence**: No Pinia/Vuex — pages use Vue composables + direct `localStorage` via the wrappers in `src/utils/storage.js` (`save(key, val)` / `load(key, default)`).

**Conversion logic** lives entirely in `src/utils/conversion.js`:
```js
rawToCooked(food, method, rawGrams, db) = rawGrams * db[food][method].yield
cookedToRaw(food, method, cookedGrams, db) = cookedGrams / db[food][method].yield
```
`yield = cooked_weight / raw_weight`. The database in `src/data/conversions.json` has 50+ foods × 1–4 cooking methods with coefficients sourced from CREA, SINU, USDA (see `docs/conversioni.md`).

**CSS**: Vanilla CSS only, no framework. Design tokens are CSS variables in `:root` in `src/style.css` (`--color-primary: #2d6a4f`, `--nav-height: 64px`, etc.). Buttons must be min 44px; layout is single-column.

## Testing

- **Unit** (`tests/unit/`): Pure function tests for `conversion.js` and `storage.js`
- **Integration** (`tests/integration/`): Vue Test Utils component mounts with localStorage seeding
- **E2E** (`tests/e2e/`): Playwright against the running dev server

`tests/setup.js` clears localStorage before/after each test. Vitest uses `happy-dom` environment.

## Android Build

The Docker pipeline in `docker/` handles the full Android build:
1. `npm run build` → `dist/`
2. `cap sync` → copies dist into Android project
3. Gradle builds the APK; release APK is signed with `docker/biteplan.jks` (gitignored)

See `docker/README.md` for full APK build instructions.
