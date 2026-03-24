# SOP — BitePlan (Vue 3 + Vite → Capacitor Android)

## Scope

App mobile-first con tre funzionalità:

1. **Meal Planner** — pianificazione settimanale (7 giorni × 3 pasti: colazione, pranzo, cena). Ogni pasto contiene una lista di voci testuali liberamente modificabili.
2. **Conversione crudo/cotto** — calcolo del peso cotto a partire dal peso crudo (e viceversa) tramite coefficienti di resa definiti in un JSON interno.
3. **Lista della spesa** — checklist con aggiunta, spunta e rimozione elementi.

---

## Stack tecnologico

| Livello | Scelta |
|---|---|
| Frontend | Vue 3 + Vite |
| Stato | Composables (no store) |
| Persistenza | LocalStorage |
| UI | CSS base mobile-first |
| Mobile (fase successiva) | Capacitor Android |
| Build riproducibile (opzionale) | Docker |

Sviluppo iniziale: `npm run dev` + Chrome DevTools modalità mobile.

---

## Struttura progetto

```
src/
├── pages/
│   ├── MealPlanner.vue
│   ├── Converter.vue
│   └── ShoppingList.vue
├── components/
│   ├── BottomNav.vue
│   ├── MealCard.vue
│   └── CheckboxItem.vue
├── data/
│   └── conversions.json
├── utils/
│   ├── conversion.js
│   └── storage.js
└── App.vue
```

---

## Fase 1 — Setup

```bash
npm create vue@latest biteplan
cd biteplan
npm install
npm run dev
```

Test mobile: Chrome → F12 → viewport 360×640.

---

## Fase 2 — Meal Planner

**Struttura dati**

```js
{
  lunedi: { colazione: [], pranzo: [], cena: [] },
  martedi: { ... }
}
```

**Funzionalità**
- Aggiungere/rimuovere voci per ogni pasto
- Visualizzare l'intera settimana
- Salvataggio automatico su LocalStorage

---

## Fase 3 — Conversione crudo/cotto

**JSON** — `src/data/conversions.json`

```json
{
  "pollo": { "forno": { "yield": 0.75 }, "padella": { "yield": 0.70 } },
  "riso":  { "bollito": { "yield": 2.5 } }
}
```

`yield = peso_cotto / peso_crudo`

**Funzioni** — `src/utils/conversion.js`

```js
export const rawToCooked = (food, method, raw, db) => raw * db[food][method].yield
export const cookedToRaw = (food, method, cooked, db) => cooked / db[food][method].yield
```

**UX**: ricerca testuale sull'alimento → selezione alimento+metodo → input grammi → risultato in tempo reale.

Esempio: 140 g pollo crudo → 105 g cotti al forno.

---

## Fase 4 — Lista della spesa

**Struttura dati**

```js
[{ id, name, checked }]
```

**Funzionalità**: aggiungi, spunta, elimina, svuota lista.

---

## Fase 5 — UI Mobile

Navigazione bottom bar: Pasti | Converti | Spesa.

Linee guida: bottoni min 44px, input semplici, una funzione per schermata.

---

## Fase 6 — Android (Capacitor)

```bash
npm install @capacitor/core @capacitor/cli
npx cap init
npx cap add android
npm run build && npx cap sync && npx cap run android
```

---

## Fase 7 — Docker (opzionale)

Pipeline: install → build frontend → cap sync → gradle build APK.

---

## Fasi future

- Modifica coefficienti di conversione in-app
- Calcolo kcal
- Generazione automatica lista spesa dai pasti pianificati
- Sync cloud

---

## Checklist

- [ ] Meal planner funzionante
- [ ] Conversioni corrette
- [ ] JSON alimenti presente (12+ voci)
- [ ] Lista spesa funzionante
- [ ] Persistenza attiva
- [ ] APK testabile
