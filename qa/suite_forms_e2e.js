import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

(async () => {
  console.log('=== Starting Suite 3: Interactive End-to-End User Journeys ===');

  const evidenceDir = path.join(__dirname, 'evidence', 'e2e');
  fs.mkdirSync(evidenceDir, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  // 1. REQUESTER FLOW
  console.log('\n--- Step 1: Requester Flow ---');
  await page.goto('http://localhost:5000/#/', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));

  // Enable semantics
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));

  await page.screenshot({ path: path.join(evidenceDir, 'e2e_01_home.png') });

  // Click 'Find Blood Now'
  console.log('Clicking "Find Blood Now"...');
  await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
    const btn = btns.find(b => b.innerText && b.innerText.includes('Find Blood Now'));
    if (btn) btn.click();
  });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_02_group_selection.png') });

  // Select 'O+' blood group
  console.log('Selecting "O+" group...');
  await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('flt-semantics[role="button"], flt-semantics'));
    const btn = btns.find(b => b.innerText && b.innerText.trim() === 'O+');
    if (btn) btn.click();
  });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_03_units_screen.png') });

  // Navigate through units, location, details
  console.log('Testing units increment and continue...');
  await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
    const continueBtn = btns.find(b => b.innerText && (b.innerText.includes('Continue') || b.innerText.includes('Next') || b.innerText.includes('Select Hospital')));
    if (continueBtn) continueBtn.click();
  });
  await new Promise(r => setTimeout(r, 2000));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_04_location_screen.png') });

  // Direct navigation to details form for form interaction testing
  console.log('Navigating to Details form to test text fields...');
  await page.goto('http://localhost:5000/#/details', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));

  // Inspect form input fields
  const inputs = await page.evaluate(() => {
    const textfields = Array.from(document.querySelectorAll('input, textarea, flt-semantics[role="textbox"]'));
    return textfields.map(t => ({
      tagName: t.tagName,
      role: t.getAttribute('role'),
      placeholder: t.getAttribute('placeholder'),
      value: t.value || t.innerText,
    }));
  });
  console.log('Discovered Form Inputs on Details:', inputs);
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_05_details_inputs.png') });

  // Navigate to Review screen
  await page.goto('http://localhost:5000/#/review', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_06_review_screen.png') });

  // 2. BANK CONSOLE
  console.log('\n--- Step 2: Bank Staff Console Interactive Testing ---');
  await page.goto('http://localhost:5000/#/bank', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_07_bank_console.png') });

  // Look for action buttons on bank screen
  const bankButtons = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
    return btns.map(b => b.innerText?.trim()).filter(Boolean);
  });
  console.log('Bank Console Buttons:', bankButtons.slice(0, 15));

  // Try clicking 'Schedule Camp' if present
  console.log('Testing Schedule Camp / Action button on Bank Console...');
  const clickedCamp = await page.evaluate(() => {
    const btns = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
    const btn = btns.find(b => b.innerText && (b.innerText.includes('Schedule') || b.innerText.includes('Camp')));
    if (btn) {
      btn.click();
      return true;
    }
    return false;
  });
  if (clickedCamp) {
    await new Promise(r => setTimeout(r, 1500));
    await page.screenshot({ path: path.join(evidenceDir, 'e2e_08_bank_camp_dialog.png') });
  }

  // 3. DONOR APP
  console.log('\n--- Step 3: Donor App Testing ---');
  await page.goto('http://localhost:5000/#/donor', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_09_donor_home.png') });

  // Donor onboarding screen
  await page.goto('http://localhost:5000/#/donor/onboarding', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_10_donor_onboarding.png') });

  // Donor ticket
  await page.goto('http://localhost:5000/#/donor/ticket/QA_20261107_DONOR_TKT_01', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 2500));
  await page.screenshot({ path: path.join(evidenceDir, 'e2e_11_donor_ticket.png') });

  await browser.close();
  console.log('\n=== Suite 3 Complete! Evidence saved to qa/evidence/e2e/ ===');
})();

