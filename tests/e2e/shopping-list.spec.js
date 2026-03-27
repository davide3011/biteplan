import { test, expect } from '@playwright/test'

test.describe('Lista della spesa', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
    await page.evaluate(() => localStorage.clear())
    await page.locator('.nav-btn', { hasText: 'Spesa' }).click()
  })

  test('mostra stato vuoto con lista vuota', async ({ page }) => {
    await expect(page.locator('.empty-state')).toBeVisible()
  })

  test('aggiunge un elemento tramite il pulsante +', async ({ page }) => {
    await page.locator('input[type="text"]').fill('latte')
    await page.locator('.btn-add').click()
    await expect(page.locator('.item-name', { hasText: 'latte' })).toBeVisible()
  })

  test('aggiunge un elemento con il tasto Invio', async ({ page }) => {
    await page.locator('input[type="text"]').fill('burro')
    await page.locator('input[type="text"]').press('Enter')
    await expect(page.locator('.item-name', { hasText: 'burro' })).toBeVisible()
  })

  test('svuota il campo dopo l\'aggiunta', async ({ page }) => {
    await page.locator('input[type="text"]').fill('olio')
    await page.locator('.btn-add').click()
    await expect(page.locator('input[type="text"]')).toHaveValue('')
  })

  test('spunta un elemento e lo sposta nei completati', async ({ page }) => {
    await page.locator('input[type="text"]').fill('pasta')
    await page.locator('.btn-add').click()

    await page.locator('.checkbox-item').first().locator('input[type="checkbox"]').click()
    await expect(page.locator('.section-divider')).toBeVisible()
    await expect(page.locator('.muted .item-name', { hasText: 'pasta' })).toBeVisible()
  })

  test('rimuove un singolo elemento con ×', async ({ page }) => {
    await page.locator('input[type="text"]').fill('farina')
    await page.locator('.btn-add').click()
    await page.locator('.checkbox-item').first().locator('.btn-remove').click()
    await expect(page.locator('.item-name', { hasText: 'farina' })).not.toBeVisible()
    await expect(page.locator('.empty-state')).toBeVisible()
  })

  test('svuota lista con conferma del dialog', async ({ page }) => {
    await page.locator('input[type="text"]').fill('test')
    await page.locator('.btn-add').click()

    page.once('dialog', dialog => dialog.accept())
    await page.locator('.btn-clear').click()

    await expect(page.locator('.empty-state')).toBeVisible()
  })

  test('non svuota lista se si annulla il dialog', async ({ page }) => {
    await page.locator('input[type="text"]').fill('test')
    await page.locator('.btn-add').click()

    page.once('dialog', dialog => dialog.dismiss())
    await page.locator('.btn-clear').click()

    await expect(page.locator('.item-name', { hasText: 'test' })).toBeVisible()
  })

  test('il contatore mostra elementi completati / totale', async ({ page }) => {
    await page.locator('input[type="text"]').fill('a')
    await page.locator('.btn-add').click()
    await page.locator('input[type="text"]').fill('b')
    await page.locator('.btn-add').click()

    await page.locator('.checkbox-item').first().locator('input[type="checkbox"]').click()
    const subtitle = await page.locator('.page-subtitle').textContent()
    expect(subtitle).toMatch(/1/)
    expect(subtitle).toMatch(/2/)
  })

  test('i dati persistono dopo il reload', async ({ page }) => {
    await page.locator('input[type="text"]').fill('yogurt')
    await page.locator('.btn-add').click()

    await page.reload()
    await page.locator('.nav-btn', { hasText: 'Spesa' }).click()
    await expect(page.locator('.item-name', { hasText: 'yogurt' })).toBeVisible()
  })
})
