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

## Stack

| Livello | Tecnologia |
|---|---|
| Framework | Flutter 3.x / Dart 3.x |
| State management | Provider |
| Persistenza | shared_preferences |
| QR code | qr_flutter + mobile_scanner |
| Build APK | Docker (headless) |

## Sviluppo

Il container dev avvia un web server Flutter accessibile dal browser, con hot reload.

```bash
cd docker/dev
docker compose up
# → http://localhost:5173
```

Con il container attivo, in un altro terminale:

```bash
docker compose attach dev
# r → hot reload  |  R → hot restart  |  q → esci
```

Vedi [docker/README.md](docker/README.md) per i dettagli e la build APK.

## Test

La suite copre unit test e widget test. Richiede l'immagine Docker `biteplan-build`
(creata automaticamente al primo `bash docker/build/build.sh`).

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
└── features/
    ├── converter/
    │   ├── models/conversion_entry_test.dart
    │   └── providers/converter_provider_test.dart
    ├── meal_planner/
    │   ├── models/meal_plan_test.dart
    │   ├── providers/meal_planner_provider_test.dart
    │   ├── widgets/meal_card_test.dart
    │   └── qr_test.dart
    └── shopping_list/
        ├── models/shopping_item_test.dart
        ├── providers/shopping_list_provider_test.dart
        └── widgets/shopping_item_tile_test.dart
```

## Build APK

```bash
bash docker/build/build.sh           # debug  → dist/biteplan-debug.apk
bash docker/build/build.sh --release # release → dist/biteplan-release.apk
```

Vedi [docker/README.md](docker/README.md) per i requisiti della firma release.

## Documentazione

- [Guida utente](docs/guida-utente.md)
- [Fonti e documentazione conversioni](docs/conversioni.md)
- [Changelog](CHANGELOG.md)

## Licenza

[EUPL v1.2](LICENSE) — Davide Grilli
