# Pattern di riferimento

Pattern Vue 3 + CSS nativo approvati per questo progetto.

## Variabili CSS del progetto

```css
:root {
  --color-bg: #f5f5f5;
  --color-surface: #ffffff;
  --color-primary: #2d6a4f;
  --color-primary-light: #52b788;
  --color-text: #1a1a1a;
  --color-muted: #6b7280;
  --color-border: #e5e7eb;
  --color-danger: #dc2626;
  --radius: 8px;
  --nav-height: 60px;
}
```

Usa sempre queste variabili. Non aggiungere colori hardcoded.

---

## Input con label accessibile

```vue
<label class="field">
  <span class="field-label">Nome elemento</span>
  <input v-model="value" type="text" placeholder="es. pollo 200g" />
</label>
```

```css
.field { display: flex; flex-direction: column; gap: 4px; }
.field-label { font-size: 0.85rem; color: var(--color-muted); font-weight: 600; }
input { border: 1px solid var(--color-border); border-radius: var(--radius);
        padding: 10px 12px; min-height: 44px; font-size: 1rem; }
input:focus { outline: 2px solid var(--color-primary); outline-offset: 1px; }
```

---

## Riga con azione distruttiva

```vue
<div class="item-row">
  <span class="item-text">{{ item.name }}</span>
  <button class="btn-remove" @click="$emit('remove')" aria-label="Rimuovi {{ item.name }}">✕</button>
</div>
```

```css
.item-row { display: flex; align-items: center; justify-content: space-between;
            background: var(--color-surface); border-radius: var(--radius);
            padding: 12px 14px; border: 1px solid var(--color-border); }
.btn-remove { background: none; color: var(--color-muted); min-height: 44px;
              min-width: 44px; font-size: 0.85rem; }
.btn-remove:active { color: var(--color-danger); }
```

---

## Bottone primario full-width (mobile)

```vue
<button class="btn-primary" @click="action">Conferma</button>
```

```css
.btn-primary { width: 100%; background: var(--color-primary); color: #fff;
               border-radius: var(--radius); min-height: 48px; font-size: 1rem;
               font-weight: 600; }
.btn-primary:active { background: var(--color-primary-light); }
```

---

## Stato vuoto

```vue
<template v-if="items.length">
  <!-- lista -->
</template>
<div v-else class="empty-state">
  <p>Nessun elemento.</p>
  <p class="empty-hint">Aggiungi qualcosa con il campo qui sopra.</p>
</div>
```

```css
.empty-state { text-align: center; padding: 40px 16px; color: var(--color-muted); }
.empty-hint { font-size: 0.85rem; margin-top: 4px; }
```

---

## Toggle a due stati

```vue
<div class="toggle-group">
  <button :class="['toggle-btn', { active: mode === 'a' }]" @click="mode = 'a'">Opzione A</button>
  <button :class="['toggle-btn', { active: mode === 'b' }]" @click="mode = 'b'">Opzione B</button>
</div>
```

```css
.toggle-group { display: flex; gap: 8px; }
.toggle-btn { flex: 1; background: var(--color-bg); color: var(--color-muted);
              border: 1px solid var(--color-border); min-height: 44px; font-size: 0.9rem; }
.toggle-btn.active { background: var(--color-primary); color: #fff; border-color: var(--color-primary); }
```
