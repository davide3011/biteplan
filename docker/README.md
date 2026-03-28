# Build APK — Docker

Genera un APK Android senza installare nulla sull'host oltre a Docker.

## Requisiti host

| Requisito | Dettaglio |
|-----------|-----------|
| **Architettura** | x86_64 (amd64) — ARM/aarch64 non supportato |
| **OS** | Linux x86_64 o macOS x86_64 |
| **Docker** | Installato e avviato |
| **Node.js** | v18+ (per il build Vite locale) |

> Gli Android build-tools (`aapt2`, `zipalign`, `apksigner`) sono binari nativi x86_64 e non girano su host ARM senza emulazione QEMU.

---

## Build debug (default)

APK firmato con il debug keystore di Android. Adatto per test su dispositivo.

```bash
bash docker/build.sh
```

---

## Build release (distribuzione)

APK firmato con il tuo keystore personale. Necessario per distribuire l'app.

### 1. Genera il keystore (una volta sola)

```bash
keytool -genkey -v \
  -keystore docker/biteplan.jks \
  -alias biteplan \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000
```

> Il file `docker/biteplan.jks` è già in `.gitignore` — non verrà mai committato.
> Conservalo in un posto sicuro: senza di esso non puoi aggiornare l'app.

### 2. Esegui la build release

```bash
bash docker/build.sh --release
# chiede interattivamente: Password keystore / Password chiave
```

Oppure passando le password come variabili d'ambiente (utile in CI):

```bash
KEYSTORE_PASS=tuapassword KEY_PASS=tuapassword bash docker/build.sh --release
```

Per usare un keystore in un percorso diverso da `docker/biteplan.jks`:

```bash
KEYSTORE_PATH=/percorso/biteplan.jks bash docker/build.sh --release
```

### 3. Verifica la firma

```bash
$ANDROID_HOME/build-tools/34.0.0/apksigner verify --verbose dist/biteplan.apk
```

---

## Flag combinabili

| Comando | Risultato |
|---------|-----------|
| `bash docker/build.sh` | APK debug dalla working directory |
| `bash docker/build.sh --head` | APK debug dall'ultimo commit git |
| `bash docker/build.sh --release` | APK release firmato dalla working directory |
| `bash docker/build.sh --head --release` | APK release firmato dall'ultimo commit git |

---

## Prima build

La prima esecuzione scarica Android SDK (~1 GB) e può richiedere **10-15 minuti**.
Le build successive usano la cache Docker e sono molto più rapide.

## Installazione su dispositivo

```bash
adb install dist/biteplan.apk
```

## Pipeline

```
[host] npm run build          → dist/
[docker] cap sync             → copia dist/ in android/assets/
[docker] gradlew assembleDebug/Release
[docker] zipalign + apksigner → solo in modalità release
[host]   dist/biteplan.apk
```

## Note

- App ID: `com.davide.biteplan`
- Android target: API 34
- Il keystore non viene mai copiato nell'immagine Docker (montato come volume read-only)
