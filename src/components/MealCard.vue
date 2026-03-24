<template>
  <div class="meal-card">
    <h2 class="day-name">{{ dayName }}</h2>

    <div v-for="slot in slots" :key="slot.id" class="meal-slot">
      <h3 class="slot-label">{{ slot.label }}</h3>

      <ul v-if="meals[slot.id].length" class="item-list">
        <li v-for="(item, idx) in meals[slot.id]" :key="idx" class="item-row">
          <span class="item-text">{{ item }}</span>
          <button class="btn-remove" @click="$emit('remove', slot.id, idx)">✕</button>
        </li>
      </ul>

      <div class="input-row">
        <input
          v-model="inputs[slot.id]"
          type="text"
          :placeholder="`Aggiungi a ${slot.label.toLowerCase()}...`"
          @keyup.enter="submit(slot.id)"
        />
        <button class="btn-add" @click="submit(slot.id)">+</button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { reactive } from 'vue'

const props = defineProps({
  dayName: String,
  meals: Object,
})
const emit = defineEmits(['add', 'remove'])

const slots = [
  { id: 'colazione', label: 'Colazione' },
  { id: 'pranzo',    label: 'Pranzo'    },
  { id: 'cena',      label: 'Cena'      },
]

const inputs = reactive({ colazione: '', pranzo: '', cena: '' })

function submit(slotId) {
  const t = inputs[slotId].trim()
  if (!t) return
  emit('add', slotId, t)
  inputs[slotId] = ''
}
</script>

<style scoped>
.meal-card {
  background: var(--color-surface);
  border-radius: var(--radius);
  padding: 16px;
  margin-bottom: 12px;
  border: 1px solid var(--color-border);
}

.day-name {
  font-size: 1rem;
  font-weight: 700;
  margin-bottom: 12px;
  color: var(--color-primary);
  text-transform: capitalize;
}

.meal-slot {
  margin-bottom: 12px;
}

.meal-slot:last-child { margin-bottom: 0; }

.slot-label {
  font-size: 0.8rem;
  font-weight: 600;
  color: var(--color-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 6px;
}

.item-list {
  list-style: none;
  margin-bottom: 6px;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-bg);
  border-radius: 6px;
  padding: 6px 10px;
}

.item-text { font-size: 0.9rem; }

.btn-remove {
  background: none;
  color: var(--color-muted);
  min-height: unset;
  padding: 0 4px;
  font-size: 0.75rem;
}

.input-row {
  display: flex;
  gap: 6px;
}

.btn-add {
  background: var(--color-primary-light);
  color: #fff;
  font-size: 1.2rem;
  min-width: 40px;
  flex-shrink: 0;
  min-height: 40px;
  padding: 0;
}
</style>
