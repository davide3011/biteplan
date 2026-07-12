# Docker — BitePlan

Un solo container, usato per test riproducibili e build APK headless.
Lo sviluppo (hot reload) avviene sull'host con Flutter + emulatore Android — vedi `CLAUDE.md`.
Tutti i comandi vanno eseguiti dalla **root del progetto** (`~/biteplan`), non da `docker/`.

---

## Container build (`docker/`)

Build headless riproducibile per generare l'APK Android.

### Build debug

APK firmato con il debug keystore di Android — adatto per installazione diretta sul dispositivo.

```bash
bash docker/build.sh
# → dist/biteplan-debug.apk
```

### Build release

APK firmato con keystore — necessario per la distribuzione.

**1. Ottieni il keystore**

Il file `docker/biteplan.jks` non è nel repo (è in `.gitignore`).
Hai due opzioni:

- **Collaboratore**: ricevi `docker/biteplan.jks` dall'autore del progetto via canale sicuro
  (es. password manager condiviso). Usare lo stesso keystore garantisce APK aggiornabili
  sui dispositivi che hanno già l'app installata.

- **Fork/uso personale**: genera il tuo keystore (produce APK non compatibili con quelli
  firmati dall'autore):
  ```bash
  keytool -genkey -v \
    -keystore docker/biteplan.jks \
    -alias biteplan \
    -keyalg RSA -keysize 2048 -validity 10000
  ```

> Conserva `docker/biteplan.jks` in un posto sicuro: perderlo significa non poter più
> pubblicare aggiornamenti firmati con la stessa identità.

**2. Esporta la password del keystore**

```bash
export BITEPLAN_KEYSTORE_PASS=tuapassword
```

La variabile è richiesta ad ogni sessione di terminale. Per non doverla riscrivere ogni volta,
aggiungila a `~/.bashrc` o `~/.zshrc`.

**3. Esegui la build release**

```bash
bash docker/build.sh --release
# → dist/biteplan-release.apk
```

Il keystore viene montato nel container come volume read-only e non viene mai copiato
nell'immagine Docker.

> Se la build fallisce con `Output file '…/biteplan-aligned.apk' exists`, esegui
> `rm dist/biteplan-aligned.apk` e rilancia. Lo script rimuove il file automaticamente
> nelle versioni aggiornate, ma eventuali run interrotte possono lasciarlo indietro.

> Prima esecuzione: scarica Flutter SDK + Android SDK (~1-2 GB), richiede 10-15 minuti.

### Installazione sul dispositivo

```bash
adb install dist/biteplan-debug.apk
# oppure copia manualmente dist/biteplan-release.apk via USB o Drive
```

---

## Test

I test usano l'immagine `biteplan-build`, creata automaticamente al primo `bash docker/build.sh`.

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
# 1. Sviluppo (host, no Docker — vedi CLAUDE.md)
emulator -avd biteplan &
flutter run

# 2. Test
docker run --rm -v "$(pwd):/workspace" -w /workspace biteplan-build \
  bash -c "flutter pub get && flutter test"

# 3. Build
bash docker/build.sh             # → dist/biteplan-debug.apk
bash docker/build.sh --release   # → dist/biteplan-release.apk

# 4. Installazione
adb install dist/biteplan-debug.apk
```

---

## Note

- App ID: `com.biteplan.biteplan`
- Android target: API 34
- Il keystore non viene mai copiato nell'immagine Docker (volume read-only)
- `dist/` è in `.gitignore`
