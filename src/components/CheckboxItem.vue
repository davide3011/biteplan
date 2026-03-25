<template>
  <li class="checkbox-item" :class="{ checked: item.checked }">
    <label class="item-label">
      <input type="checkbox" :checked="item.checked" @change="$emit('toggle')" />
      <span class="item-name">{{ item.name }}</span>
    </label>
    <button class="btn-remove" @click="$emit('remove')" :aria-label="`Rimuovi ${item.name}`">
      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
        <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
      </svg>
    </button>
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
  border-radius: var(--radius-sm);
  padding: 4px 4px 4px 14px;
  border: 1.5px solid var(--color-border);
  box-shadow: var(--shadow-sm);
  transition: background var(--transition), border-color var(--transition);
}

.checkbox-item.checked {
  background: var(--color-bg);
  border-color: transparent;
  box-shadow: none;
}

.item-label {
  display: flex;
  align-items: center;
  gap: 12px;
  cursor: pointer;
  flex: 1;
  padding: 8px 0;
}

input[type="checkbox"] {
  width: 20px;
  height: 20px;
  cursor: pointer;
  accent-color: var(--color-primary);
  flex-shrink: 0;
}

.item-name {
  font-size: 1rem;
  transition: color var(--transition);
}

.checked .item-name {
  text-decoration: line-through;
  color: var(--color-muted);
}

/* touch target pieno 44×44px */
.btn-remove {
  background: none;
  color: var(--color-muted);
  min-height: 44px;
  min-width: 44px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: var(--radius-sm);
  flex-shrink: 0;
}

.btn-remove:active { color: var(--color-danger); }
</style>
