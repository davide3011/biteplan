# Emulatore Android — installazione e uso (Ubuntu)

Guida per chi sviluppa BitePlan su Ubuntu (nativo o WSL2) e deve installare ed usare
l'emulatore Android in locale. Per i requisiti generali del progetto vedi [README](../README.md);
per la build via Docker vedi [CLAUDE.md](../CLAUDE.md).

## 1. Prerequisiti

- **KVM** per l'accelerazione hardware: senza, l'emulatore è troppo lento per essere usabile.

  ```bash
  ls /dev/kvm          # deve esistere
  groups | grep kvm    # il tuo utente deve essere nel gruppo kvm
  ```

  Se il gruppo manca:

  ```bash
  sudo usermod -aG kvm $USER
  # poi rilogin (o riavvia la sessione) perché il gruppo sia effettivo
  ```

  Su **WSL2** serve un kernel con KVM abilitato (le versioni recenti lo hanno di serie).
  La finestra dell'emulatore compare tramite WSLg.

- **Java 17+**: `sudo apt install openjdk-21-jdk`
- Strumenti di base: `git curl unzip`, e ~15 GB di spazio libero per SDK + system image.

## 2. Installare Android SDK command-line tools

```bash
mkdir -p ~/android-sdk/cmdline-tools
cd ~/android-sdk/cmdline-tools
curl -O https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-11076708_latest.zip && mv cmdline-tools latest
rm commandlinetools-linux-11076708_latest.zip

cat >> ~/.bashrc <<'EOF'
export ANDROID_HOME="$HOME/android-sdk"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
EOF
source ~/.bashrc
```

## 3. Installare i pacchetti SDK e accettare le licenze

```bash
sdkmanager "platform-tools" "emulator" \
  "platforms;android-34" "build-tools;34.0.0" \
  "system-images;android-34;google_apis;x86_64"
yes | sdkmanager --licenses
```

## 4. Creare l'AVD `biteplan`

Il progetto usa un AVD dedicato (Pixel 6, Android 14, `google_apis`/x86_64) — non riusare
AVD di altri progetti.

```bash
echo "no" | avdmanager create avd -n biteplan \
  -k "system-images;android-34;google_apis;x86_64" -d pixel_6
```

Verifica che tutto sia a posto con `flutter doctor` (la voce "Android toolchain" deve
risultare ✓).

## 5. Avviare l'emulatore

```bash
emulator -avd biteplan &
```

Il primo boot richiede 1-2 minuti; quelli successivi sono più veloci grazie allo snapshot
automatico dello stato. Per lo sviluppo con hot reload, dalla root del progetto:

```bash
flutter run     # r = hot reload, R = hot restart
```

### Opzioni utili

```bash
emulator -list-avds              # elenca gli AVD disponibili
emulator -avd biteplan -no-snapshot-load   # forza un cold boot (ignora lo stato salvato)
emulator -avd biteplan -wipe-data          # resetta l'AVD allo stato di fabbrica
```

## 6. Comandi `adb` quotidiani

```bash
adb devices                      # emulatori/device collegati
adb wait-for-device               # attende che l'emulatore sia raggiungibile
adb shell 'while [ "$(getprop sys.boot_completed)" != "1" ]; do sleep 1; done'  # attende il boot completo

adb install -r dist/biteplan-debug.apk   # installa/reinstalla un APK già buildato
adb shell monkey -p com.davide.biteplan -c android.intent.category.LAUNCHER 1  # avvia l'app

adb logcat --pid=$(adb shell pidof -s com.davide.biteplan)   # log in tempo reale dell'app

adb uninstall com.davide.biteplan   # disinstalla
```

> Per lo sviluppo iterativo usa `flutter run` (hot reload); la sequenza `adb install` sopra
> serve a validare l'APK esatto che verrà distribuito, senza passare da `flutter run`.

## 7. Chiudere l'emulatore

```bash
adb -s emulator-5554 emu kill    # spegnimento pulito (salva lo snapshot)
# oppure chiudi la finestra dell'emulatore
```

## Troubleshooting

| Sintomo | Causa probabile | Soluzione |
|---|---|---|
| `emulator: ERROR: x86_64 emulation currently requires hardware acceleration` | KVM non accessibile | Verifica `/dev/kvm` e l'appartenenza al gruppo `kvm` (§1) |
| Emulatore lentissimo, UI a scatti | KVM non attivo, o system image ARM su host x86_64 | Usa una system image `x86_64` come da §3, verifica KVM |
| Boot bloccato su logo Android per minuti | Cold boot dopo `-wipe-data`, oppure macchina sotto carico | Attendi, è normale al primo avvio; se persiste prova `-no-snapshot-load` |
| Finestra emulatore non compare su WSL2 | WSLg non attivo o kernel senza supporto grafico | Aggiorna WSL (`wsl --update`), verifica `echo $DISPLAY` |
| `adb: no devices/emulators found` | Emulatore non ancora avviato o non ancora bootato | `adb wait-for-device`, poi ricontrolla con `adb devices` |
