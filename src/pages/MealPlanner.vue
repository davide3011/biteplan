<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Piano Pasti</h1>
      <p class="page-subtitle">{{ todayDate }}</p>
    </div>
    <MealCard
      v-for="day in days"
      :key="day.id"
      :day-name="day.label"
      :meals="meals[day.id]"
      :default-open="day.id === todayId"
      @add="(slot, text) => addItem(day.id, slot, text)"
      @remove="(slot, idx) => removeItem(day.id, slot, idx)"
    />
    <button class="btn-generate" @click="generateShopping">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 01-8 0"/>
      </svg>
      Genera lista della spesa
    </button>
  </div>
</template>

<script setup>
import { reactive, watch } from 'vue'
import MealCard from '../components/MealCard.vue'
import { save, load } from '../utils/storage.js'

const emit = defineEmits(['go-shop'])

const days = [
  { id: 'lunedi',    label: 'Lunedì'    },
  { id: 'martedi',   label: 'Martedì'   },
  { id: 'mercoledi', label: 'Mercoledì' },
  { id: 'giovedi',   label: 'Giovedì'   },
  { id: 'venerdi',   label: 'Venerdì'   },
  { id: 'sabato',    label: 'Sabato'    },
  { id: 'domenica',  label: 'Domenica'  },
]

const todayMap = ['domenica', 'lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato']
const todayId = todayMap[new Date().getDay()]
const todayDate = 'Oggi, ' + new Date().toLocaleDateString('it-IT', { weekday: 'long', day: 'numeric', month: 'long' })

const defaultMeals = () =>
  Object.fromEntries(days.map(d => [d.id, { colazione: [], pranzo: [], cena: [] }]))

const meals = reactive(load('meals', defaultMeals()))

watch(meals, () => save('meals', meals), { deep: true })

function addItem(day, slot, text) {
  const t = text.trim()
  if (t) meals[day][slot].push(t)
}

function removeItem(day, slot, idx) {
  meals[day][slot].splice(idx, 1)
}

function generateShopping() {
  const allItems = days.flatMap(d =>
    ['colazione', 'pranzo', 'cena'].flatMap(slot => meals[d.id][slot])
  )
  const existing = load('shopping', [])
  const existingNames = new Set(existing.map(i => i.name.toLowerCase()))
  const seen = new Set()
  const toAdd = []
  for (const name of allItems) {
    const key = name.toLowerCase()
    if (!existingNames.has(key) && !seen.has(key)) {
      seen.add(key)
      toAdd.push({ id: Date.now() + Math.random(), name, checked: false })
    }
  }
  save('shopping', [...existing, ...toAdd])
  emit('go-shop')
}
</script>

<style scoped>
.btn-generate {
  width: 100%;
  margin-top: 8px;
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 48px;
  border-radius: var(--radius);
}

.btn-generate:active {
  opacity: 0.85;
}
</style>
