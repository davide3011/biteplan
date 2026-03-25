# Changelog

Tutte le modifiche rilevanti a questo progetto sono documentate in questo file.

Il formato segue [Keep a Changelog](https://keepachangelog.com/it/1.1.0/),
il progetto aderisce al [Semantic Versioning](https://semver.org/lang/it/).

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
