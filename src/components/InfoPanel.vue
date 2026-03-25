<template>
  <Transition name="fade">
    <div v-if="modelValue" class="overlay" @click="$emit('update:modelValue', false)" />
  </Transition>

  <Transition name="slide-up">
    <div v-if="modelValue" class="sheet" role="dialog" aria-label="Informazioni app">

      <div class="sheet-handle" />

      <div class="sheet-top">
        <div class="app-identity">
          <img class="app-icon" :src="appIcon" alt="BitePlan" />
          <div>
            <div class="app-name">BitePlan</div>
            <div class="app-version">Versione {{ version }}</div>
          </div>
        </div>
        <button class="btn-x" @click="$emit('update:modelValue', false)" aria-label="Chiudi">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
            <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
          </svg>
        </button>
      </div>

      <div class="info-list">
        <div class="info-row">
          <span class="info-label">Autore</span>
          <span class="info-value">Davide Grilli</span>
        </div>
        <div class="info-row">
          <span class="info-label">Licenza</span>
          <span class="info-value">EUPL v1.2</span>
        </div>
        <div class="info-row">
          <span class="info-label">Documentazione</span>
          <a class="info-link" href="https://docs.biteplan.example.com" target="_blank" rel="noopener">
            Apri
            <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M18 13v6a2 2 0 01-2 2H5a2 2 0 01-2-2V8a2 2 0 012-2h6"/>
              <polyline points="15 3 21 3 21 9"/><line x1="10" y1="14" x2="21" y2="3"/>
            </svg>
          </a>
        </div>
      </div>

    </div>
  </Transition>
</template>

<script setup>
import pkg from '../../package.json'
import appIcon from '../../assets/icon-only.png'
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
  padding: 12px 20px 48px;
  z-index: 201;
  box-shadow: 0 -8px 32px rgba(0, 0, 0, 0.12);
}

.sheet-handle {
  width: 36px;
  height: 4px;
  background: var(--color-border);
  border-radius: var(--radius-full);
  margin: 0 auto 24px;
}

/* header: icona app + nome/versione + X */
.sheet-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.app-identity {
  display: flex;
  align-items: center;
  gap: 14px;
}

.app-icon {
  width: 48px;
  height: 48px;
  border-radius: 12px;
  object-fit: cover;
}

.app-name {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
}

.app-version {
  font-size: 0.8rem;
  color: var(--color-muted);
  margin-top: 1px;
}

.btn-x {
  background: var(--color-bg);
  color: var(--color-muted);
  min-height: 36px;
  min-width: 36px;
  padding: 0;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid var(--color-border);
}

/* lista righe info */
.info-list {
  border: 1px solid var(--color-border);
  border-radius: var(--radius);
  overflow: hidden;
}

.info-row {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 14px 16px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
}

.info-row:last-child { border-bottom: none; }

.info-label {
  font-size: 0.9rem;
  color: var(--color-text);
}

.info-value {
  font-size: 0.9rem;
  color: var(--color-muted);
}

.info-link {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--color-primary);
  text-decoration: none;
  display: flex;
  align-items: center;
  gap: 4px;
}

/* transizioni */
.fade-enter-active, .fade-leave-active { transition: opacity 200ms ease; }
.fade-enter-from, .fade-leave-to { opacity: 0; }

.slide-up-enter-active, .slide-up-leave-active { transition: transform 250ms ease; }
.slide-up-enter-from, .slide-up-leave-to { transform: translateX(-50%) translateY(100%); }
</style>
