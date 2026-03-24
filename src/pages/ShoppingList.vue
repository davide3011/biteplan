<template>
  <div class="page">
    <h1 class="page-title">Lista della spesa</h1>

    <div class="add-row">
      <input
        v-model="newItem"
        type="text"
        placeholder="Aggiungi elemento..."
        @keyup.enter="add"
      />
      <button class="btn-add" @click="add">+</button>
    </div>

    <ul v-if="items.length" class="shop-list">
      <CheckboxItem
        v-for="item in items"
        :key="item.id"
        :item="item"
        @toggle="toggle(item.id)"
        @remove="remove(item.id)"
      />
    </ul>

    <p v-else class="empty-msg">Nessun elemento nella lista.</p>

    <button v-if="items.length" class="btn-clear" @click="clearAll">Svuota lista</button>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import CheckboxItem from '../components/CheckboxItem.vue'
import { save, load } from '../utils/storage.js'

const items = ref(load('shopping', []))
const newItem = ref('')

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
  font-size: 1.4rem;
  min-width: 44px;
  flex-shrink: 0;
}

.shop-list {
  list-style: none;
  display: flex;
  flex-direction: column;
  gap: 4px;
  margin-bottom: 20px;
}

.empty-msg {
  color: var(--color-muted);
  text-align: center;
  margin: 40px 0;
}

.btn-clear {
  width: 100%;
  background: var(--color-danger);
  color: #fff;
}
</style>
