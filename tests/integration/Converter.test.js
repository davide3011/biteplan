import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Converter from '../../src/pages/Converter.vue'

function mountConverter() {
  return mount(Converter, { attachTo: document.body })
}

describe('Converter — stato iniziale', () => {
  it('mostra il messaggio hint quando non c\'è nessuna ricerca', () => {
    const w = mountConverter()
    expect(w.find('.hint-state').exists()).toBe(true)
    expect(w.find('.converter-card').exists()).toBe(false)
  })

  it('non mostra risultati senza input', () => {
    const w = mountConverter()
    expect(w.findAll('.result-item')).toHaveLength(0)
  })
})

describe('Converter — ricerca', () => {
  it('mostra risultati corrispondenti alla query', async () => {
    const w = mountConverter()
    const input = w.find('input[type="text"]')
    await input.setValue('riso')
    await input.trigger('input')
    expect(w.findAll('.result-item').length).toBeGreaterThan(0)
  })

  it('ogni risultato ha nome alimento e metodo di cottura', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('pollo')
    await w.find('input[type="text"]').trigger('input')
    const first = w.find('.result-item')
    expect(first.find('.result-food').text()).toBeTruthy()
    expect(first.find('.result-method').text()).toBeTruthy()
  })

  it('nasconde l\'hint state durante la ricerca', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('pasta')
    await w.find('input[type="text"]').trigger('input')
    expect(w.find('.hint-state').exists()).toBe(false)
  })

  it('svuota i risultati per query vuota', async () => {
    const w = mountConverter()
    const input = w.find('input[type="text"]')
    await input.setValue('riso')
    await input.trigger('input')
    await input.setValue('')
    await input.trigger('input')
    expect(w.findAll('.result-item')).toHaveLength(0)
    expect(w.find('.hint-state').exists()).toBe(true)
  })

  it('i nomi degli alimenti hanno solo l\'iniziale maiuscola', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('riso')
    await w.find('input[type="text"]').trigger('input')
    const foods = w.findAll('.result-food').map(el => el.text())
    // Nessun testo deve avere lettere maiuscole dopo la prima (test multi-word)
    foods.forEach(f => {
      if (f.includes(' ')) {
        // "Riso basmati" → la seconda parola non deve essere capitalizzata
        const words = f.split(' ')
        words.slice(1).forEach(w => expect(w[0]).toBe(w[0].toLowerCase()))
      }
    })
  })
})

describe('Converter — selezione alimento', () => {
  async function selectFirstResult(w, query = 'riso') {
    await w.find('input[type="text"]').setValue(query)
    await w.find('input[type="text"]').trigger('input')
    await w.find('.result-item').trigger('click')
  }

  it('mostra la converter card dopo la selezione', async () => {
    const w = mountConverter()
    await selectFirstResult(w)
    expect(w.find('.converter-card').exists()).toBe(true)
  })

  it('nasconde i risultati dopo la selezione', async () => {
    const w = mountConverter()
    await selectFirstResult(w)
    expect(w.findAll('.result-item')).toHaveLength(0)
  })

  it('mostra nome alimento e metodo nella card', async () => {
    const w = mountConverter()
    await selectFirstResult(w)
    expect(w.find('.food-name').text()).toBeTruthy()
    expect(w.find('.food-method').text()).toBeTruthy()
  })

  it('disabilita il campo di ricerca dopo la selezione', async () => {
    const w = mountConverter()
    await selectFirstResult(w)
    expect(w.find('input[type="text"]').attributes('disabled')).toBeDefined()
  })
})

describe('Converter — calcolo', () => {
  async function mountWithSelection(query = 'riso basmati') {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue(query)
    await w.find('input[type="text"]').trigger('input')
    await w.find('.result-item').trigger('click')
    return w
  }

  it('mostra il risultato dopo aver inserito i grammi', async () => {
    const w = await mountWithSelection()
    await w.find('.calc-input').setValue('100')
    await w.find('.calc-input').trigger('input')
    expect(w.find('.output-value').exists()).toBe(true)
  })

  it('non mostra risultato per input 0', async () => {
    const w = await mountWithSelection()
    await w.find('.calc-input').setValue('0')
    await w.find('.calc-input').trigger('input')
    expect(w.find('.output-value').exists()).toBe(false)
  })

  it('mostra il footer con fattore di resa quando c\'è un risultato', async () => {
    const w = await mountWithSelection()
    await w.find('.calc-input').setValue('100')
    await w.find('.calc-input').trigger('input')
    expect(w.find('.card-footer').exists()).toBe(true)
    expect(w.find('.card-footer').text()).toContain('fattore di resa')
  })
})

describe('Converter — swap direzione', () => {
  it('il pulsante swap inverte le label crudo/cotto', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('pasta')
    await w.find('input[type="text"]').trigger('input')
    await w.find('.result-item').trigger('click')

    expect(w.find('.calc-label').text()).toMatch(/crudo/i)
    await w.find('.btn-swap').trigger('click')
    expect(w.find('.calc-label').text()).toMatch(/cotto/i)
  })

  it('swap azzera il campo grammi', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('pasta')
    await w.find('input[type="text"]').trigger('input')
    await w.find('.result-item').trigger('click')
    await w.find('.calc-input').setValue('200')
    await w.find('.btn-swap').trigger('click')
    // Dopo lo swap il campo deve essere vuoto (grams = null)
    expect(w.find('.calc-input').element.value).toBe('')
  })
})

describe('Converter — reset', () => {
  it('il pulsante Cambia riporta allo stato di ricerca', async () => {
    const w = mountConverter()
    await w.find('input[type="text"]').setValue('riso')
    await w.find('input[type="text"]').trigger('input')
    await w.find('.result-item').trigger('click')
    await w.find('.btn-reset').trigger('click')
    expect(w.find('.converter-card').exists()).toBe(false)
    expect(w.find('input[type="text"]').attributes('disabled')).toBeUndefined()
  })
})
