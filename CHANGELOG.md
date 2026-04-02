# Changelog

Tutte le modifiche rilevanti a questo progetto sono documentate in questo file.

Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.1.0/),
il progetto aderisce al [Semantic Versioning](https://semver.org/lang/it/).

---

## [1.1.0] — 2026-04-02

### Aggiunto

- **Condivisione piano pasti via QR code** — pulsante "Condividi" nel Piano Pasti genera un QR code che codifica l'intero piano settimanale; un altro dispositivo può scansionarlo per importare il piano
- **Guida utente aggiornata** — aggiunte sezioni "Condividere il piano" e "Ricevere un piano" nella guida in-app (DocsPanel) e nel file `docs/guida-utente.md`

### Fix

- **AndroidManifest** — aggiunto permesso `CAMERA` necessario per la scansione del QR code nei build generati da Capacitor
- **Dipendenze** — risolte 6 vulnerabilità npm aggiornando `vite` e `vitest` alle versioni più recenti

---

## [1.0.0] — 2026-03-28

### Aggiunto

- **Build APK release firmato** — pipeline Docker aggiornata con supporto
  `assembleRelease` + `zipalign` + `apksigner`; flag `--release` in `build.sh`
  per attivare la firma; keystore montato come volume read-only (mai nell'immagine)
- **`build.sh --release`** — chiede interattivamente le password del keystore;
  supporta override via `KEYSTORE_PASS`, `KEY_PASS`, `KEYSTORE_PATH`
- **Flag combinabili** — `--head` e `--release` ora combinabili in qualsiasi ordine

### Fix

- `build.sh --head` — APK ora copiato in `dist/` del progetto invece di andare
  perso nella directory temporanea cancellata dal trap EXIT
- `build.sh` — `dist/` creata con `mkdir -p` prima del `docker run` per evitare
  ownership root che causava "Permission denied" nelle build successive

---

## [0.9.1] — 2026-03-27

### Aggiunto

- **Guida utente in-app** — pannello documentazione integrato (DocsPanel): slide-from-right, navigazione a pill per sezione (Pasti, Converti, Spesa), IntersectionObserver per pill attiva durante lo scroll, card con step numerati e callout tip
- **Suite di test** — 64 test automatici con Vitest + Playwright:
  - Unit: `conversion.js` e `storage.js` con edge case
  - Integration: Converter, MealPlanner, ShoppingList con Vue Test Utils
  - E2E: navigazione, piano pasti, convertitore, lista della spesa con Playwright
- **Script npm**: `test`, `test:coverage`, `test:e2e`, `test:e2e:ui`

### Modificato

- **InfoPanel** — il link esterno alla documentazione è sostituito dal pulsante "Guida" che apre DocsPanel in-app
- **Convertitore** — nomi degli alimenti in sentence case (`capFirst`) anche nella lista risultati e nell'header della card (non solo i metodi)
- **Convertitore** — simmetria visiva input/output: stesso underline `border-bottom` e stessa dimensione `1.6rem` per entrambe le colonne
- **README** — aggiunta sezione "Requisiti per lo sviluppo" con versioni minime di Node.js, npm, Git e browser
- **Icona app** — favicon e icona Android (round launcher) aggiornate a forma circolare con sfondo trasparente

### Fix

- **Convertitore** — rimosso CSS morto: doppio `align-items` in `.calc-output`, doppio `background` in `.btn-reset`, hack visibility globale su `.calc-unit`

### Documentazione

- **docs/guida-utente.md** — riscritta e allineata allo stato attuale dell'app (tab corrette, funzionalità aggiornate, friggitrice ad aria inclusa)

---

## [0.9.0] — 2026-03-27

### Aggiunto

- **Piano Pasti** — bottone "Genera lista della spesa": raccoglie tutti gli item dalla settimana, deduplica (case-insensitive), salta quelli già presenti e naviga automaticamente alla tab Lista della spesa
- **Convertitore** — espanso il database da 14 a oltre 50 voci; aggiunto supporto friggitrice ad aria per carni, pesce, verdure e tuberi
- **Verdure** — aggiunte 16 nuove voci (spinaci, bieta, broccoli, cavolfiore, fagiolini, asparagi, carciofi, finocchi, porri, verza, cavolo cappuccio, cicoria coltivata, cicoria di campo, cavolini di Bruxelles, rape, agretti)
- **Metodi di cottura verdure** — ogni verdura copre ora tutti i metodi applicabili: bollitura, padella, forno, friggitrice ad aria
- Server Vite esposto sulla rete locale (`--host`): accessibile da dispositivi mobili via `http://<ip>:5173`

### Modificato

- **Convertitore** — coefficienti di resa aggiornati con dati reali da fonti ufficiali (CREA/alimentinutrizione.it, SINU, Istituto Muzzone, AEMMEDI, USDA FNDDS); sostituiti tutti i valori placeholder
- **docs/conversioni.md** — metodologia documentata per derivazione yield da kcal CREA e da USDA FNDDS per cottura in padella; fonti verificate e collegate per ogni valore

### Fix

- Bottone info (`ⓘ`) posizionato sotto `env(safe-area-inset-top)`: non finisce più sotto la status bar su dispositivi con notch
- Convertitore — metodo di cottura ora in sentence case ("Friggitrice ad aria" invece di "Friggitrice Ad Aria")
- `docker/README.md` — percorso APK corretto da `output/` a `dist/`

### Documentazione

- README riscritto con funzionalità dettagliate e nota accesso da mobile

---

## [0.1.0-alpha] — 2026-03-25

Prima versione alpha dell'app BitePlan.

### Aggiunto

- **Piano Pasti** — pianificazione settimanale su 7 giorni × 3 pasti (colazione, pranzo, cena)
  - Aggiunta e rimozione di voci per ogni pasto
  - Card accordion per giorno, giorno corrente aperto di default
  - Persistenza automatica su LocalStorage
- **Convertitore crudo/cotto** — conversione bidirezionale del peso
  - Ricerca alimento in tempo reale
  - 14 alimenti con metodi di cottura multipli
  - Swap diretto tra crudo → cotto e cotto → crudo
- **Lista della spesa** — checklist con aggiunta, spunta e rimozione elementi
  - Separazione visiva tra elementi completati e da completare
  - Funzione svuota lista con conferma
- Navigazione bottom bar (Piano Pasti, Convertitore, Lista della spesa)
- Pannello info app con versione, autore e licenza
- Icona app personalizzata (launcher e favicon)
- Build APK Android tramite Docker (pipeline riproducibile su host x86_64)
  - `build.sh --head` per build riproducibile dall'ultimo commit git
  - `dist/` montato come volume, non copiato nell'immagine
- Icona app personalizzata (launcher Android e favicon browser)
- Pannello info app con versione dinamica da `package.json`, autore e licenza
- Licenza EUPL v1.2
- Documentazione: README, guida utente, tabella coefficienti conversioni con fonti

### Tecnico

- Vue 3 + Vite, CSS mobile-first (max 480px), touch target ≥ 44px
- Capacitor Android per il packaging APK
- Dockerfile basato su `eclipse-temurin:21-jdk-jammy` + Node.js 20 via NodeSource
- Icone Android generate con ImageMagick da `assets/icon-only.png` (5 densità mipmap)
- Versione APK sincronizzata con `package.json` tramite script Node inline

[0.1.0-alpha]: https://github.com/davide3011/biteplan/releases/tag/v0.1.0-alpha
