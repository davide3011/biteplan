<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Convertitore</h1>
      <p class="page-subtitle">Calcola il peso cotto dal crudo e viceversa</p>
    </div>

    <!-- step 1: ricerca -->
    <div class="search-wrapper">
      <div class="search-field">
        <svg class="search-icon" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
        </svg>
        <input
          v-model="query"
          type="text"
          placeholder="Cerca alimento…"
          @input="onSearch"
          :disabled="!!selected"
        />
      </div>

      <ul v-if="results.length && !selected" class="results-list">
        <li
          v-for="r in results"
          :key="r.key"
          class="result-item"
          @click="selectItem(r)"
        >
          <span class="result-food">{{ r.food }}</span>
          <span class="result-method">{{ r.method }}</span>
        </li>
      </ul>
    </div>

    <!-- step 2: converter card -->
    <div v-if="selected" class="converter-card">
      <div class="card-top">
        <div class="food-info">
          <span class="food-name">{{ selected.food }}</span>
          <span class="food-sep">·</span>
          <span class="food-method">{{ selected.method }}</span>
        </div>
        <button class="btn-reset" @click="reset" aria-label="Cambia alimento">
          Cambia
        </button>
      </div>

      <div class="card-divider" />

      <!-- riga input → swap → output -->
      <div class="calc-row">
        <div class="calc-side input-side">
          <div class="calc-label">{{ direction === 'rawToCooked' ? 'crudo' : 'cotto' }}</div>
          <div class="calc-input-wrap">
            <input
              v-model.number="grams"
              type="number"
              min="0"
              placeholder="0"
              class="calc-input"
            />
            <span class="calc-unit">g</span>
          </div>
        </div>

        <button class="btn-swap" @click="swapDirection" :title="direction === 'rawToCooked' ? 'Inverti direzione' : 'Inverti direzione'">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="17 1 21 5 17 9"/>
            <path d="M3 11V9a4 4 0 014-4h14"/>
            <polyline points="7 23 3 19 7 15"/>
            <path d="M21 13v2a4 4 0 01-4 4H3"/>
          </svg>
        </button>

        <div class="calc-side output-side" :class="{ 'has-result': result !== null }">
          <div class="calc-label">{{ direction === 'rawToCooked' ? 'cotto' : 'crudo' }}</div>
          <div class="calc-output">
            <span v-if="result !== null" class="output-value">{{ result }}</span>
            <span v-else class="output-placeholder">—</span>
            <span class="calc-unit" :class="{ visible: result !== null }">g</span>
          </div>
        </div>
      </div>

      <div v-if="result !== null" class="card-footer">
        fattore di resa {{ yieldValue }} · {{ direction === 'rawToCooked' ? 'da mangiare cotti' : 'peso crudo equivalente' }}
      </div>
    </div>

    <!-- stato iniziale -->
    <div v-if="!selected && !results.length && !query" class="hint-state">
      <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
      </svg>
      <p>Cerca un alimento per iniziare</p>
      <p class="hint-sub">es. pollo, riso, zucchine</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import db from '../data/conversions.json'
import { rawToCooked, cookedToRaw } from '../utils/conversion.js'

const query = ref('')
const results = ref([])
const selected = ref(null)
const direction = ref('rawToCooked')
const grams = ref(null)

const yieldValue = computed(() => {
  if (!selected.value) return ''
  return db[selected.value.food][selected.value.method].yield
})

const result = computed(() => {
  if (!selected.value || !grams.value || grams.value <= 0) return null
  const { food, method } = selected.value
  const val = direction.value === 'rawToCooked'
    ? rawToCooked(food, method, grams.value, db)
    : cookedToRaw(food, method, grams.value, db)
  return Math.round(val * 10) / 10
})

function onSearch() {
  const q = query.value.toLowerCase().trim()
  if (!q) { results.value = []; return }
  const matches = []
  for (const food of Object.keys(db)) {
    if (food.includes(q)) {
      for (const method of Object.keys(db[food])) {
        matches.push({ key: `${food}-${method}`, food, method })
      }
    }
  }
  results.value = matches
}

function selectItem(r) {
  selected.value = r
  query.value = ''
  results.value = []
  grams.value = null
}

function reset() {
  selected.value = null
  query.value = ''
  results.value = []
  grams.value = null
  direction.value = 'rawToCooked'
}

function swapDirection() {
  direction.value = direction.value === 'rawToCooked' ? 'cookedToRaw' : 'rawToCooked'
  grams.value = null
}
</script>

<style scoped>
/* ── ricerca ───────────────────────────────────────── */
.search-wrapper { margin-bottom: 16px; }

.search-field {
  position: relative;
  display: flex;
  align-items: center;
}

.search-icon {
  position: absolute;
  left: 14px;
  color: var(--color-muted);
  pointer-events: none;
}

.search-field input {
  padding-left: 42px;
}

.results-list {
  list-style: none;
  background: var(--color-surface);
  border: 1.5px solid var(--color-border);
  border-top: none;
  border-radius: 0 0 var(--radius) var(--radius);
  overflow: hidden;
  box-shadow: var(--shadow-sm);
}

.result-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
  cursor: pointer;
  border-bottom: 1px solid var(--color-border);
  transition: background var(--transition);
}

.result-item:last-child { border-bottom: none; }
.result-item:active { background: var(--color-bg); }
.result-food { font-weight: 600; text-transform: capitalize; }
.result-method { font-size: 0.85rem; color: var(--color-muted); text-transform: capitalize; }

/* ── converter card ───────────────────────────────── */
.converter-card {
  background: var(--color-surface);
  border-radius: var(--radius);
  border: 1.5px solid var(--color-border);
  box-shadow: var(--shadow-md);
  overflow: hidden;
}

.card-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 14px 16px;
}

.food-info {
  display: flex;
  align-items: center;
  gap: 6px;
  text-transform: capitalize;
}

.food-name { font-weight: 700; font-size: 1rem; }
.food-sep  { color: var(--color-border); font-size: 1.1rem; }
.food-method { font-size: 0.9rem; color: var(--color-muted); }

.btn-reset {
  background: none;
  color: var(--color-primary);
  font-size: 0.85rem;
  font-weight: 600;
  min-height: unset;
  padding: 4px 10px;
  border: 1.5px solid var(--color-primary-muted);
  border-radius: var(--radius-full);
  background: var(--color-primary-muted);
}

.card-divider {
  height: 1px;
  background: var(--color-border);
  margin: 0 16px;
}

/* ── riga calcolatrice ───────────────────────────── */
.calc-row {
  display: flex;
  align-items: center;
  padding: 20px 16px;
  gap: 12px;
}

.calc-side {
  flex: 1;
  display: flex;
  flex-direction: column;
  gap: 6px;
}

.calc-label {
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.06em;
  color: var(--color-muted);
}

.calc-input-wrap {
  display: flex;
  align-items: center;
  gap: 6px;
}

/* override globale per input dentro la card */
.calc-input {
  font-size: 1.5rem;
  font-weight: 700;
  letter-spacing: -0.02em;
  border: none;
  border-bottom: 2px solid var(--color-border);
  border-radius: 0;
  padding: 4px 0;
  min-height: unset;
  background: transparent;
  width: 100%;
  color: var(--color-text);
  transition: border-color var(--transition);
}

.calc-input:focus {
  outline: none;
  box-shadow: none;
  border-bottom-color: var(--color-primary);
}

.calc-unit {
  font-size: 1rem;
  font-weight: 600;
  color: var(--color-muted);
}

/* bottone swap centrale */
.btn-swap {
  background: var(--color-bg);
  color: var(--color-primary);
  min-height: 44px;
  min-width: 44px;
  padding: 0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
  border: 1.5px solid var(--color-border);
  transition: background var(--transition), transform var(--transition);
}

.btn-swap:active {
  background: var(--color-primary-muted);
  transform: rotate(180deg);
  opacity: 1;
}

/* colonna output */
.output-side .calc-output {
  display: flex;
  align-items: baseline;
  gap: 4px;
  min-height: 44px;
  align-items: center;
}

.output-value {
  font-size: 2rem;
  font-weight: 800;
  letter-spacing: -0.03em;
  color: var(--color-primary);
}

.output-placeholder {
  font-size: 2rem;
  font-weight: 300;
  color: var(--color-border);
}

/* nasconde "g" finché non c'è un risultato */
.calc-unit { visibility: hidden; }
.calc-input-wrap .calc-unit,
.has-result .calc-unit { visibility: visible; }

/* ── footer card ─────────────────────────────────── */
.card-footer {
  padding: 10px 16px 14px;
  font-size: 0.78rem;
  color: var(--color-muted);
  border-top: 1px solid var(--color-border);
  text-align: center;
}

/* ── stato iniziale ──────────────────────────────── */
.hint-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 60px 20px;
  color: var(--color-muted);
}

.hint-sub { font-size: 0.85rem; opacity: 0.6; }
</style>
