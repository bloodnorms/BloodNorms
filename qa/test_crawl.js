import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

(async () => {
  console.log('--- Launching Chrome for Smoke Test ---');
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  const consoleLogs = [];
  const networkErrors = [];

  page.on('console', msg => {
    consoleLogs.push({ type: msg.type(), text: msg.text() });
    console.log(`[BROWSER CONSOLE ${msg.type().toUpperCase()}]:`, msg.text());
  });

  page.on('requestfailed', request => {
    networkErrors.push({
      url: request.url(),
      error: request.failure() ? request.failure().errorText : 'unknown',
    });
    console.log(`[NETWORK FAILED]: ${request.url()} - ${request.failure()?.errorText}`);
  });

  console.log('Navigating to http://localhost:5000 ...');
  try {
    const response = await page.goto('http://localhost:5000', {
      waitUntil: 'networkidle0',
      timeout: 30000,
    });
    console.log('Response status:', response ? response.status() : 'null');
  } catch (e) {
    console.log('Navigation event:', e.message);
  }

  // Wait a few seconds for Flutter CanvasKit / Skwasm renderer to initialize
  await new Promise(r => setTimeout(r, 4000));

  const currentUrl = page.url();
  console.log('Current Page URL:', currentUrl);
  const title = await page.title();
  console.log('Page Title:', title);

  const evidenceDir = path.join(__dirname, 'evidence', 'smoke');
  fs.mkdirSync(evidenceDir, { recursive: true });

  const screenshotPath = path.join(evidenceDir, 'smoke-01-home.png');
  await page.screenshot({ path: screenshotPath });
  console.log(`Saved screenshot to ${screenshotPath}`);

  // Test deep links
  const routes = ['/admin', '/bank', '/donor', '/b', '/group', '/units', '/location', '/details'];
  for (const r of routes) {
    console.log(`\nNavigating to http://localhost:5000${r} ...`);
    try {
      await page.goto(`http://localhost:5000${r}`, { waitUntil: 'networkidle0', timeout: 15000 });
      await new Promise(res => setTimeout(res, 2500));
      console.log(`Current URL after ${r}:`, page.url());
      const slug = r.replace('/', '').replace('/', '_') || 'home';
      const snapPath = path.join(evidenceDir, `smoke-${slug}.png`);
      await page.screenshot({ path: snapPath });
      console.log(`Captured ${snapPath}`);
    } catch (err) {
      console.error(`Failed on route ${r}:`, err.message);
    }
  }

  await browser.close();
  console.log('Smoke test complete!');
})();
