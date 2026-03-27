import { describe, it, expect, vi } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ShoppingList from '../../src/pages/ShoppingList.vue'
import { load } from '../../src/utils/storage.js'

const CheckboxItemStub = {
  name: 'CheckboxItem',
  template: '<li class="checkbox-stub">{{ item.name }}</li>',
  props: ['item'],
  emits: ['toggle', 'remove'],
}

function seedShopping(items) {
  localStorage.setItem('shopping', JSON.stringify(items))
}

function mountShoppingList() {
  return mount(ShoppingList, {
    global: { stubs: { CheckboxItem: CheckboxItemStub } },
  })
}

describe('ShoppingList — stato iniziale', () => {
  it('mostra lo stato vuoto se non ci sono elementi', () => {
    const w = mountShoppingList()
    expect(w.find('.empty-state').exists()).toBe(true)
  })

  it('non mostra il pulsante svuota lista se la lista è vuota', () => {
    const w = mountShoppingList()
    expect(w.find('.btn-clear').exists()).toBe(false)
  })

  it('carica gli elementi dal localStorage all\'avvio', () => {
    seedShopping([{ id: 1, name: 'pasta', checked: false }])
    const w = mountShoppingList()
    expect(w.find('.empty-state').exists()).toBe(false)
    expect(w.findAll('.checkbox-stub')).toHaveLength(1)
  })
})

describe('ShoppingList — aggiunta elementi', () => {
  it('aggiunge un elemento tramite click su +', async () => {
    const w = mountShoppingList()
    await w.find('input[type="text"]').setValue('latte')
    await w.find('.btn-add').trigger('click')

    const items = load('shopping', [])
    expect(items).toHaveLength(1)
    expect(items[0].name).toBe('latte')
    expect(items[0].checked).toBe(false)
  })

  it('aggiunge un elemento tramite tasto Invio', async () => {
    const w = mountShoppingList()
    const input = w.find('input[type="text"]')
    await input.setValue('burro')
    await input.trigger('keyup.enter')

    expect(load('shopping', []).map(i => i.name)).toContain('burro')
  })

  it('svuota il campo input dopo l\'aggiunta', async () => {
    const w = mountShoppingList()
    await w.find('input[type="text"]').setValue('olio')
    await w.find('.btn-add').trigger('click')
    expect(w.find('input[type="text"]').element.value).toBe('')
  })

  it('non aggiunge stringhe vuote', async () => {
    const w = mountShoppingList()
    await w.find('input[type="text"]').setValue('   ')
    await w.find('.btn-add').trigger('click')
    expect(load('shopping', [])).toHaveLength(0)
    expect(w.find('.empty-state').exists()).toBe(true)
  })
})

describe('ShoppingList — toggle e rimozione', () => {
  it('sposta un elemento nei completati dopo toggle', async () => {
    seedShopping([{ id: 1, name: 'pasta', checked: false }])
    const w = mountShoppingList()
    await w.findComponent(CheckboxItemStub).vm.$emit('toggle')
    await nextTick()

    const items = load('shopping', [])
    expect(items[0].checked).toBe(true)
  })

  it('ripristina un elemento già spuntato dopo un secondo toggle', async () => {
    seedShopping([{ id: 1, name: 'pasta', checked: true }])
    const w = mountShoppingList()
    await w.findComponent(CheckboxItemStub).vm.$emit('toggle')
    await nextTick()

    expect(load('shopping', [])[0].checked).toBe(false)
  })

  it('rimuove un singolo elemento', async () => {
    seedShopping([
      { id: 1, name: 'pasta', checked: false },
      { id: 2, name: 'riso',  checked: false },
    ])
    const w = mountShoppingList()
    await w.findAllComponents(CheckboxItemStub)[0].vm.$emit('remove')
    await nextTick()

    const items = load('shopping', [])
    expect(items).toHaveLength(1)
    expect(items[0].name).toBe('riso')
  })
})

describe('ShoppingList — svuota lista', () => {
  it('svuota la lista dopo conferma', async () => {
    vi.spyOn(window, 'confirm').mockReturnValue(true)
    seedShopping([{ id: 1, name: 'pasta', checked: false }])
    const w = mountShoppingList()

    await w.find('.btn-clear').trigger('click')
    await nextTick()

    expect(w.find('.empty-state').exists()).toBe(true)
    expect(load('shopping', [])).toHaveLength(0)
  })

  it('non svuota se l\'utente annulla', async () => {
    vi.spyOn(window, 'confirm').mockReturnValue(false)
    seedShopping([{ id: 1, name: 'pasta', checked: false }])
    const w = mountShoppingList()

    await w.find('.btn-clear').trigger('click')
    await nextTick()

    expect(load('shopping', [])).toHaveLength(1)
  })
})

describe('ShoppingList — contatore completati', () => {
  it('mostra N/totale nel sottotitolo', () => {
    seedShopping([
      { id: 1, name: 'pasta',   checked: true  },
      { id: 2, name: 'riso',    checked: false },
      { id: 3, name: 'patate',  checked: false },
    ])
    const w = mountShoppingList()
    const subtitle = w.find('.page-subtitle').text()
    expect(subtitle).toMatch(/1/)
    expect(subtitle).toMatch(/3/)
  })

  it('non mostra il sottotitolo se la lista è vuota', () => {
    const w = mountShoppingList()
    expect(w.find('.page-subtitle').exists()).toBe(false)
  })
})
