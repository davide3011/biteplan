import { test, expect } from '@playwright/test'

test.describe('Navigazione tra tab', () => {
  test.beforeEach(async ({ page }) => {
    await page.goto('/')
  })

  test('la tab Pasti è attiva al caricamento', async ({ page }) => {
    await expect(page.locator('.nav-btn.active')).toContainText('Pasti')
    await expect(page.locator('.page-title')).toContainText('Piano Pasti')
  })

  test('la tab Converti mostra il convertitore', async ({ page }) => {
    await page.locator('.nav-btn', { hasText: 'Converti' }).click()
    await expect(page.locator('.page-title')).toContainText('Convertitore')
    await expect(page.locator('.nav-btn.active')).toContainText('Converti')
  })

  test('la tab Spesa mostra la lista della spesa', async ({ page }) => {
    await page.locator('.nav-btn', { hasText: 'Spesa' }).click()
    await expect(page.locator('.page-title')).toContainText('Lista della spesa')
    await expect(page.locator('.nav-btn.active')).toContainText('Spesa')
  })

  test('si può tornare a Pasti da un\'altra tab', async ({ page }) => {
    await page.locator('.nav-btn', { hasText: 'Converti' }).click()
    await page.locator('.nav-btn', { hasText: 'Pasti' }).click()
    await expect(page.locator('.page-title')).toContainText('Piano Pasti')
  })

  test('il pulsante info apre il pannello informazioni', async ({ page }) => {
    await page.locator('.btn-info').click()
    await expect(page.locator('.sheet')).toBeVisible()
    await expect(page.locator('.app-name')).toContainText('BitePlan')
  })

  test('il pannello info si chiude con la X', async ({ page }) => {
    await page.locator('.btn-info').click()
    await page.locator('.btn-x').click()
    await expect(page.locator('.sheet')).not.toBeVisible()
  })
})
