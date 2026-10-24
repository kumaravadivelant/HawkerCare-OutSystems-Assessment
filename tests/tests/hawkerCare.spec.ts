
import { test, expect } from '@playwright/test';

// ============================================
// HawkerCare - Automated End-to-End Tests
// Technology: Playwright + TypeScript
// Application: OutSystems Reactive Web
// ============================================

const appUrl =
  'https://personal-345ipche.outsystemscloud.com/HawkerCare/Home';

// ============================================
// Before Each Test
// ============================================

test.beforeEach(async ({ page }) => {
  await page.goto(appUrl);

  // Wait until API data is loaded
  await expect(
    page.getByText('107 hawker centres found')
  ).toBeVisible({ timeout: 45000 });
});

// ============================================
// TC01 - Application Data Loading
// ============================================

test('TC01 - Hawker centres load successfully', async ({ page }) => {

  await expect(
    page.getByText('Discover Singapore Hawker Centres')
  ).toBeVisible();

  await expect(
    page.getByText('ABC Brickworks Market & Food Centre')
  ).toBeVisible();

  await expect(
    page.getByText('107 hawker centres found')
  ).toBeVisible();

});

// ============================================
// TC02 - Search by Location
// ============================================

test('TC02 - Search by location', async ({ page }) => {

  const search = page.getByPlaceholder(
    'Search hawker centre by name or location...'
  );

  await search.fill('bedok');

  await expect(
    page.getByText('7 hawker centres found')
  ).toBeVisible();

});

// ============================================
// TC03 - Filter by HDB Owner
// ============================================

test('TC03 - Filter by HDB owner', async ({ page }) => {

  const owner = page.getByRole('combobox');

  await owner.selectOption({ label: 'HDB' });

  await expect(
    page.getByText('82 hawker centres found')
  ).toBeVisible();

});

// ============================================
// TC04 - Combined Search and Owner Filter
// ============================================

test('TC04 - Search and owner filter together', async ({ page }) => {

  const search = page.getByPlaceholder(
    'Search hawker centre by name or location...'
  );

  const owner = page.getByRole('combobox');

  await search.fill('bedok');

  await owner.selectOption({ label: 'HDB' });

  await expect(
    page.getByText('6 hawker centres found')
  ).toBeVisible();

  await expect(
    page.getByText('Blk 16 Bedok South Road')
  ).toBeVisible();

});

// ============================================
// TC05 - Invalid Search / No Results
// ============================================

test('TC05 - Invalid search displays no results', async ({ page }) => {

  const search = page.getByPlaceholder(
    'Search hawker centre by name or location...'
  );

  await search.fill('xyz123');

  await expect(
    page.getByText('0 hawker centres found')
  ).toBeVisible();

  await expect(
    page.getByText(
      'No hawker centres found. Try another name or location.'
    )
  ).toBeVisible();

});

// ============================================
// TC06 - Clear Search Keeps Owner Filter
// ============================================

test('TC06 - Clear search keeps owner filter', async ({ page }) => {

  const search = page.getByPlaceholder(
    'Search hawker centre by name or location...'
  );

  const owner = page.getByRole('combobox');

  // Step 1: Select HDB
  await owner.selectOption({ label: 'HDB' });

  await expect(
    page.getByText('82 hawker centres found')
  ).toBeVisible();

  // Step 2: Search Bedok
  await search.fill('bedok');

  await expect(
    page.getByText('6 hawker centres found')
  ).toBeVisible();

  // Step 3: Click Clear Search button (X)

const clearButton = page.locator('button#Btn_ClearSearch2');

  await expect(clearButton).toBeVisible();

  await clearButton.click();

  // Step 4: Verify search is empty
  await expect(search).toHaveValue('');

  // Step 5: HDB filter must remain selected
  
await expect(owner.locator('option:checked')).toHaveText('HDB');

  // Step 6: All 82 HDB centres must return
  await expect(
    page.getByText('82 hawker centres found')
  ).toBeVisible();

});

// ============================================
// TC07 - Pagination
// ============================================

test('TC07 - Pagination displays 10 records', async ({ page }) => {

  // Step 1: Verify page 1 record range
  await expect(
    page.getByText('1 to 10 of 107 items')
  ).toBeVisible();

  // Step 2: Verify first record on page 1
  await expect(
    page.getByText('ABC Brickworks Market & Food Centre')
  ).toBeVisible();

  // Step 3: Navigate to page 2
  const pageTwo = page.getByText('2', {
    exact: true
  }).last();

  await pageTwo.click();

  // Step 4: Verify page 2 record range
  await expect(
    page.getByText('11 to 20 of 107 items')
  ).toBeVisible();

  // Step 5: Page 1 first record should not appear
  await expect(
    page.getByText('ABC Brickworks Market & Food Centre')
  ).not.toBeVisible();

});

// ============================================
// TC08 - Sorting Hawker Centre Names
// ============================================

test('TC08 - Sort hawker centre names', async ({ page }) => {

  // Step 1: Verify ascending order
  await expect(
    page.getByText('ABC Brickworks Market & Food Centre')
  ).toBeVisible();

  // Step 2: Find sortable column header
  const sortHeader = page.getByText(
    'Hawker Centre Name',
    { exact: true }
  );

  // Step 3: Click to sort descending (Z-A)
  await sortHeader.click();

  // Step 4: Zion should appear on first page
  await expect(
    page.getByText('Zion Riverside Food Centre')
  ).toBeVisible();

  // Step 5: Click again to sort ascending (A-Z)
  await sortHeader.click();

  // Step 6: ABC should appear again
  await expect(
    page.getByText('ABC Brickworks Market & Food Centre')
  ).toBeVisible();

});
