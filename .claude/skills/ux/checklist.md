# UX Review Checklist

Usa questa checklist quando rivedi o scrivi un componente Vue mobile-first.

## Touch & interazione

- [ ] Ogni elemento interattivo ha `min-height: 44px` e `min-width: 44px`
- [ ] Spaziatura tra elementi adiacenti ≥ 8px (evita tap accidentali)
- [ ] Stati `:active` e `:focus-visible` definiti esplicitamente
- [ ] Nessun hover-only interaction (non funziona su touch)

## Feedback visivo

- [ ] Ogni azione utente ha risposta visiva immediata (cambio colore, spinner, messaggio)
- [ ] Stato vuoto gestito con messaggio utile, non schermata bianca
- [ ] Errori comunicati in linguaggio naturale, non codici tecnici
- [ ] Operazioni distruttive (elimina, svuota) richiedono conferma

## Accessibilità

- [ ] Rapporto di contrasto ≥ 4.5:1 per testo normale, ≥ 3:1 per testo grande
- [ ] `<input>` ha `<label>` associato (non solo placeholder)
- [ ] `<button>` ha testo leggibile o `aria-label`
- [ ] Ordine di navigazione con Tab è logico e visibile

## CSS & coerenza

- [ ] Colori e dimensioni usano variabili CSS (`:root { --color-* }`)
- [ ] Nessun valore hardcoded che duplica una variabile esistente
- [ ] Font-size base 16px, nessun testo sotto 14px
- [ ] `box-sizing: border-box` applicato globalmente

## Vue 3

- [ ] Props tipizzate con `defineProps`
- [ ] Eventi emessi con `defineEmits`
- [ ] Nessuna logica diretta nel template (estrai in computed o funzioni)
- [ ] `watch` con `{ deep: true }` solo dove necessario (ha costo)
