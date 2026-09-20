# Architettura — BitePlan

Documento tecnico per chi sviluppa o mantiene l'app: come sono strutturati i dati e come
scorrono tra UI, provider e persistenza. Per l'elenco file per file vedi [CLAUDE.md](../CLAUDE.md);
per l'uso dell'app vedi [guida-utente.md](guida-utente.md).

## Pattern generale

Ogni feature (`meal_planner`, `converter`, `shopping_list`) segue lo stesso schema:

```
Widget (presentation/) → Provider (ChangeNotifier) → StorageService / asset → SharedPreferences
        ↑____________________________notifyListeners()____________________________|
```

Ogni provider espone metodi che mutano lo stato immutabile in memoria, chiamano
`notifyListeners()` e poi salvano in modo fire-and-forget (senza `await`, l'UI non aspetta
la scrittura su disco). `load()` va chiamato una volta all'avvio (in `main.dart`) prima di
usare il provider.

## Piano pasti (`meal_planner`)

- **Modello**: `MealPlan` è una mappa `dayId → DayPlan`; `DayPlan` ha tre liste di stringhe
  (`colazione`, `pranzo`, `cena`). Entrambi sono immutabili: ogni modifica passa da
  `copyWith`/`withUpdatedDay` e ricostruisce l'oggetto.
- **Provider**: `MealPlannerProvider` tiene `_plan` in memoria, la inizializza vuota con
  `MealPlan.empty(kDayIds)`, la carica da `StorageService` (chiave `meals`, JSON via
  `toJsonString`/`fromJsonString`). Se il JSON salvato è corrotto, torna a un piano vuoto
  invece di lanciare un'eccezione.
- **Condivisione QR** (`qr_codec.dart`): `buildQrPayload` serializza il piano come
  `{ "v": 1, "meals": {...} }` e restituisce `null` se supera 2953 byte (capienza QR con error
  correction L) — la UI mostra un errore in quel caso. `parseMealPlanFromQr` valida
  struttura e versione prima di ricostruire il `MealPlan`, per non far crashare l'app su un
  QR malformato o generato da una versione futura.
- **Generazione lista spesa**: la pagina piano pasti legge `plan.allItems` e chiama
  `ShoppingListProvider.addAll(...)` — l'aggregazione duplicati avviene lì, non nel meal
  planner.

## Convertitore crudo/cotto (`converter`)

- **Dati**: `assets/data/conversions.json` è una mappa `alimento → metodo → { yield }`,
  caricata una sola volta in `ConverterProvider.loadDb()` e appiattita in una lista di
  `ConversionEntry { food, method, yieldFactor }`.
- **Calcolo**: `rawToCooked = raw * yieldFactor`, `cookedToRaw = cooked / yieldFactor`.
  Il provider arrotonda il risultato a un decimale (`(v * 10).roundToDouble() / 10`).
- **Ricerca**: `search(query)` filtra `_db` per sottostringa case-insensitive sul nome
  alimento; non c'è persistenza, lo stato (`selected`, `grams`, `rawToCooked`) vive solo in
  memoria e si azzera con `reset()`.
- I coefficienti e le fonti sono documentati in [conversioni.md](conversioni.md) — per
  aggiungerne di nuovi si modifica solo il JSON, non serve toccare il provider.

## Lista della spesa (`shopping_list`)

- **Modello**: `ShoppingItem { id, name, checked, quantity }`. `id` è generato come
  `timestamp_contatore` (non un vero UUID) per garantire unicità anche ad aggiunte multiple
  nello stesso millisecondo.
- **Provider**: `ShoppingListProvider` persiste su chiave `shopping_list` come lista JSON.
  `pendingItems`/`checkedItems` sono getter derivati, non stato separato.
- **`addAll(names)`**: raggruppa i nomi per confronto case-insensitive, somma le occorrenze
  in `quantity` e salta quelli già presenti nella lista (case-insensitive anche lì) — è il
  meccanismo dietro "zucchine (x2)" e dietro il "senza duplicati" della generazione lista
  dal piano pasti.

## Controllo aggiornamenti

`UpdateService.checkUpdate()` (chiamato da `app.dart` in `initState`) interroga
`GET /repos/davide3011/biteplan/releases/latest` su GitHub con `dart:io HttpClient`
(nessun package HTTP aggiuntivo), timeout 5s su connessione e risposta. Confronta il
`tag_name` (spogliato del prefisso `v`) con `kAppVersion` via confronto semver a tre
componenti (`isNewer`); qualsiasi errore di rete, parsing o timeout fa fallire silenziosamente
il controllo (ritorna `null`, nessun dialog). Disabilitato su web (`kIsWeb`).

`kAppVersion` in `app_constants.dart` **non** è sincronizzato automaticamente con
`pubspec.yaml` — va aggiornato a mano ad ogni release, altrimenti il confronto versione è
sbagliato.

## MethodChannel nativo

Il bottone "Scarica" del dialog di aggiornamento e altri link esterni passano da
`UrlLauncherService`, che invoca il canale nativo `com.davide.biteplan/launcher`
implementato in Kotlin (`android/app/src/main/kotlin/com/davide/biteplan/MainActivity.kt`)
con un `Intent.ACTION_VIEW` — scelta per evitare di aggiungere il package `url_launcher`
per un solo caso d'uso.
