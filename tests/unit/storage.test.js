import { describe, it, expect, beforeEach } from 'vitest'
import { save, load } from '../../src/utils/storage.js'

// localStorage viene svuotato in tests/setup.js — qui garantiamo isolamento locale
beforeEach(() => localStorage.clear())

describe('save', () => {
  it('serializza un oggetto in JSON', () => {
    save('test', { a: 1, b: 'due' })
    expect(localStorage.getItem('test')).toBe('{"a":1,"b":"due"}')
  })

  it('serializza un array', () => {
    save('list', [1, 2, 3])
    expect(localStorage.getItem('list')).toBe('[1,2,3]')
  })

  it('sovrascrive un valore esistente', () => {
    save('key', 'primo')
    save('key', 'secondo')
    expect(localStorage.getItem('key')).toBe('"secondo"')
  })

  it('gestisce valori primitivi (numero, stringa, booleano)', () => {
    save('n', 42)
    save('s', 'ciao')
    save('b', false)
    expect(JSON.parse(localStorage.getItem('n'))).toBe(42)
    expect(JSON.parse(localStorage.getItem('s'))).toBe('ciao')
    expect(JSON.parse(localStorage.getItem('b'))).toBe(false)
  })
})

describe('load', () => {
  it('restituisce il valore parsato se la chiave esiste', () => {
    localStorage.setItem('obj', '{"a":1}')
    expect(load('obj', null)).toEqual({ a: 1 })
  })

  it('restituisce il default se la chiave non esiste', () => {
    expect(load('nonexistent', 'fallback')).toBe('fallback')
  })

  it('restituisce il default anche per array vuoto come fallback', () => {
    expect(load('missing', [])).toEqual([])
  })

  it('round-trip: save → load restituisce il valore originale', () => {
    const data = [{ id: 1, name: 'pasta', checked: false }]
    save('shopping', data)
    expect(load('shopping', [])).toEqual(data)
  })

  it('round-trip su struttura pasti annidata', () => {
    const meals = { lunedi: { colazione: ['caffè'], pranzo: [], cena: [] } }
    save('meals', meals)
    expect(load('meals', {})).toEqual(meals)
  })
})
