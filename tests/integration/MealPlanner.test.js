import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import MealPlanner from '../../src/pages/MealPlanner.vue'
import { load } from '../../src/utils/storage.js'

// Stub di MealCard: espone props e può emettere add/remove
const MealCardStub = {
  name: 'MealCard',
  template: '<div class="meal-card-stub" />',
  props: ['dayName', 'meals', 'defaultOpen'],
  emits: ['add', 'remove'],
}

function mountPlanner() {
  return mount(MealPlanner, {
    global: { stubs: { MealCard: MealCardStub } },
  })
}

// Pre-popola il localStorage con un piano pasti completo
function seedMeals(overrides = {}) {
  const base = Object.fromEntries(
    ['lunedi', 'martedi', 'mercoledi', 'giovedi', 'venerdi', 'sabato', 'domenica'].map(
      d => [d, { colazione: [], pranzo: [], cena: [] }]
    )
  )
  const merged = { ...base, ...overrides }
  localStorage.setItem('meals', JSON.stringify(merged))
  return merged
}

describe('MealPlanner — rendering', () => {
  it('rende 7 card giornaliere', () => {
    const w = mountPlanner()
    expect(w.findAll('.meal-card-stub')).toHaveLength(7)
  })

  it('mostra il pulsante "Genera lista della spesa"', () => {
    const w = mountPlanner()
    expect(w.find('.btn-generate').exists()).toBe(true)
  })

  it('mostra la data corrente nel sottotitolo', () => {
    const w = mountPlanner()
    expect(w.find('.page-subtitle').text()).toMatch(/oggi/i)
  })
})

describe('MealPlanner — aggiunta e rimozione voci', () => {
  it('aggiunge un alimento al pranzo di lunedì', async () => {
    const w = mountPlanner()
    const cards = w.findAllComponents(MealCardStub)
    // lunedì è il primo giorno (indice 0)
    await cards[0].vm.$emit('add', 'pranzo', 'pasta')
    await nextTick()

    const saved = load('meals', {})
    expect(saved.lunedi.pranzo).toContain('pasta')
  })

  it('non aggiunge stringhe vuote', async () => {
    // Seed necessario: il watcher non scatta se nulla cambia,
    // quindi localStorage rimarrebbe vuoto e load() returnerebbe {}
    seedMeals()
    const w = mountPlanner()
    const cards = w.findAllComponents(MealCardStub)
    await cards[0].vm.$emit('add', 'pranzo', '   ')
    await nextTick()

    const saved = load('meals', {})
    expect(saved.lunedi.pranzo).toHaveLength(0)
  })

  it('rimuove un alimento tramite indice', async () => {
    seedMeals({ lunedi: { colazione: [], pranzo: ['pasta', 'insalata'], cena: [] } })
    const w = mountPlanner()
    const cards = w.findAllComponents(MealCardStub)
    await cards[0].vm.$emit('remove', 'pranzo', 0) // rimuovi "pasta"
    await nextTick()

    const saved = load('meals', {})
    expect(saved.lunedi.pranzo).toEqual(['insalata'])
  })

  it('persiste le modifiche in localStorage', async () => {
    const w = mountPlanner()
    const cards = w.findAllComponents(MealCardStub)
    await cards[1].vm.$emit('add', 'cena', 'pollo')
    await nextTick()

    expect(load('meals', {}).martedi.cena).toContain('pollo')
  })
})

describe('MealPlanner — genera lista della spesa', () => {
  it('emette go-shop al click del pulsante', async () => {
    const w = mountPlanner()
    await w.find('.btn-generate').trigger('click')
    expect(w.emitted('go-shop')).toBeTruthy()
  })

  it('salva gli alimenti del piano in localStorage come spesa', async () => {
    seedMeals({
      lunedi:  { colazione: ['caffè'], pranzo: ['pasta'], cena: ['pollo'] },
      martedi: { colazione: [],        pranzo: ['riso'],  cena: []        },
    })
    const w = mountPlanner()
    await w.find('.btn-generate').trigger('click')

    const shopping = load('shopping', [])
    const names = shopping.map(i => i.name)
    expect(names).toContain('caffè')
    expect(names).toContain('pasta')
    expect(names).toContain('pollo')
    expect(names).toContain('riso')
  })

  it('non aggiunge duplicati rispetto agli elementi già in lista', async () => {
    seedMeals({ lunedi: { colazione: [], pranzo: ['pasta'], cena: [] } })
    // Pasta già presente nella lista della spesa
    localStorage.setItem('shopping', JSON.stringify([
      { id: 1, name: 'pasta', checked: false },
    ]))

    const w = mountPlanner()
    await w.find('.btn-generate').trigger('click')

    const shopping = load('shopping', [])
    const pastaCount = shopping.filter(i => i.name.toLowerCase() === 'pasta').length
    expect(pastaCount).toBe(1)
  })

  it('non aggiunge duplicati tra i giorni del piano', async () => {
    seedMeals({
      lunedi:  { colazione: [], pranzo: ['pasta'], cena: [] },
      martedi: { colazione: [], pranzo: ['pasta'], cena: [] }, // stesso alimento
    })
    const w = mountPlanner()
    await w.find('.btn-generate').trigger('click')

    const shopping = load('shopping', [])
    const pastaCount = shopping.filter(i => i.name.toLowerCase() === 'pasta').length
    expect(pastaCount).toBe(1)
  })

  it('non aggiunge nulla se il piano è vuoto', async () => {
    const w = mountPlanner()
    await w.find('.btn-generate').trigger('click')
    expect(load('shopping', [])).toHaveLength(0)
  })
})

describe('MealPlanner — svuota piano', () => {
  it('non mostra il pulsante se il piano è vuoto', () => {
    const w = mountPlanner()
    expect(w.find('.btn-clear').exists()).toBe(false)
  })

  it('mostra il pulsante se c\'è almeno un pasto', () => {
    seedMeals({ lunedi: { colazione: ['caffè'], pranzo: [], cena: [] } })
    const w = mountPlanner()
    expect(w.find('.btn-clear').exists()).toBe(true)
  })

  it('svuota il piano dopo conferma', async () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true)
    seedMeals({ lunedi: { colazione: ['caffè'], pranzo: ['pasta'], cena: [] } })
    const w = mountPlanner()

    await w.find('.btn-clear').trigger('click')
    await nextTick()

    const saved = load('meals', {})
    expect(saved.lunedi.colazione).toHaveLength(0)
    expect(saved.lunedi.pranzo).toHaveLength(0)
    expect(w.find('.btn-clear').exists()).toBe(false)
  })

  it('non svuota se l\'utente annulla', async () => {
    vi.spyOn(window, 'confirm').mockReturnValue(false)
    seedMeals({ lunedi: { colazione: ['caffè'], pranzo: [], cena: [] } })
    const w = mountPlanner()

    await w.find('.btn-clear').trigger('click')
    await nextTick()

    expect(load('meals', {}).lunedi.colazione).toHaveLength(1)
  })
})
