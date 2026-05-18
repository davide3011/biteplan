# Docker — BitePlan

Due container distinti: uno per lo sviluppo con hot reload, uno per la build APK headless.
Tutti i comandi vanno eseguiti dalla **root del progetto** (`~/biteplan`), non da `docker/`.

---

## Container dev (`docker/dev/`)

Avvia un web server Flutter accessibile dal browser, con hot reload.

```bash
cd docker/dev
docker compose up
```

Apri **http://localhost:5173** nel browser.

### Hot reload

Con il container attivo, in un altro terminale:

```bash
docker compose attach dev
# r → hot reload  |  R → hot restart  |  q → esci
```

Le modifiche ai file `.dart` sull'host sono visibili subito nel container grazie al volume
montato — basta premere `r` per ricaricare.

> Prima esecuzione: scarica l'immagine Flutter (~500 MB), richiede 5-10 minuti.
> Le successive usano la cache Docker e sono molto più rapide.

---

## Container build (`docker/build/`)

Build headless riproducibile per generare l'APK Android.

### Build debug

APK firmato con il debug keystore di Android — adatto per installazione diretta sul dispositivo.

```bash
bash docker/build/build.sh
# → dist/biteplan-debug.apk
```

### Build release

APK firmato con keystore personale — necessario per la distribuzione.

**1. Genera il keystore (una sola volta)**

```bash
keytool -genkey -v \
  -keystore docker/biteplan.jks \
  -alias biteplan \
  -keyalg RSA -keysize 2048 -validity 10000
```

> `docker/biteplan.jks` è in `.gitignore` e non verrà mai committato.
> Conservalo in un posto sicuro: senza di esso non puoi pubblicare aggiornamenti.

**2. Esegui la build release**

```bash
bash docker/build/build.sh --release
# → dist/biteplan-release.apk
```

Il keystore viene montato nel container come volume read-only e non viene mai copiato
nell'immagine Docker.

> Prima esecuzione: scarica Flutter SDK + Android SDK (~1-2 GB), richiede 10-15 minuti.

### Installazione sul dispositivo

```bash
adb install dist/biteplan-debug.apk
# oppure copia manualmente dist/biteplan-release.apk via USB o Drive
```

---

## Test

I test non richiedono il container dev — usano l'immagine `biteplan-build`, creata
automaticamente al primo `bash docker/build/build.sh`.

```bash
# Tutti i test (110 test — unit + widget)
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get && flutter test"

# Un singolo file
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter test test/features/meal_planner/qr_test.dart"

# Una singola feature
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter test test/features/shopping_list/"
```

---

## Prima configurazione (android/ assente)

Se la cartella `android/` non esiste ancora, lo script `build.sh` la genera
automaticamente tramite `flutter create` all'interno del container — non è necessario
avere Flutter installato sull'host.

---

## Flusso completo

```
# 1. Sviluppo
cd docker/dev && docker compose up
→ http://localhost:5173   (hot reload con 'r')

# 2. Test
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get && flutter test"

# 3. Build
bash docker/build/build.sh             # → dist/biteplan-debug.apk
bash docker/build/build.sh --release   # → dist/biteplan-release.apk

# 4. Installazione
adb install dist/biteplan-debug.apk
```

---

## Note

- App ID: `com.biteplan.biteplan`
- Android target: API 34
- Il keystore non viene mai copiato nell'immagine Docker (volume read-only)
- `dist/` è in `.gitignore`
