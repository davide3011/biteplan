<template>
  <div class="page">
    <h1 class="page-title">Conversione crudo / cotto</h1>

    <div class="search-box">
      <input
        v-model="query"
        type="text"
        placeholder="Cerca alimento (es. pollo)"
        @input="onSearch"
      />
    </div>

    <ul v-if="results.length && !selected" class="results-list">
      <li
        v-for="r in results"
        :key="r.key"
        class="result-item"
        @click="selectItem(r)"
      >
        {{ r.food }} — {{ r.method }}
      </li>
    </ul>

    <div v-if="selected" class="converter-panel">
      <div class="selected-label">
        {{ selected.food }} — {{ selected.method }}
        <button class="btn-link" @click="reset">cambia</button>
      </div>

      <div class="direction-toggle">
        <button :class="['toggle-btn', { active: direction === 'rawToCooked' }]" @click="direction = 'rawToCooked'">crudo → cotto</button>
        <button :class="['toggle-btn', { active: direction === 'cookedToRaw' }]" @click="direction = 'cookedToRaw'">cotto → crudo</button>
      </div>

      <div class="input-row">
        <input v-model.number="grams" type="number" min="0" placeholder="grammi" />
        <span class="unit">g</span>
      </div>

      <div v-if="result !== null" class="result-box">
        <span class="result-value">{{ result }}</span>
        <span class="result-unit">g</span>
        <span class="result-label">{{ direction === 'rawToCooked' ? 'cotti' : 'crudi' }}</span>
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
.search-box { margin-bottom: 12px; }

.results-list {
  list-style: none;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  overflow: hidden;
  margin-bottom: 16px;
}

.result-item {
  padding: 12px 16px;
  cursor: pointer;
  border-bottom: 1px solid var(--color-border);
  text-transform: capitalize;
}

.result-item:last-child { border-bottom: none; }
.result-item:active { background: var(--color-bg); }

.converter-panel { display: flex; flex-direction: column; gap: 16px; }

.selected-label {
  font-weight: 600;
  text-transform: capitalize;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-link {
  background: none;
  color: var(--color-primary);
  min-height: unset;
  padding: 0;
  font-size: 0.85rem;
}

.direction-toggle { display: flex; gap: 8px; }

.toggle-btn {
  flex: 1;
  background: var(--color-bg);
  color: var(--color-muted);
  border: 1px solid var(--color-border);
  font-size: 0.85rem;
}

.toggle-btn.active {
  background: var(--color-primary);
  color: #fff;
  border-color: var(--color-primary);
}

.input-row { display: flex; align-items: center; gap: 8px; }
.unit { font-size: 1rem; color: var(--color-muted); }

.result-box {
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  padding: 20px;
  text-align: center;
}

.result-value { font-size: 2.5rem; font-weight: 700; color: var(--color-primary); }
.result-unit  { font-size: 1.2rem; color: var(--color-muted); margin: 0 4px; }
.result-label { font-size: 1rem; color: var(--color-muted); }
</style>
