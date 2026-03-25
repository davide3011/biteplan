<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Conversione</h1>
      <p class="page-subtitle">crudo ↔ cotto</p>
    </div>

    <div class="search-box">
      <input
        v-model="query"
        type="text"
        placeholder="Cerca alimento (es. pollo, riso...)"
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

    <div v-if="selected" class="converter-panel">

      <div class="selected-chip">
        <span class="chip-text">{{ selected.food }} · {{ selected.method }}</span>
        <button class="btn-chip-reset" @click="reset" aria-label="Cambia alimento">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>

      <div class="direction-toggle">
        <button :class="['toggle-btn', { active: direction === 'rawToCooked' }]" @click="direction = 'rawToCooked'">crudo → cotto</button>
        <button :class="['toggle-btn', { active: direction === 'cookedToRaw' }]" @click="direction = 'cookedToRaw'">cotto → crudo</button>
      </div>

      <div class="input-group">
        <label class="input-label">{{ direction === 'rawToCooked' ? 'Grammi crudi' : 'Grammi cotti' }}</label>
        <div class="input-row">
          <input v-model.number="grams" type="number" min="0" placeholder="0" />
          <span class="unit">g</span>
        </div>
      </div>

      <div v-if="result !== null" class="result-box">
        <div class="result-formula">
          {{ grams }}g × {{ yieldValue }} =
        </div>
        <div class="result-main">
          <span class="result-value">{{ result }}</span>
          <span class="result-unit">g</span>
        </div>
        <div class="result-desc">{{ direction === 'rawToCooked' ? 'da mangiare cotti' : 'peso crudo equivalente' }}</div>
      </div>
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
  query.value = `${r.food} — ${r.method}`
  results.value = []
  grams.value = null
}

function reset() {
  selected.value = null
  query.value = ''
  results.value = []
  grams.value = null
}
</script>

<style scoped>
.search-box { margin-bottom: 8px; }

.results-list {
  list-style: none;
  background: var(--color-surface);
  border: 1.5px solid var(--color-border);
  border-radius: var(--radius);
  overflow: hidden;
  margin-bottom: 16px;
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

.converter-panel { display: flex; flex-direction: column; gap: 16px; }

.selected-chip {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: var(--color-primary-muted);
  border-radius: var(--radius-full);
  padding: 6px 12px 6px 14px;
  align-self: flex-start;
}

.chip-text {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-primary);
  text-transform: capitalize;
}

.btn-chip-reset {
  background: none;
  color: var(--color-primary);
  min-height: unset;
  padding: 2px;
  display: flex;
  align-items: center;
  opacity: 0.7;
}

.direction-toggle { display: flex; gap: 8px; }

.toggle-btn {
  flex: 1;
  background: var(--color-surface);
  color: var(--color-muted);
  border: 1.5px solid var(--color-border);
  font-size: 0.875rem;
  font-weight: 500;
  border-radius: var(--radius-sm);
}

.toggle-btn.active {
  background: var(--color-primary);
  color: #fff;
  border-color: var(--color-primary);
}

.input-group { display: flex; flex-direction: column; gap: 6px; }

.input-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.input-row { display: flex; align-items: center; gap: 10px; }
.unit { font-size: 1rem; color: var(--color-muted); font-weight: 500; }

.result-box {
  background: var(--color-primary);
  border-radius: var(--radius);
  padding: 24px 20px;
  text-align: center;
  box-shadow: var(--shadow-md);
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.result-formula {
  font-size: 0.8rem;
  color: rgba(255,255,255,0.65);
}

.result-main {
  display: flex;
  align-items: baseline;
  justify-content: center;
  gap: 4px;
}

.result-value {
  font-size: 3rem;
  font-weight: 800;
  color: #fff;
  letter-spacing: -0.02em;
  line-height: 1;
}

.result-unit {
  font-size: 1.4rem;
  color: rgba(255,255,255,0.8);
  font-weight: 600;
}

.result-desc {
  font-size: 0.85rem;
  color: rgba(255,255,255,0.65);
  margin-top: 2px;
}
</style>
