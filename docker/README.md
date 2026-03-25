# Build APK — Docker

Genera un APK Android debug senza installare nulla sull'host oltre a Docker.

## Requisiti host

| Requisito | Dettaglio |
|-----------|-----------|
| **Architettura** | x86_64 (amd64) — ARM/aarch64 non supportato |
| **OS** | Linux x86_64 o macOS x86_64 |
| **Docker** | Installato e avviato |
| **Node.js** | v18+ (per il build Vite locale) |

> Gli Android build-tools (`aapt2`, `zipalign`, ecc.) sono binari nativi x86_64 e non girano su host ARM senza emulazione QEMU.

## Utilizzo

Dalla root del progetto:

```bash
# Build dalla working directory (file attuali)
bash docker/build.sh

# Build da HEAD (ignora modifiche non committate)
bash docker/build.sh --head
```

L'APK viene generato in `output/biteplan.apk`.

## Prima build

La prima esecuzione scarica Android SDK (~1 GB) e può richiedere **10-15 minuti**.
Le build successive usano la cache Docker e sono molto più rapide.

## Installazione su dispositivo

Con ADB:

```bash
adb install output/biteplan.apk
```

## Pipeline

```
[host] npm run build      → dist/   (montato come volume in sola lettura)
[docker] cap sync         → copia dist/ in android/assets/
[docker] gradlew assembleDebug
[host]  output/biteplan.apk
```

## Note

- APK di tipo **debug**, non firmato per la produzione
- App ID: `com.davide.biteplan`
- Android target: API 34
