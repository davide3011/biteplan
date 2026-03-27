import { test, expect } from '@playwright/test'

test.describe('Piano Pasti', () => {
  test.beforeEach(async ({ page }) => {
    // Pulisce localStorage per partire da uno stato noto
    await page.goto('/')
    await page.evaluate(() => localStorage.clear())
    await page.reload()
  })

  test('mostra 7 card giornaliere', async ({ page }) => {
    const cards = page.locator('.meal-card')
    await expect(cards).toHaveCount(7)
  })

  test('il giorno corrente è espanso di default', async ({ page }) => {
    // Almeno una card deve essere aperta (class "open")
    await expect(page.locator('.meal-card.open')).toHaveCount(1)
  })

  test('si può espandere e chiudere una card con tap', async ({ page }) => {
    const firstHeader = page.locator('.card-header').first()
    const firstCard = page.locator('.meal-card').first()

    // Se la prima card è già aperta, chiudila prima
    const isOpen = await firstCard.evaluate(el => el.classList.contains('open'))
    await firstHeader.click()
    if (isOpen) {
      await expect(firstCard).not.toHaveClass(/open/)
    } else {
      await expect(firstCard).toHaveClass(/open/)
    }
  })

  test('aggiunge un alimento al pranzo del giorno corrente', async ({ page }) => {
    const openCard = page.locator('.meal-card.open')
    const pranzoInput = openCard.locator('.meal-slot').nth(1).locator('input[type="text"]')
    await pranzoInput.fill('pasta al pomodoro')
    await pranzoInput.press('Enter')

    await expect(openCard.locator('.item-text', { hasText: 'pasta al pomodoro' })).toBeVisible()
  })

  test('rimuove un alimento con il pulsante ×', async ({ page }) => {
    const openCard = page.locator('.meal-card.open')
    const pranzoInput = openCard.locator('.meal-slot').nth(1).locator('input[type="text"]')
    await pranzoInput.fill('riso')
    await pranzoInput.press('Enter')

    const itemRow = openCard.locator('.item-row', { hasText: 'riso' })
    await expect(itemRow).toBeVisible()
    await itemRow.locator('.btn-remove').click()
    await expect(itemRow).not.toBeVisible()
  })

  test('genera la lista della spesa e passa alla tab Spesa', async ({ page }) => {
    const openCard = page.locator('.meal-card.open')
    const cenahInput = openCard.locator('.meal-slot').nth(2).locator('input[type="text"]')
    await cenahInput.fill('pollo')
    await cenahInput.press('Enter')

    await page.locator('.btn-generate').click()

    // Deve essere passato alla tab Spesa
    await expect(page.locator('.page-title')).toContainText('Lista della spesa')
    await expect(page.locator('.item-name', { hasText: 'pollo' })).toBeVisible()
  })

  test('i dati persistono dopo il reload', async ({ page }) => {
    const openCard = page.locator('.meal-card.open')
    const colazioneInput = openCard.locator('.meal-slot').first().locator('input[type="text"]')
    await colazioneInput.fill('caffè')
    await colazioneInput.press('Enter')

    await page.reload()
    await expect(page.locator('.meal-card.open .item-text', { hasText: 'caffè' })).toBeVisible()
  })
})
