<template>
  <div class="page">
    <div class="page-header">
      <h1 class="page-title">Piano Pasti</h1>
      <p class="page-subtitle">{{ todayDate }}</p>
    </div>
    <MealCard
      v-for="day in days"
      :key="day.id"
      :day-name="day.label"
      :meals="meals[day.id]"
      :default-open="day.id === todayId"
      @add="(slot, text) => addItem(day.id, slot, text)"
      @remove="(slot, idx) => removeItem(day.id, slot, idx)"
    />
    <button class="btn-generate" @click="generateShopping">
      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 2L3 6v14a2 2 0 002 2h14a2 2 0 002-2V6l-3-4z"/>
        <line x1="3" y1="6" x2="21" y2="6"/>
        <path d="M16 10a4 4 0 01-8 0"/>
      </svg>
      Genera lista della spesa
    </button>

    <div class="btn-share-row">
      <button class="btn-share" @click="openShare">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <rect x="3" y="3" width="7" height="7" rx="1"/>
          <rect x="14" y="3" width="7" height="7" rx="1"/>
          <rect x="3" y="14" width="7" height="7" rx="1"/>
          <rect x="14" y="14" width="3" height="3" rx="0.5"/>
          <rect x="19" y="14" width="2" height="2" rx="0.5"/>
          <rect x="14" y="19" width="2" height="2" rx="0.5"/>
          <rect x="18" y="19" width="3" height="2" rx="0.5"/>
        </svg>
        Condividi
      </button>
      <button class="btn-share btn-share--receive" @click="openScan">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z"/>
          <circle cx="12" cy="13" r="4"/>
        </svg>
        Ricevi
      </button>
    </div>
  </div>

  <!-- Modal: Condividi -->
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="showShareModal" class="qr-overlay" @click.self="closeShare">
        <div class="qr-sheet" role="dialog" aria-label="Condividi piano pasti" aria-modal="true">
          <div class="sheet-handle" />
          <div class="qr-header">
            <span class="qr-title">Condividi piano</span>
            <button class="btn-x" @click="closeShare" aria-label="Chiudi">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
          <p class="qr-hint">Fai scansionare questo codice dall'altro dispositivo</p>
          <div class="qr-img-wrap">
            <img v-if="qrDataUrl" :src="qrDataUrl" alt="QR code piano pasti" class="qr-img" />
            <p v-else-if="qrError" class="qr-error">{{ qrError }}</p>
            <div v-else class="qr-loading">Generazione in corso…</div>
          </div>
        </div>
      </div>
    </Transition>
  </Teleport>

  <!-- Modal: Ricevi -->
  <Teleport to="body">
    <Transition name="fade">
      <div v-if="showScanModal" class="qr-overlay" @click.self="closeAndStopScan">
        <div class="qr-sheet" role="dialog" aria-label="Ricevi piano pasti" aria-modal="true">
          <div class="sheet-handle" />
          <div class="qr-header">
            <span class="qr-title">Scansiona QR</span>
            <button class="btn-x" @click="closeAndStopScan" aria-label="Chiudi">
              <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round">
                <line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/>
              </svg>
            </button>
          </div>
          <p class="qr-hint">Inquadra il codice QR dell'altro dispositivo</p>
          <div class="scan-wrap">
            <video ref="videoEl" class="scan-video" autoplay playsinline muted />
            <canvas ref="canvasEl" class="scan-canvas" aria-hidden="true" />
            <div class="scan-frame" aria-hidden="true" />
          </div>
          <p v-if="scanError" class="qr-error">{{ scanError }}</p>
          <p v-if="scanSuccess" class="qr-success">Piano ricevuto!</p>
        </div>
      </div>
    </Transition>
  </Teleport>
</template>

<script setup>
import { reactive, watch, ref, onUnmounted, nextTick } from 'vue'
import MealCard from '../components/MealCard.vue'
import { save, load } from '../utils/storage.js'
import QRCode from 'qrcode'
import jsQR from 'jsqr'

const emit = defineEmits(['go-shop'])

const days = [
  { id: 'lunedi',    label: 'Lunedì'    },
  { id: 'martedi',   label: 'Martedì'   },
  { id: 'mercoledi', label: 'Mercoledì' },
  { id: 'giovedi',   label: 'Giovedì'   },
  { id: 'venerdi',   label: 'Venerdì'   },
  { id: 'sabato',    label: 'Sabato'    },
  { id: 'domenica',  label: 'Domenica'  },
]

const todayMap = ['domenica', 'lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato']
const todayId = todayMap[new Date().getDay()]
const todayDate = 'Oggi, ' + new Date().toLocaleDateString('it-IT', { weekday: 'long', day: 'numeric', month: 'long' })

const defaultMeals = () =>
  Object.fromEntries(days.map(d => [d.id, { colazione: [], pranzo: [], cena: [] }]))

const meals = reactive(load('meals', defaultMeals()))

watch(meals, () => save('meals', meals), { deep: true })

function addItem(day, slot, text) {
  const t = text.trim()
  if (t) meals[day][slot].push(t)
}

function removeItem(day, slot, idx) {
  meals[day][slot].splice(idx, 1)
}

function generateShopping() {
  const allItems = days.flatMap(d =>
    ['colazione', 'pranzo', 'cena'].flatMap(slot => meals[d.id][slot])
  )
  const existing = load('shopping', [])
  const existingNames = new Set(existing.map(i => i.name.toLowerCase()))
  const seen = new Set()
  const toAdd = []
  for (const name of allItems) {
    const key = name.toLowerCase()
    if (!existingNames.has(key) && !seen.has(key)) {
      seen.add(key)
      toAdd.push({ id: Date.now() + Math.random(), name, checked: false })
    }
  }
  save('shopping', [...existing, ...toAdd])
  emit('go-shop')
}

// ── Share (QR generation) ─────────────────────────────────────────────────

const showShareModal = ref(false)
const qrDataUrl      = ref('')
const qrError        = ref('')

async function openShare() {
  qrDataUrl.value = ''
  qrError.value   = ''
  showShareModal.value = true

  const payload = JSON.stringify({ v: 1, meals })
  if (payload.length > 2953) {
    qrError.value = 'Dati troppo grandi per un QR code. Riduci il numero di alimenti inseriti.'
    return
  }
  try {
    qrDataUrl.value = await QRCode.toDataURL(payload, {
      errorCorrectionLevel: 'L',
      margin: 1,
      width: 260,
      color: { dark: '#1a1a1a', light: '#ffffff' },
    })
  } catch {
    qrError.value = 'Impossibile generare il QR code.'
  }
}

function closeShare() {
  showShareModal.value = false
  qrDataUrl.value = ''
  qrError.value   = ''
}

// ── Receive (camera scan) ─────────────────────────────────────────────────

const showScanModal = ref(false)
const videoEl       = ref(null)
const canvasEl      = ref(null)
const scanError     = ref('')
const scanSuccess   = ref(false)

let stream = null
let rafId  = null

async function openScan() {
  scanError.value   = ''
  scanSuccess.value = false
  showScanModal.value = true
  await nextTick()

  try {
    stream = await navigator.mediaDevices.getUserMedia({
      video: { facingMode: 'environment' },
      audio: false,
    })
    videoEl.value.srcObject = stream
    videoEl.value.play()
    rafId = requestAnimationFrame(scanFrame)
  } catch (err) {
    if (err.name === 'NotAllowedError') {
      scanError.value = 'Accesso fotocamera negato. Abilita il permesso nelle impostazioni del dispositivo.'
    } else {
      scanError.value = 'Impossibile accedere alla fotocamera.'
    }
  }
}

function scanFrame() {
  const video  = videoEl.value
  const canvas = canvasEl.value
  if (!video || !canvas || video.readyState < 2) {
    rafId = requestAnimationFrame(scanFrame)
    return
  }

  canvas.width  = video.videoWidth
  canvas.height = video.videoHeight
  const ctx = canvas.getContext('2d')
  ctx.drawImage(video, 0, 0)

  const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
  const code = jsQR(imageData.data, canvas.width, canvas.height, {
    inversionAttempts: 'dontInvert',
  })

  if (code) {
    handleScannedData(code.data)
    return
  }

  rafId = requestAnimationFrame(scanFrame)
}

function handleScannedData(raw) {
  stopCamera()
  try {
    const parsed = JSON.parse(raw)
    if (parsed?.v !== 1 || typeof parsed.meals !== 'object') {
      scanError.value = 'QR non valido: dati non riconosciuti.'
      return
    }
    const expectedDays  = ['lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica']
    const expectedSlots = ['colazione', 'pranzo', 'cena']
    for (const day of expectedDays) {
      for (const slot of expectedSlots) {
        if (!Array.isArray(parsed.meals[day]?.[slot])) {
          scanError.value = 'QR non valido: struttura dati errata.'
          return
        }
      }
    }
    for (const day of expectedDays) {
      for (const slot of expectedSlots) {
        meals[day][slot] = parsed.meals[day][slot]
      }
    }
    scanSuccess.value = true
    setTimeout(() => closeAndStopScan(), 1200)
  } catch {
    scanError.value = 'QR non valido: impossibile leggere i dati.'
  }
}

function stopCamera() {
  if (rafId)  { cancelAnimationFrame(rafId); rafId = null }
  if (stream) { stream.getTracks().forEach(t => t.stop()); stream = null }
}

function closeAndStopScan() {
  stopCamera()
  showScanModal.value = false
  scanError.value     = ''
  scanSuccess.value   = false
}

onUnmounted(stopCamera)
</script>

<style scoped>
.btn-generate {
  width: 100%;
  margin-top: 8px;
  background: var(--color-primary);
  color: #fff;
  font-weight: 600;
  font-size: 0.95rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  min-height: 48px;
  border-radius: var(--radius);
}

.btn-generate:active {
  opacity: 0.85;
}

/* ── Riga Condividi / Ricevi ─────────────────────── */
.btn-share-row {
  display: flex;
  gap: 8px;
  margin-top: 8px;
}

.btn-share {
  flex: 1;
  background: var(--color-primary-muted);
  color: var(--color-primary);
  font-weight: 600;
  font-size: 0.9rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  min-height: 44px;
  border-radius: var(--radius);
  border: 1.5px solid transparent;
}

.btn-share:active {
  background: var(--color-primary);
  color: #fff;
  opacity: 1;
}

.btn-share--receive {
  background: var(--color-surface);
  border-color: var(--color-border);
  color: var(--color-text);
}

.btn-share--receive:active {
  background: var(--color-bg);
  opacity: 1;
}

/* ── Overlay ─────────────────────────────────────── */
.qr-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.5);
  z-index: 400;
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

/* ── Bottom sheet ────────────────────────────────── */
.qr-sheet {
  width: 100%;
  max-width: 480px;
  background: var(--color-surface);
  border-radius: var(--radius) var(--radius) 0 0;
  padding: 12px 20px 48px;
  box-shadow: 0 -8px 32px rgba(0, 0, 0, 0.12);
}

.sheet-handle {
  width: 36px;
  height: 4px;
  background: var(--color-border);
  border-radius: var(--radius-full);
  margin: 0 auto 20px;
}

.qr-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 8px;
}

.qr-title {
  font-size: 1rem;
  font-weight: 700;
  color: var(--color-text);
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

.qr-hint {
  font-size: 0.85rem;
  color: var(--color-muted);
  margin-bottom: 20px;
}

/* ── QR image ────────────────────────────────────── */
.qr-img-wrap {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 180px;
}

.qr-img {
  width: 240px;
  height: 240px;
  border-radius: var(--radius-sm);
  image-rendering: pixelated;
}

.qr-loading {
  font-size: 0.9rem;
  color: var(--color-muted);
}

/* ── Scanner ─────────────────────────────────────── */
.scan-wrap {
  position: relative;
  width: 100%;
  max-width: 320px;
  margin: 0 auto 16px;
  border-radius: var(--radius);
  overflow: hidden;
  background: #000;
  aspect-ratio: 1;
}

.scan-video {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

.scan-canvas {
  display: none;
}

.scan-frame {
  position: absolute;
  inset: 24px;
  border: 2.5px solid var(--color-primary-light);
  border-radius: var(--radius-sm);
  pointer-events: none;
}

/* ── Feedback ────────────────────────────────────── */
.qr-error {
  font-size: 0.85rem;
  color: var(--color-danger);
  background: var(--color-danger-muted);
  border-radius: var(--radius-sm);
  padding: 10px 14px;
  margin-top: 4px;
}

.qr-success {
  font-size: 0.9rem;
  font-weight: 700;
  color: var(--color-primary);
  background: var(--color-primary-muted);
  border-radius: var(--radius-sm);
  padding: 10px 14px;
  margin-top: 4px;
  text-align: center;
}

/* ── Transizioni ─────────────────────────────────── */
.fade-enter-active,
.fade-leave-active { transition: opacity 200ms ease; }
.fade-enter-from,
.fade-leave-to      { opacity: 0; }
</style>
