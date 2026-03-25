<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Pasti della settimana</h1>
      <p class="page-subtitle">{{ todayLabel }}</p>
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
  </div>
</template>

<script setup>
import { reactive, watch } from 'vue'
import MealCard from '../components/MealCard.vue'
import { save, load } from '../utils/storage.js'

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
const todayLabel = days.find(d => d.id === todayId)?.label ?? ''

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
</script>
