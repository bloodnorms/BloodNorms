import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const routes = [
  { path: '#/', name: '01_home', title: 'Home / Requester Landing' },
  { path: '#/group', name: '02_group', title: 'Blood Group Selection' },
  { path: '#/units', name: '03_units', title: 'Units & Urgency' },
  { path: '#/location', name: '04_location', title: 'Location Picker' },
  { path: '#/banks', name: '05_banks_requester', title: 'Requester Banks Matching' },
  { path: '#/details', name: '06_details', title: 'Patient Details Form' },
  { path: '#/review', name: '07_review', title: 'Review & Send Request' },
  { path: '#/live/QA_20261107_REQ_01', name: '08_live_tracking', title: 'Live Request Tracking' },
  { path: '#/b', name: '09_public_banks', title: 'Public Banks Directory' },
  { path: '#/donor', name: '10_donor_home', title: 'Donor Home & Pass' },
  { path: '#/donor/onboarding', name: '11_donor_onboarding', title: 'Donor Onboarding Form' },
  { path: '#/donor/ticket/QA_20261107_REQ_01', name: '12_donor_ticket', title: 'Donor Response Ticket' },
  { path: '#/bank', name: '13_bank_console', title: 'Blood Bank Staff Console' },
  { path: '#/admin', name: '14_admin_console', title: 'Admin Command Center' },
];

(async () => {
  console.log('=== Starting Suite 1: Full Route Crawl & Evidence Capture ===');

  const evidenceDir = path.join(__dirname, 'evidence', 'routes');
  fs.mkdirSync(evidenceDir, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  const crawlResults = [];

  for (const route of routes) {
    const fullUrl = `http://localhost:5000/${route.path}`;
    console.log(`\nNavigating to ${route.title} (${fullUrl}) ...`);

    const consoleMessages = [];
    const failedRequests = [];

    const consoleHandler = msg => {
      consoleMessages.push({ type: msg.type(), text: msg.text() });
    };
    const reqFailHandler = req => {
      failedRequests.push({
        url: req.url(),
        error: req.failure() ? req.failure().errorText : 'failed',
      });
    };

    page.on('console', consoleHandler);
    page.on('requestfailed', reqFailHandler);

    const startTime = Date.now();
    let status = 200;
    try {
      const resp = await page.goto(fullUrl, { waitUntil: 'networkidle0', timeout: 20000 });
      if (resp) status = resp.status();
    } catch (e) {
      console.log(`Navigation notice for ${route.name}: ${e.message}`);
    }

    // Give Flutter 2.5s to render
    await new Promise(r => setTimeout(r, 2500));

    // Enable semantics to inspect accessibility
    try {
      await page.evaluate(() => {
        const ph = document.querySelector('flt-semantics-placeholder');
        if (ph) ph.click();
      });
      await new Promise(r => setTimeout(r, 1000));
    } catch (_) {}

    const durationMs = Date.now() - startTime;
    const screenshotPath = path.join(evidenceDir, `${route.name}.png`);
    await page.screenshot({ path: screenshotPath });

    const semanticText = await page.evaluate(() => {
      const nodes = Array.from(document.querySelectorAll('flt-semantics'));
      return nodes.map(n => n.innerText?.trim()).filter(Boolean).slice(0, 10);
    });

    console.log(`[OK] Captured ${route.name}.png (${fs.statSync(screenshotPath).size} bytes, ${durationMs}ms)`);
    console.log(`Sample rendered text: ${semanticText[0]?.substring(0, 80) || 'None'}`);

    crawlResults.push({
      route: route.path,
      name: route.name,
      title: route.title,
      status,
      durationMs,
      screenshot: `qa/evidence/routes/${route.name}.png`,
      consoleErrors: consoleMessages.filter(m => m.type === 'error'),
      failedRequests,
    });

    page.off('console', consoleHandler);
    page.off('requestfailed', reqFailHandler);
  }

  await browser.close();

  fs.writeFileSync(
    path.join(__dirname, 'evidence', 'route_crawl_results.json'),
    JSON.stringify(crawlResults, null, 2)
  );

  console.log('\n=== Suite 1 Finished Successfully! Results saved to qa/evidence/route_crawl_results.json ===');
})();

