# Docker — BitePlan

Due container distinti: uno per lo sviluppo, uno per la build APK.

---

## Container dev (`docker/dev/`)

Avvia un web server Flutter con hot reload accessibile dal browser.

```bash
cd docker/dev
docker compose up
```

Apri **http://localhost:5173** nel browser.

**Hot reload** — con il container attivo, in un altro terminale:

```bash
docker compose attach dev
# premi 'r' → hot reload  |  'R' → hot restart  |  'q' → esci
```

Le modifiche ai file `.dart` sull'host sono visibili subito nel container
grazie al volume montato — basta premere `r` per ricaricare.

> Prima esecuzione: scarica Flutter SDK (~500 MB), richiede 5-10 minuti.
> Le successive usano la cache Docker e sono molto più rapide.

---

## Container build (`docker/build/`)

Build headless riproducibile per generare l'APK Android.

**Prerequisito**: la cartella `android/` deve esistere nel progetto.
Se non esiste, generala con Flutter installato localmente o nel container dev:

```bash
flutter create --project-name biteplan --org com.biteplan .
```

### Build debug

APK firmato con il debug keystore di Android — adatto per test su dispositivo.

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

> `docker/biteplan.jks` è in `.gitignore` — non verrà mai committato.
> Conservalo in un posto sicuro: senza di esso non puoi pubblicare aggiornamenti.

**2. Esegui la build release**

```bash
bash docker/build/build.sh --release
# → dist/biteplan-release.apk
```

Il keystore viene montato nel container come volume read-only e non viene
mai copiato nell'immagine Docker.

> Prima esecuzione: scarica Flutter SDK + Android SDK (~1-2 GB), richiede 10-15 minuti.

---

## Flusso completo

```
cd docker/dev && docker compose up
    → http://localhost:5173   (sviluppo con hot reload)
    ↓
flutter create --project-name biteplan --org com.biteplan .
    (una volta sola, genera android/)
    ↓
bash docker/build/build.sh           # → dist/biteplan-debug.apk
bash docker/build/build.sh --release # → dist/biteplan-release.apk
    ↓
adb install dist/biteplan-debug.apk
```

---

## Note

- App ID: `com.biteplan.biteplan`
- Android target: API 34
- Il keystore non viene mai copiato nell'immagine Docker (volume read-only)
