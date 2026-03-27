# BitePlan

App mobile-first per la gestione della dieta quotidiana — pianificazione pasti, conversione crudo/cotto e lista della spesa.

## Funzionalità

### Piano Pasti
- Pianificazione settimanale su 7 giorni × 3 pasti (colazione, pranzo, cena)
- Card accordion per giorno, giorno corrente aperto di default
- Aggiunta e rimozione di voci per ogni pasto
- Generazione automatica della lista della spesa dai pasti pianificati
- Persistenza automatica su LocalStorage

### Convertitore crudo/cotto
- Conversione bidirezionale del peso (crudo → cotto e cotto → crudo)
- Ricerca alimento in tempo reale
- Oltre 50 voci tra cereali, legumi, verdure, carni, pesce e uova
- Fino a 4 metodi di cottura per alimento: bollitura, padella, forno, friggitrice ad aria
- Coefficienti di resa documentati con fonti (CREA, SINU, Istituto Muzzone, USDA)

### Lista della spesa
- Checklist con aggiunta manuale o importazione dai pasti pianificati
- Separazione visiva tra elementi da completare e completati
- Rimozione singola e svuota lista con conferma

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
Da un dispositivo mobile sulla stessa rete, aprire `http://<ip-host>:5173`.

## Build APK Android

Vedi [docker/README.md](docker/README.md) per i requisiti e i dettagli della pipeline.

## Documentazione

- [Guida utente](docs/guida-utente.md)
- [Fonti e documentazione conversioni](docs/conversioni.md)
- [Changelog](CHANGELOG.md)

## Licenza

[EUPL v1.2](LICENSE) — Davide Grilli
