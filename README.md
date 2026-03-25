# BitePlan

App mobile-first per la gestione della dieta quotidiana.

## Funzionalità

- **Piano Pasti** — pianifica colazione, pranzo e cena per ogni giorno della settimana
- **Convertitore crudo/cotto** — calcola il peso cotto a partire dal crudo (e viceversa) con coefficienti di resa per 14 alimenti
- **Lista della spesa** — checklist con aggiunta, spunta e rimozione elementi

## Stack

| Livello | Tecnologia |
|---|---|
| Frontend | Vue 3 + Vite |
| Persistenza | LocalStorage |
| UI | CSS mobile-first (max 480px) |
| Mobile | Capacitor Android |
| Build APK | Docker |

## Avvio in sviluppo

```bash
npm install
npm run dev
```

Aprire [http://localhost:5173](http://localhost:5173) in Chrome con DevTools in modalità mobile (viewport 360×640).

## Build APK Android

Richiede Docker su host **x86_64**.

```bash
bash docker/build.sh
```

L'APK viene generato in `dist/biteplan.apk`. Vedi [docker/README.md](docker/README.md) per i dettagli.

## Documentazione

- [Guida utente](docs/guida-utente.md)
- [Fonti e documentazione conversioni](docs/conversioni.md)
- [Changelog](CHANGELOG.md)

## Licenza

[EUPL v1.2](LICENSE) — Davide Grilli
