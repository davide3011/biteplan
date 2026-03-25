<template>
  <!-- overlay -->
  <Transition name="fade">
    <div v-if="modelValue" class="overlay" @click="$emit('update:modelValue', false)" />
  </Transition>

  <!-- bottom sheet -->
  <Transition name="slide-up">
    <div v-if="modelValue" class="sheet" role="dialog" aria-label="Informazioni app">

      <div class="sheet-handle" />

      <div class="sheet-header">
        <span class="app-name">BitePlan</span>
        <span class="app-version">v{{ version }}</span>
      </div>

      <p class="app-desc">App per la gestione della dieta settimanale: pianifica i pasti, converti i pesi crudo/cotto e gestisci la lista della spesa.</p>

      <div class="divider" />

      <div class="info-row">
        <span class="info-label">Autore</span>
        <span class="info-value">Davide Grilli</span>
      </div>

      <div class="info-row">
        <span class="info-label">Versione</span>
        <span class="info-value">{{ version }}</span>
      </div>

      <div class="info-row">
        <span class="info-label">Licenza</span>
        <span class="info-value">EUPL v1.2</span>
      </div>

      <div class="info-row">
        <span class="info-label">Documentazione</span>
        <a class="info-link" href="https://docs.biteplan.example.com" target="_blank" rel="noopener">
          docs.biteplan.example.com
          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/>
            <polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/>
          </svg>
        </a>
      </div>

      <button class="btn-close" @click="$emit('update:modelValue', false)">Chiudi</button>
    </div>
  </Transition>
</template>

<script setup>
import pkg from '../../package.json'
defineProps({ modelValue: Boolean })
defineEmits(['update:modelValue'])
const version = pkg.version
</script>

<style scoped>
.overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 200;
}

.sheet {
  position: fixed;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  width: 100%;
  max-width: 480px;
  background: var(--color-surface);
  border-radius: var(--radius) var(--radius) 0 0;
  padding: 12px 20px 36px;
  z-index: 201;
  box-shadow: 0 -8px 32px rgba(0, 0, 0, 0.12);
  display: flex;
  flex-direction: column;
  gap: 0;
}

.sheet-handle {
  width: 36px;
  height: 4px;
  background: var(--color-border);
  border-radius: var(--radius-full);
  margin: 0 auto 20px;
}

.sheet-header {
  display: flex;
  align-items: baseline;
  gap: 8px;
  margin-bottom: 8px;
}

.app-name {
  font-size: 1.2rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--color-primary);
}

.app-version {
  font-size: 0.8rem;
  color: var(--color-muted);
  font-weight: 500;
}

.app-desc {
  font-size: 0.88rem;
  color: var(--color-muted);
  line-height: 1.5;
  margin-bottom: 20px;
}

.divider {
  height: 1px;
  background: var(--color-border);
  margin-bottom: 16px;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 11px 0;
  border-bottom: 1px solid var(--color-border);
}

.info-row:last-of-type { border-bottom: none; }

.info-label {
  font-size: 0.88rem;
  color: var(--color-muted);
}

.info-value {
  font-size: 0.88rem;
  font-weight: 600;
  color: var(--color-text);
}

.info-link {
  font-size: 0.88rem;
  font-weight: 600;
  color: var(--color-primary);
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 4px;
}

.btn-close {
  margin-top: 20px;
  width: 100%;
  background: var(--color-bg);
  color: var(--color-text);
  font-weight: 600;
}

/* transizioni */
.fade-enter-active, .fade-leave-active { transition: opacity 200ms ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-up-enter-active, .slide-up-leave-active { transition: transform 250ms ease; }
.slide-up-enter-from, .slide-up-leave-to { transform: translateX(-50%) translateY(100%); }
</style>
