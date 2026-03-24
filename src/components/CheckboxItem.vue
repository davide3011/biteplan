<template>
  <li class="checkbox-item" :class="{ checked: item.checked }">
    <label class="item-label">
      <input type="checkbox" :checked="item.checked" @change="$emit('toggle')" />
      <span class="item-name">{{ item.name }}</span>
    </label>
    <button class="btn-remove" @click="$emit('remove')">✕</button>
  </li>
</template>

<script setup>
defineProps({ item: Object })
defineEmits(['toggle', 'remove'])
</script>

<style scoped>
.checkbox-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: var(--color-surface);
  border-radius: var(--radius);
  padding: 12px 14px;
  border: 1px solid var(--color-border);
}

.item-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  flex: 1;
}

input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
  accent-color: var(--color-primary);
}

.item-name {
  font-size: 1rem;
}

.checked .item-name {
  text-decoration: line-through;
  color: var(--color-muted);
}

.btn-remove {
  background: none;
  color: var(--color-muted);
  min-height: unset;
  padding: 0 4px;
  font-size: 0.8rem;
}
</style>
