# Test — BitePlan

Cosa copre la suite di test, cosa no, e come lanciarla. Per l'architettura del codice
testato vedi [architettura.md](architettura.md).

## Come lanciare i test

```bash
flutter test                                            # tutta la suite unit + widget (host)
flutter test test/features/meal_planner/qr_test.dart    # singolo file

# versione riproducibile via Docker (immagine biteplan-build, creata da bash docker/build.sh)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get --enforce-lockfile && flutter test"

# integration test — richiede un emulatore avviato (vedi docs/emulatore.md)
flutter test integration_test/app_test.dart
```

## Struttura

```text
test/
├── coverage_helper_test.dart             # importa tutta lib/ perché lcov copra anche i file non testati
├── helpers/pump_app.dart                 # estensione pumpApp per i widget test
├── features/
│   ├── converter/{models,pages,providers}/
│   ├── meal_planner/{models,pages,providers,widgets}/ + qr_test.dart
│   ├── shopping_list/{models,pages,providers,widgets}/
│   └── guide/{pages,widgets}/
└── shared/{services,widgets}/
```

184 test unit + widget, coverage ~93% su `lib/`, più `integration_test/app_test.dart`
(navigazione tra tab, flussi end-to-end su un emulatore/device reale).

## Cosa è coperto

- **Modelli**: serializzazione/deserializzazione, `copyWith`, edge case (`MealPlan`,
  `DayPlan`, `ConversionEntry`, `ShoppingItem`).
- **Provider**: mutazioni di stato, persistenza (fire-and-forget) tramite
  `StorageService` con `SharedPreferences.setMockInitialValues({})` isolato per test.
- **Conversione crudo/cotto**: `rawToCooked`/`cookedToRaw` in `ConversionEntry`.
- **QR**: `buildQrPayload`/`parseMealPlanFromQr` in `qr_codec.dart` (payload valido,
  troppo grande, malformato).
- **Update checker**: `isNewer()`, `parseTagName()` (`@visibleForTesting`), dialog di
  aggiornamento con `MethodChannel` mockato.
- **Widget/pagine**: rendering, interazioni utente (tap, form) via `pumpApp`, per tutte
  le feature (meal_planner, converter, shopping_list, guide).
- **Integration test**: navigazione fra i tab e flussi che attraversano più feature,
  su un device/emulatore reale (non richiesto per lo sviluppo quotidiano).

## Cosa NON è coperto (per scelta)

- **`main.dart`**: bootstrap dell'app (setup provider, `runApp`), poco valore nel
  testarlo isolatamente — è coperto indirettamente dall'integration test.
- **Percorso camera di `qr_scan_page`**: l'uso reale della fotocamera per scansionare un
  QR richiede hardware/permessi non simulabili in un widget test; la logica di parsing
  (`qr_codec.dart`) è invece testata a parte.
- **`UrlLauncherService`**: wrapper sottile sul `MethodChannel` nativo
  (`com.davide.biteplan/launcher`) che apre un URL nel browser — l'effetto (apertura
  browser) non è verificabile senza un device reale.

## Insidie note

- **Non chiamare `loadDb()`/`load()` dei provider nel body di `testWidgets`**: l'async
  reale eseguito nella zona `FakeAsync` di `flutter_test` può bloccare la suite (timeout
  10 min). Vanno chiamati nel `setUp()` — vedi
  [test/features/converter/pages/converter_page_test.dart](../test/features/converter/pages/converter_page_test.dart).
- **Storage isolato**: ogni test che tocca `StorageService`/i provider deve chiamare
  `SharedPreferences.setMockInitialValues({})` prima di caricare lo stato, altrimenti i
  test si influenzano a vicenda.
- **MethodChannel nei test**: va mockato con
  `TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler`
  — vedi [test/shared/widgets/update_dialog_test.dart](../test/shared/widgets/update_dialog_test.dart).
- **Nuovi file in `lib/`**: aggiungerli all'import di
  [test/coverage_helper_test.dart](../test/coverage_helper_test.dart), altrimenti lcov
  li esclude dal report di coverage anche se non hanno bisogno di test dedicati.
