<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Lista della spesa</h1>
      <p class="page-subtitle" v-if="items.length">
        {{ checkedCount }} / {{ items.length }} completat{{ checkedCount === 1 ? 'o' : 'i' }}
      </p>
    </div>

    <div class="add-row">
      <input
        v-model="newItem"
        type="text"
        placeholder="Aggiungi elemento..."
        @keyup.enter="add"
      />
      <button class="btn-add" @click="add" aria-label="Aggiungi">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
          <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
        </svg>
      </button>
    </div>

    <template v-if="items.length">
      <ul class="shop-list">
        <CheckboxItem
          v-for="item in pendingItems"
          :key="item.id"
          :item="item"
          @toggle="toggle(item.id)"
          @remove="remove(item.id)"
        />
      </ul>

      <template v-if="checkedCount > 0">
        <div class="section-divider">
          <span>Completati ({{ checkedCount }})</span>
        </div>
        <ul class="shop-list muted">
          <CheckboxItem
            v-for="item in checkedItems"
            :key="item.id"
            :item="item"
            @toggle="toggle(item.id)"
            @remove="remove(item.id)"
          />
        </ul>
      </template>

      <button class="btn-clear" @click="clearAll">Svuota lista</button>
    </template>

    <div v-else class="empty-state">
      <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" style="color: var(--color-border)">
        <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 01-8 0"/>
      </svg>
      <p>Lista vuota</p>
      <p class="empty-hint">Aggiungi qualcosa con il campo qui sopra.</p>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import CheckboxItem from '../components/CheckboxItem.vue'
import { save, load } from '../utils/storage.js'

const items = ref(load('shopping', []))
const newItem = ref('')

const pendingItems = computed(() => items.value.filter(i => !i.checked))
const checkedItems = computed(() => items.value.filter(i => i.checked))
const checkedCount = computed(() => checkedItems.value.length)

watch(items, () => save('shopping', items.value), { deep: true })

function add() {
  const t = newItem.value.trim()
  if (!t) return
  items.value.push({ id: Date.now(), name: t, checked: false })
  newItem.value = ''
}

function toggle(id) {
  const item = items.value.find(i => i.id === id)
  if (item) item.checked = !item.checked
}

function remove(id) {
  items.value = items.value.filter(i => i.id !== id)
}

function clearAll() {
  if (confirm('Svuotare tutta la lista?')) items.value = []
}
</script>

<style scoped>
.add-row {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
}

.btn-add {
  background: var(--color-primary);
  color: #fff;
  min-width: 48px;
  min-height: 48px;
  flex-shrink: 0;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
}

.shop-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 6px;
  margin-bottom: 8px;
}

.section-divider {
  display: flex;
  align-items: center;
  gap: 8px;
  margin: 12px 0 8px;
  font-size: 0.75rem;
  font-weight: 600;
  color: var(--color-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.section-divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--color-border);
}

.empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  padding: 60px 20px;
  color: var(--color-muted);
}

.empty-hint {
  font-size: 0.85rem;
  color: var(--color-muted);
  opacity: 0.7;
}
</style>
