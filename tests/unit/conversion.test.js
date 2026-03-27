import { describe, it, expect } from 'vitest'
import { rawToCooked, cookedToRaw } from '../../src/utils/conversion.js'

// DB minimale — isola i test dalle modifiche al JSON reale
const db = {
  'riso basmati':  { bollitura:          { yield: 3.00 } },
  'pasta semola':  { bollitura:          { yield: 1.88 } },
  'pollo petto':   { padella:            { yield: 0.75 }, forno: { yield: 0.70 } },
  'zucchine':      { bollitura:          { yield: 0.90 }, padella: { yield: 0.82 } },
  'ceci secchi':   { bollitura:          { yield: 2.90 } },
}

describe('rawToCooked', () => {
  it('calcola il peso cotto con fattore > 1 (cereali)', () => {
    expect(rawToCooked('riso basmati', 'bollitura', 100, db)).toBe(300)
  })

  it('calcola il peso cotto con fattore non intero', () => {
    expect(rawToCooked('pasta semola', 'bollitura', 100, db)).toBeCloseTo(188)
  })

  it('calcola il peso cotto con fattore < 1 (verdure)', () => {
    expect(rawToCooked('zucchine', 'bollitura', 200, db)).toBeCloseTo(180)
  })

  it('restituisce 0 per peso 0', () => {
    expect(rawToCooked('riso basmati', 'bollitura', 0, db)).toBe(0)
  })

  it('scala linearmente con la quantità', () => {
    const single = rawToCooked('riso basmati', 'bollitura', 100, db)
    const double = rawToCooked('riso basmati', 'bollitura', 200, db)
    expect(double).toBeCloseTo(single * 2)
  })

  it('usa il metodo di cottura corretto', () => {
    const padella = rawToCooked('pollo petto', 'padella', 100, db)
    const forno   = rawToCooked('pollo petto', 'forno',   100, db)
    expect(padella).not.toBe(forno)
    expect(padella).toBe(75)
    expect(forno).toBe(70)
  })

  it('funziona con legumi secchi (fattore molto > 1)', () => {
    expect(rawToCooked('ceci secchi', 'bollitura', 100, db)).toBeCloseTo(290)
  })
})

describe('cookedToRaw', () => {
  it('calcola il peso crudo da un peso cotto', () => {
    expect(cookedToRaw('riso basmati', 'bollitura', 300, db)).toBeCloseTo(100)
  })

  it('è l\'inverso esatto di rawToCooked', () => {
    const rawIn = 150
    const cooked = rawToCooked('pollo petto', 'padella', rawIn, db)
    const rawOut = cookedToRaw('pollo petto', 'padella', cooked, db)
    expect(rawOut).toBeCloseTo(rawIn)
  })

  it('funziona con verdure (fattore < 1 → crudo > cotto)', () => {
    const crudo = cookedToRaw('zucchine', 'padella', 82, db)
    expect(crudo).toBeCloseTo(100)
  })

  it('restituisce 0 per peso cotto 0', () => {
    expect(cookedToRaw('riso basmati', 'bollitura', 0, db)).toBe(0)
  })

  it('scala linearmente', () => {
    const base   = cookedToRaw('riso basmati', 'bollitura', 300, db)
    const doppio = cookedToRaw('riso basmati', 'bollitura', 600, db)
    expect(doppio).toBeCloseTo(base * 2)
  })
})
