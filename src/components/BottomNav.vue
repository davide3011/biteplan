<template>
  <nav class="bottom-nav">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      :class="['nav-btn', { active: modelValue === tab.id }]"
      @click="$emit('update:modelValue', tab.id)"
    >
      <span class="nav-icon">{{ tab.icon }}</span>
      <span class="nav-label">{{ tab.label }}</span>
    </button>
  </nav>
</template>

<script setup>
defineProps({ modelValue: String })
defineEmits(['update:modelValue'])

const tabs = [
  { id: 'meal',    icon: '📅', label: 'Pasti'    },
  { id: 'convert', icon: '⚖️', label: 'Converti' },
  { id: 'shop',    icon: '🛒', label: 'Spesa'    },
]
</script>

<style scoped>
.bottom-nav {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  max-width: 480px;
  height: var(--nav-height);
  background: var(--color-surface);
  border-top: 1px solid var(--color-border);
  display: flex;
  z-index: 100;
}

.nav-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 2px;
  background: none;
  border-radius: 0;
  color: var(--color-muted);
  min-height: unset;
  padding: 0;
  font-size: 0.7rem;
}

.nav-btn.active {
  color: var(--color-primary);
}

.nav-icon {
  font-size: 1.2rem;
}

.nav-label {
  font-size: 0.7rem;
}
</style>
