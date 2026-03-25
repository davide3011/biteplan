<template>
  <div class="meal-card" :class="{ open: isOpen }">
    <button class="card-header" @click="isOpen = !isOpen" :aria-expanded="isOpen">
      <span class="day-name">{{ dayName }}</span>
      <span class="day-summary" v-if="!isOpen && totalItems > 0">{{ totalItems }} {{ totalItems === 1 ? 'voce' : 'voci' }}</span>
      <span class="chevron" :class="{ rotated: isOpen }">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
          <polyline points="6 9 12 15 18 9"/>
        </svg>
      </span>
    </button>

    <div class="card-body" v-show="isOpen">
      <div v-for="slot in slots" :key="slot.id" class="meal-slot">
        <div class="slot-header">
          <span class="slot-icon">{{ slot.icon }}</span>
          <h3 class="slot-label">{{ slot.label }}</h3>
        </div>

        <ul v-if="meals[slot.id].length" class="item-list">
          <li v-for="(item, idx) in meals[slot.id]" :key="idx" class="item-row">
            <span class="item-text">{{ item }}</span>
            <button class="btn-remove" @click="$emit('remove', slot.id, idx)" :aria-label="`Rimuovi ${item}`">✕</button>
          </li>
        </ul>

        <div class="input-row">
          <input
            v-model="inputs[slot.id]"
            type="text"
            :placeholder="`Aggiungi a ${slot.label.toLowerCase()}...`"
            @keyup.enter="submit(slot.id)"
          />
          <button class="btn-add" @click="submit(slot.id)" aria-label="Aggiungi">
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'

const props = defineProps({
  dayName: String,
  meals: Object,
  defaultOpen: { type: Boolean, default: false },
})
const emit = defineEmits(['add', 'remove'])

const isOpen = ref(props.defaultOpen)

const slots = [
  { id: 'colazione', label: 'Colazione', icon: '☀️' },
  { id: 'pranzo',    label: 'Pranzo',    icon: '🌤️' },
  { id: 'cena',      label: 'Cena',      icon: '🌙' },
]

const inputs = reactive({ colazione: '', pranzo: '', cena: '' })

const totalItems = computed(() =>
  slots.reduce((sum, s) => sum + props.meals[s.id].length, 0)
)

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
  margin-bottom: 10px;
  box-shadow: var(--shadow-sm);
  overflow: hidden;
  border: 1px solid var(--color-border);
}

.card-header {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 14px 16px;
  background: none;
  border-radius: 0;
  min-height: unset;
  text-align: left;
}

.day-name {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
  flex: 1;
}

/* numero voci mostrato quando la card è chiusa */
.day-summary {
  font-size: 0.75rem;
  color: var(--color-muted);
  background: var(--color-primary-muted);
  color: var(--color-primary);
  padding: 2px 8px;
  border-radius: var(--radius-full);
  font-weight: 600;
}

.chevron {
  color: var(--color-muted);
  display: flex;
  transition: transform var(--transition);
}

.chevron.rotated { transform: rotate(180deg); }

.card-body {
  padding: 0 16px 16px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.meal-slot { display: flex; flex-direction: column; gap: 6px; }

.slot-header {
  display: flex;
  align-items: center;
  gap: 6px;
}

.slot-icon { font-size: 0.9rem; }

.slot-label {
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--color-muted);
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.item-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.item-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-bg);
  border-radius: var(--radius-sm);
  padding: 8px 10px;
}

.item-text { font-size: 0.9rem; flex: 1; }

/* touch target 44px garantito con padding */
.btn-remove {
  background: none;
  color: var(--color-muted);
  min-height: 44px;
  min-width: 44px;
  padding: 0;
  font-size: 0.75rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.btn-remove:active { color: var(--color-danger); }

.input-row { display: flex; gap: 8px; }

.btn-add {
  background: var(--color-primary);
  color: #fff;
  min-width: 48px;
  min-height: 48px;
  flex-shrink: 0;
  padding: 0;
  border-radius: var(--radius-sm);
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
