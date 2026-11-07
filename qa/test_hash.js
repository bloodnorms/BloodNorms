import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

(async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  page.on('console', msg => {
    console.log(`[PAGE CONSOLE ${msg.type()}]:`, msg.text());
  });

  console.log('Navigating to http://localhost:5000/#/admin ...');
  await page.goto('http://localhost:5000/#/admin', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));

  console.log('Current URL:', page.url());
  const html = await page.content();
  console.log('HTML snippet:', html.substring(0, 500));

  const adminSnap = path.join(__dirname, 'evidence', 'smoke', 'test-hash-admin.png');
  await page.screenshot({ path: adminSnap });
  console.log('Saved:', adminSnap, 'size:', fs.statSync(adminSnap).size);

  console.log('Navigating to http://localhost:5000/#/bank ...');
  await page.goto('http://localhost:5000/#/bank', { waitUntil: 'networkidle0', timeout: 30000 });
  await new Promise(r => setTimeout(r, 4000));

  const bankSnap = path.join(__dirname, 'evidence', 'smoke', 'test-hash-bank.png');
  await page.screenshot({ path: bankSnap });
  console.log('Saved:', bankSnap, 'size:', fs.statSync(bankSnap).size);

  await browser.close();
})();

