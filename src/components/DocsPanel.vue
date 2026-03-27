<template>
  <Transition name="slide-right">
    <div v-if="modelValue" class="docs-panel" role="dialog" aria-label="Guida utente">

      <!-- Header sticky: back arrow + titolo centrato + spacer bilanciante -->
      <div class="docs-header">
        <button class="btn-back" @click="$emit('update:modelValue', false)" aria-label="Torna indietro">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="15 18 9 12 15 6"/>
          </svg>
        </button>
        <span class="docs-title">Guida</span>
        <!-- spacer identico al btn-back per centrare il titolo -->
        <div aria-hidden="true" class="header-spacer" />
      </div>

      <!-- Pill nav scrollabile — IntersectionObserver aggiorna la pill attiva -->
      <div class="section-nav" role="tablist" aria-label="Sezioni">
        <button
          v-for="s in sections"
          :key="s.id"
          :class="['nav-pill', { active: activeSection === s.id }]"
          role="tab"
          :aria-selected="activeSection === s.id"
          @click="scrollToSection(s.id)"
        >{{ s.label }}</button>
      </div>

      <!-- Contenuto scorrevole -->
      <div class="docs-scroll" ref="scrollEl">

        <!-- ── Pasti ──────────────────────────────── -->
        <section data-section="pasti">
          <div class="section-head">
            <span class="section-icon" aria-hidden="true">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <rect x="3" y="4" width="18" height="18" rx="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
              </svg>
            </span>
            <h2 class="section-heading">Pasti</h2>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Aggiungere un alimento</h3>
            <ol class="steps">
              <li>Tocca il giorno per espandere la card</li>
              <li>Scegli il pasto: <strong>Colazione</strong>, <strong>Pranzo</strong> o <strong>Cena</strong></li>
              <li>Scrivi il nome nel campo di testo</li>
              <li>Premi <kbd>+</kbd> o Invio per aggiungerlo</li>
            </ol>
          </div>

          <div class="doc-card tip">
            <p class="tip-label" aria-hidden="true">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12.01" y2="8"/><line x1="12" y1="12" x2="12" y2="16"/>
              </svg>
              Suggerimento
            </p>
            <p>Premi <strong>Genera lista della spesa</strong> in fondo alla pagina per importare automaticamente tutti gli alimenti della settimana, senza duplicati.</p>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Rimuovere un alimento</h3>
            <p>Tocca il pulsante <strong>×</strong> a destra dell'elemento.</p>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Salvataggio automatico</h3>
            <p>I dati vengono salvati automaticamente sul dispositivo. Non serve premere nessun tasto.</p>
          </div>
        </section>

        <!-- ── Converti ───────────────────────────── -->
        <section data-section="converti">
          <div class="section-head">
            <span class="section-icon" aria-hidden="true">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <polyline points="17 1 21 5 17 9"/>
                <path d="M3 11V9a4 4 0 014-4h14"/>
                <polyline points="7 23 3 19 7 15"/>
                <path d="M21 13v2a4 4 0 01-4 4H3"/>
              </svg>
            </span>
            <h2 class="section-heading">Converti</h2>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Come usarlo</h3>
            <ol class="steps">
              <li>Cerca l'alimento nel campo (es. <em>pollo</em>, <em>riso</em>)</li>
              <li>Seleziona il metodo di cottura dall'elenco</li>
              <li>Inserisci il peso in grammi</li>
              <li>Il risultato appare in tempo reale</li>
              <li>Premi <strong>⇄</strong> per invertire crudo ↔ cotto</li>
            </ol>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Alimenti disponibili</h3>
            <div class="category-table" role="list">
              <div class="cat-row" v-for="cat in categories" :key="cat.label" role="listitem">
                <span class="cat-label">{{ cat.label }}</span>
                <span class="cat-items">{{ cat.items }}</span>
              </div>
            </div>
            <div class="methods-row" aria-label="Metodi di cottura disponibili">
              <span class="method-chip" v-for="m in cookingMethods" :key="m">{{ m }}</span>
            </div>
          </div>
        </section>

        <!-- ── Spesa ──────────────────────────────── -->
        <section data-section="spesa">
          <div class="section-head">
            <span class="section-icon" aria-hidden="true">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
                <line x1="3" y1="6" x2="21" y2="6"/>
                <path d="M16 10a4 4 0 01-8 0"/>
              </svg>
            </span>
            <h2 class="section-heading">Spesa</h2>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Aggiungere un elemento</h3>
            <p>Scrivi il nome nel campo in alto e premi <kbd>+</kbd> o Invio.</p>
          </div>

          <div class="doc-card tip">
            <p class="tip-label" aria-hidden="true">
              <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12.01" y2="8"/><line x1="12" y1="12" x2="12" y2="16"/>
              </svg>
              Suggerimento
            </p>
            <p>Vai alla tab <strong>Pasti</strong> e premi <strong>Genera lista della spesa</strong> per importare automaticamente gli alimenti pianificati.</p>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Spuntare un elemento</h3>
            <p>Tocca la casella a sinistra. Gli elementi completati vengono spostati in una sezione separata con testo barrato.</p>
          </div>

          <div class="doc-card">
            <h3 class="card-title">Rimuovere / svuotare</h3>
            <p>Tocca <strong>×</strong> per rimuovere un elemento singolo, oppure <strong>Svuota lista</strong> in fondo per eliminare tutto (richiede conferma).</p>
          </div>
        </section>

        <div class="docs-footer">BitePlan · v{{ version }} · Davide Grilli</div>

      </div>
    </div>
  </Transition>
</template>

<script setup>
import { ref, watch, nextTick, onUnmounted } from 'vue'
import pkg from '../../package.json'

const props = defineProps({ modelValue: Boolean })
defineEmits(['update:modelValue'])

const version = pkg.version
const scrollEl = ref(null)
const activeSection = ref('pasti')
let observer = null

const sections = [
  { id: 'pasti',    label: 'Pasti'    },
  { id: 'converti', label: 'Converti' },
  { id: 'spesa',    label: 'Spesa'    },
]

const categories = [
  { label: 'Cereali e pasta', items: 'Riso (4 varietà), pasta, farro, orzo, quinoa, cous cous' },
  { label: 'Legumi secchi',   items: 'Ceci, fagioli, lenticchie' },
  { label: 'Verdure',         items: 'Carote, zucchine, patate, spinaci, broccoli, asparagi e altri' },
  { label: 'Carni',           items: 'Pollo petto, tacchino fesa, hamburger, vitello' },
  { label: 'Pesce',           items: 'Tonno, merluzzo, spigola, sogliola' },
  { label: 'Uova',            items: 'Uovo al tegamino, frittata' },
]

const cookingMethods = ['Bollitura', 'Padella', 'Forno', 'Friggitrice ad aria']

watch(() => props.modelValue, async (open) => {
  if (open) {
    await nextTick()
    setupObserver()
    activeSection.value = 'pasti'
    scrollEl.value?.scrollTo({ top: 0 })
  } else {
    observer?.disconnect()
    observer = null
  }
})

function setupObserver() {
  if (!scrollEl.value) return
  observer?.disconnect()
  // rootMargin: entra in zona attiva quando la sezione raggiunge il 20% dall'alto del container
  observer = new IntersectionObserver(
    (entries) => {
      const visible = entries.filter(e => e.isIntersecting)
      if (visible.length) activeSection.value = visible[0].target.dataset.section
    },
    { root: scrollEl.value, rootMargin: '0px 0px -65% 0px', threshold: 0 }
  )
  scrollEl.value.querySelectorAll('[data-section]').forEach(el => observer.observe(el))
}

function scrollToSection(id) {
  const el = scrollEl.value?.querySelector(`[data-section="${id}"]`)
  if (el) el.scrollIntoView({ behavior: 'smooth', block: 'start' })
}

onUnmounted(() => observer?.disconnect())
</script>

<style scoped>
/* ── Panel container ─────────────────────────── */
.docs-panel {
  position: fixed;
  inset: 0;
  max-width: 480px;
  margin: 0 auto;
  background: var(--color-bg);
  z-index: 300;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

/* ── Animazione slide da destra ──────────────── */
/* enter ease-out: risposta immediata, decelera all'arrivo (feel nativo) */
.slide-right-enter-active { transition: transform 320ms cubic-bezier(0.25, 1, 0.5, 1); }
/* leave ease-in: parte lentamente, accelera — chiusura decisa */
.slide-right-leave-active { transition: transform 240ms cubic-bezier(0.55, 0, 1, 0.45); }
.slide-right-enter-from,
.slide-right-leave-to     { transform: translateX(100%); }

/* ── Header ──────────────────────────────────── */
.docs-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  /* safe-area-inset-top: evita sovrapposizione con status bar su iOS */
  padding: calc(env(safe-area-inset-top, 0px) + 10px) 8px 10px;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.btn-back {
  display: flex;
  align-items: center;
  justify-content: center;
  min-height: 44px;
  min-width: 44px;
  background: none;
  color: var(--color-primary);
  border-radius: var(--radius-sm);
  padding: 0;
  transition: background var(--transition);
}

.btn-back:active {
  background: var(--color-primary-muted);
  opacity: 1;
}

.docs-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
  letter-spacing: -0.01em;
}

/* spacer uguale al btn-back per centrare il titolo otticamente */
.header-spacer { width: 44px; }

/* ── Navigazione sezioni (pill) ──────────────── */
.section-nav {
  display: flex;
  gap: 6px;
  padding: 10px 16px;
  overflow-x: auto;
  scrollbar-width: none;
  background: var(--color-surface);
  border-bottom: 1px solid var(--color-border);
  flex-shrink: 0;
}

.section-nav::-webkit-scrollbar { display: none; }

.nav-pill {
  flex-shrink: 0;
  font-size: 0.85rem;
  font-weight: 600;
  padding: 0 14px;
  min-height: 32px;
  border-radius: var(--radius-full);
  background: var(--color-bg);
  color: var(--color-muted);
  border: 1px solid var(--color-border);
  transition: background var(--transition), color var(--transition), border-color var(--transition);
}

.nav-pill.active {
  background: var(--color-primary);
  color: #fff;
  border-color: var(--color-primary);
}

/* ── Scroll container ────────────────────────── */
.docs-scroll {
  flex: 1;
  overflow-y: auto;
  -webkit-overflow-scrolling: touch;
  padding-bottom: calc(env(safe-area-inset-bottom, 0px) + 40px);
}

/* ── Section header ──────────────────────────── */
section { padding-top: 4px; }
section + section { margin-top: 8px; }

.section-head {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 24px 16px 10px;
}

.section-icon {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 32px;
  height: 32px;
  /* quadratino con sfondo primario muted — identifica visivamente la sezione */
  background: var(--color-primary-muted);
  border-radius: var(--radius-sm);
  color: var(--color-primary);
  flex-shrink: 0;
}

.section-heading {
  font-size: 1.1rem;
  font-weight: 800;
  letter-spacing: -0.02em;
  color: var(--color-text);
}

/* ── Card contenuto ──────────────────────────── */
.doc-card {
  margin: 0 16px 8px;
  background: var(--color-surface);
  border-radius: var(--radius);
  padding: 14px 16px;
  border: 1px solid var(--color-border);
  box-shadow: var(--shadow-sm);
  font-size: 0.9rem;
  line-height: 1.55;
  color: var(--color-text);
}

.card-title {
  font-size: 0.82rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  color: var(--color-muted);
  margin-bottom: 8px;
}

/* ── Card tip / suggerimento ─────────────────── */
/* border-left accent: segnala contenuto accessorio senza competere con le card */
.doc-card.tip {
  background: var(--color-primary-muted);
  border-color: transparent;
  border-left: 3px solid var(--color-primary);
  box-shadow: none;
}

.tip-label {
  display: flex;
  align-items: center;
  gap: 5px;
  font-size: 0.72rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.07em;
  color: var(--color-primary);
  margin-bottom: 6px;
}

/* ── Lista numerata con badge ────────────────── */
/* counter CSS invece di <span> inline: mantiene semantica <ol> accessibile */
.steps {
  list-style: none;
  counter-reset: steps;
  display: flex;
  flex-direction: column;
  gap: 9px;
  margin-top: 8px;
}

.steps li {
  counter-increment: steps;
  display: flex;
  align-items: flex-start;
  gap: 10px;
  font-size: 0.9rem;
  line-height: 1.5;
}

.steps li::before {
  content: counter(steps);
  display: flex;
  align-items: center;
  justify-content: center;
  min-width: 22px;
  height: 22px;
  background: var(--color-primary);
  color: #fff;
  border-radius: 50%;
  font-size: 0.7rem;
  font-weight: 700;
  flex-shrink: 0;
  margin-top: 2px;
}

/* ── Kbd inline ──────────────────────────────── */
kbd {
  display: inline-flex;
  align-items: center;
  padding: 1px 7px;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: 5px;
  font-family: inherit;
  font-size: 0.85em;
  font-weight: 600;
  color: var(--color-text);
}

/* ── Tabella categorie alimenti ──────────────── */
.category-table {
  border: 1px solid var(--color-border);
  border-radius: var(--radius-sm);
  overflow: hidden;
  margin-top: 10px;
}

.cat-row {
  display: flex;
  align-items: baseline;
  gap: 8px;
  padding: 9px 12px;
  border-bottom: 1px solid var(--color-border);
  font-size: 0.86rem;
}

.cat-row:last-child { border-bottom: none; }

.cat-label {
  font-weight: 600;
  color: var(--color-text);
  flex-shrink: 0;
  min-width: 110px;
}

.cat-items { color: var(--color-muted); font-size: 0.82rem; }

/* ── Chip metodi cottura ─────────────────────── */
.methods-row {
  display: flex;
  flex-wrap: wrap;
  gap: 6px;
  margin-top: 12px;
}

.method-chip {
  font-size: 0.78rem;
  font-weight: 600;
  padding: 3px 10px;
  background: var(--color-bg);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-full);
  color: var(--color-muted);
}

/* ── Footer ──────────────────────────────────── */
.docs-footer {
  margin: 24px 16px 0;
  text-align: center;
  font-size: 0.78rem;
  color: var(--color-muted);
  opacity: 0.6;
}
</style>
