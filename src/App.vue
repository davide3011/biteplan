<template>
  <div id="app-root">
    <MealPlanner v-if="page === 'meal'" />
    <Converter   v-else-if="page === 'convert'" />
    <ShoppingList v-else-if="page === 'shop'" />
    <BottomNav v-model="page" />

    <!-- bottone info fisso in alto a destra -->
    <button class="btn-info" @click="showInfo = true" aria-label="Informazioni app">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <circle cx="12" cy="12" r="10"/>
        <line x1="12" y1="16" x2="12" y2="12"/>
        <line x1="12" y1="8" x2="12.01" y2="8"/>
      </svg>
    </button>

    <InfoPanel v-model="showInfo" />
  </div>
</template>

<script setup>
import { ref } from 'vue'
import BottomNav    from './components/BottomNav.vue'
import InfoPanel    from './components/InfoPanel.vue'
import MealPlanner  from './pages/MealPlanner.vue'
import Converter    from './pages/Converter.vue'
import ShoppingList from './pages/ShoppingList.vue'

const page = ref('meal')
const showInfo = ref(false)
</script>

<style scoped>
#app-root {
  height: 100dvh;
  display: flex;
  flex-direction: column;
  position: relative;
}

.btn-info {
  position: fixed;
  top: 14px;
  right: 16px;
  /* centra rispetto al max-width del layout */
  max-width: calc(480px);
  background: var(--color-surface);
  color: var(--color-muted);
  min-height: 36px;
  min-width: 36px;
  padding: 0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  box-shadow: var(--shadow-sm);
  border: 1px solid var(--color-border);
  z-index: 50;
  transition: color var(--transition), box-shadow var(--transition);
}

.btn-info:active {
  color: var(--color-primary);
  box-shadow: var(--shadow-md);
  opacity: 1;
}
</style>
