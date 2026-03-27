import { test, expect } from '@playwright/test'

test.describe('Convertitore', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
    await page.locator('.nav-btn', { hasText: 'Converti' }).click()
  })

  test('mostra il messaggio iniziale prima di cercare', async ({ page }) => {
    await expect(page.locator('.hint-state')).toBeVisible()
    await expect(page.locator('.converter-card')).not.toBeVisible()
  })

  test('cerca un alimento e mostra i risultati', async ({ page }) => {
    await page.locator('input[type="text"]').fill('riso')
    await expect(page.locator('.result-item').first()).toBeVisible()
  })

  test('i nomi nella lista hanno solo l\'iniziale maiuscola', async ({ page }) => {
    await page.locator('input[type="text"]').fill('pollo')
    const firstFood = await page.locator('.result-food').first().textContent()
    // "Pollo petto" → solo la prima lettera maiuscola
    expect(firstFood[0]).toBe(firstFood[0].toUpperCase())
    if (firstFood.includes(' ')) {
      const secondWord = firstFood.split(' ')[1]
      expect(secondWord[0]).toBe(secondWord[0].toLowerCase())
    }
  })

  test('seleziona un alimento e mostra la converter card', async ({ page }) => {
    await page.locator('input[type="text"]').fill('riso basmati')
    await page.locator('.result-item').first().click()
    await expect(page.locator('.converter-card')).toBeVisible()
    await expect(page.locator('.result-item')).toHaveCount(0)
  })

  test('calcola il peso cotto inserendo i grammi', async ({ page }) => {
    await page.locator('input[type="text"]').fill('riso basmati')
    await page.locator('.result-item').first().click()
    await page.locator('.calc-input').fill('100')
    // Riso basmati ha fattore 3.0 → 300g cotto
    await expect(page.locator('.output-value')).toBeVisible()
    const result = await page.locator('.output-value').textContent()
    expect(parseFloat(result)).toBeCloseTo(300, 0)
  })

  test('il pulsante ⇄ inverte la direzione crudo↔cotto', async ({ page }) => {
    await page.locator('input[type="text"]').fill('pasta')
    await page.locator('.result-item').first().click()

    const labelBefore = await page.locator('.calc-label').first().textContent()
    await page.locator('.btn-swap').click()
    const labelAfter = await page.locator('.calc-label').first().textContent()

    expect(labelBefore).not.toBe(labelAfter)
  })

  test('il pulsante Cambia torna alla ricerca', async ({ page }) => {
    await page.locator('input[type="text"]').fill('riso')
    await page.locator('.result-item').first().click()
    await page.locator('.btn-reset').click()

    await expect(page.locator('.converter-card')).not.toBeVisible()
    await expect(page.locator('input[type="text"]')).not.toBeDisabled()
  })

  test('mostra il footer con fattore di resa quando c\'è un risultato', async ({ page }) => {
    await page.locator('input[type="text"]').fill('riso')
    await page.locator('.result-item').first().click()
    await page.locator('.calc-input').fill('100')
    await expect(page.locator('.card-footer')).toContainText('fattore di resa')
  })
})
