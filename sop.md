# SOP — BitePlan (Flutter → Android APK)

## Scope

App mobile Android con tre funzionalità:

1. **Meal Planner** — pianificazione settimanale (7 giorni × 3 pasti: colazione, pranzo, cena). Ogni pasto contiene una lista di voci testuali liberamente modificabili.
2. **Conversione crudo/cotto** — calcolo del peso cotto a partire dal peso crudo (e viceversa) tramite coefficienti di resa definiti in un asset JSON interno.
3. **Lista della spesa** — checklist con aggiunta, spunta e rimozione elementi.

---

## Stack tecnologico

| Livello | Scelta |
|---|---|
| Framework | Flutter (Dart) |
| Stato | Provider o Riverpod |
| Persistenza | shared_preferences |
| UI | Material 3, mobile-first |
| Build APK | Docker (container build) |
| Sviluppo | Docker + noVNC (container dev con GUI) |

---

## Struttura progetto

```
lib/
├── main.dart
├── app.dart                    # MaterialApp, routing, BottomNavigationBar
├── pages/
│   ├── meal_planner_page.dart
│   ├── converter_page.dart
│   └── shopping_list_page.dart
├── widgets/
│   ├── meal_card.dart          # Accordion giorno
│   └── checkbox_item.dart
├── models/
│   ├── meal_plan.dart
│   └── shopping_item.dart
├── services/
│   ├── storage_service.dart    # Wrapper shared_preferences
│   └── conversion_service.dart # rawToCooked / cookedToRaw
└── data/
    └── conversions.json        # Asset: 50+ alimenti × metodi cottura

docker/
├── dev/
│   ├── Dockerfile              # Flutter SDK + Android SDK + Xvfb + noVNC
│   └── docker-compose.yml      # Porta 6080 → noVNC, volume su ./
├── build/
│   ├── Dockerfile              # Flutter SDK + Android SDK headless
│   └── build.sh                # flutter build apk --release + firma
pubspec.yaml
```

---

## Container dev (noVNC)

Il container di sviluppo espone un desktop virtuale via browser, utile per eseguire l'emulatore Android o Android Studio senza installare nulla sull'host.

**Stack interno**: Ubuntu + Flutter SDK + Android SDK + Xvfb + noVNC + websockify.

```bash
# Avvio
cd docker/dev
docker compose up

# Accesso GUI
# → http://localhost:6080 (noVNC, nessuna password)
```

Il volume mappa `./` (root del progetto) in `/workspace` nel container, quindi le modifiche ai file sono bidirezionali in tempo reale.

**Workflow nel container**:
1. Aprire un terminale nel desktop noVNC
2. `cd /workspace && flutter pub get`
3. Avviare l'emulatore o collegare device via ADB
4. `flutter run`

---

## Container build (APK)

Build headless riproducibile, senza GUI.

```bash
# Debug
bash docker/build/build.sh

# Release firmato
bash docker/build/build.sh --release
```

Pipeline interna:
1. `flutter pub get`
2. `flutter build apk --release` → `build/app/outputs/flutter-apk/app-release.apk`
3. Firma con `apksigner` (keystore montato come volume o secret)
4. `zipalign`

L'APK firmato viene copiato in `dist/` nella root del progetto.

---

## Modello dati

**Meal Plan**
```dart
class MealPlan {
  final Map<String, DayPlan> days; // 'lunedi' … 'domenica'
}

class DayPlan {
  final List<String> colazione;
  final List<String> pranzo;
  final List<String> cena;
}
```

**Shopping Item**
```dart
class ShoppingItem {
  final String id;
  final String name;
  bool checked;
}
```

---

## Conversione crudo/cotto

**Asset** — `lib/data/conversions.json`
```json
{
  "pollo": { "forno": { "yield": 0.75 }, "padella": { "yield": 0.70 } },
  "riso basmati": { "bollitura": { "yield": 3.00 } }
}
```

`yield = peso_cotto / peso_crudo`

**Service** — `lib/services/conversion_service.dart`
```dart
double rawToCooked(double raw, double yield) => raw * yield;
double cookedToRaw(double cooked, double yield) => cooked / yield;
```

UX: ricerca testuale → selezione alimento + metodo → input grammi → risultato in tempo reale.

---

## Persistenza

`StorageService` wrappa `shared_preferences`:
- Meal plan serializzato come JSON stringa sotto chiave `meals`
- Lista spesa serializzata come JSON stringa sotto chiave `shopping_list`

---

## UI

- `BottomNavigationBar` con 3 tab: Pasti | Converti | Spesa
- Material 3, `ColorScheme.fromSeed(seedColor: Color(0xFF2d6a4f))`
- Target touch minimo 48×48 dp (Material baseline)
- Orientamento bloccato in portrait (`SystemChrome.setPreferredOrientations`)

---

## Fasi future

- Modifica coefficienti di conversione in-app
- Calcolo kcal
- Condivisione piano via QR code
- Sync cloud
