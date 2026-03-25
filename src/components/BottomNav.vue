<template>
  <nav class="bottom-nav">
    <button
      v-for="tab in tabs"
      :key="tab.id"
      :class="['nav-btn', { active: modelValue === tab.id }]"
      @click="$emit('update:modelValue', tab.id)"
      :aria-label="tab.label"
    >
      <span class="nav-icon" v-html="tab.icon" />
      <span class="nav-label">{{ tab.label }}</span>
    </button>
  </nav>
</template>

<script setup>
defineProps({ modelValue: String })
defineEmits(['update:modelValue'])

const tabs = [
  {
    id: 'meal',
    label: 'Pasti',
    icon: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <rect x="3" y="4" width="18" height="18" rx="2"/>
      <line x1="16" y1="2" x2="16" y2="6"/>
      <line x1="8" y1="2" x2="8" y2="6"/>
      <line x1="3" y1="10" x2="21" y2="10"/>
    </svg>`,
  },
  {
    id: 'convert',
    label: 'Converti',
    icon: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <polyline points="17 1 21 5 17 9"/>
      <path d="M3 11V9a4 4 0 014-4h14"/>
      <polyline points="7 23 3 19 7 15"/>
      <path d="M21 13v2a4 4 0 01-4 4H3"/>
    </svg>`,
  },
  {
    id: 'shop',
    label: 'Spesa',
    icon: `<svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
      <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
      <line x1="3" y1="6" x2="21" y2="6"/>
      <path d="M16 10a4 4 0 01-8 0"/>
    </svg>`,
  },
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
  box-shadow: 0 -4px 16px rgba(0, 0, 0, 0.06);
}

.nav-btn {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 3px;
  background: none;
  border-radius: 0;
  color: var(--color-muted);
  min-height: unset;
  padding: 0;
  position: relative;
  transition: color var(--transition);
}

.nav-btn.active {
  color: var(--color-primary);
}

/* indicatore attivo: pill sopra l'icona — segnala la tab senza aggressività */
.nav-btn.active::before {
  content: '';
  position: absolute;
  top: 6px;
  width: 28px;
  height: 3px;
  background: var(--color-primary);
  border-radius: var(--radius-full);
}

.nav-icon {
  display: flex;
  align-items: center;
  justify-content: center;
}

.nav-label {
  font-size: 0.68rem;
  font-weight: 500;
}
</style>
