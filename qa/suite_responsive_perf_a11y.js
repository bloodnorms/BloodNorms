import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const viewports = [
  { name: 'desktop_1920x1080', width: 1920, height: 1080 },
  { name: 'laptop_1440x900', width: 1440, height: 900 },
  { name: 'tablet_landscape_1024x768', width: 1024, height: 768 },
  { name: 'tablet_portrait_768x1024', width: 768, height: 1024 },
  { name: 'mobile_375x667', width: 375, height: 667 },
];

(async () => {
  console.log('=== Starting Suite 5: Responsive, Performance & Accessibility Audit ===');

  const evidenceDir = path.join(__dirname, 'evidence', 'responsive');
  fs.mkdirSync(evidenceDir, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
  });

  const page = await browser.newPage();

  // 1. Responsive Viewport Audits
  console.log('\n--- 1. Testing Responsive Viewports ---');
  const responsiveFindings = [];

  for (const vp of viewports) {
    console.log(`Setting viewport: ${vp.name} (${vp.width}x${vp.height})...`);
    await page.setViewport({ width: vp.width, height: vp.height });

    // Home
    await page.goto('http://localhost:5000/#/', { waitUntil: 'networkidle0' });
    await new Promise(r => setTimeout(r, 2000));
    const homeShot = path.join(evidenceDir, `home_${vp.name}.png`);
    await page.screenshot({ path: homeShot });

    // Admin Console
    await page.goto('http://localhost:5000/#/admin', { waitUntil: 'networkidle0' });
    await new Promise(r => setTimeout(r, 2000));
    const adminShot = path.join(evidenceDir, `admin_${vp.name}.png`);
    await page.screenshot({ path: adminShot });

    const overflowCheck = await page.evaluate(() => {
      return {
        docScrollWidth: document.documentElement.scrollWidth,
        windowInnerWidth: window.innerWidth,
        hasHorizontalOverflow: document.documentElement.scrollWidth > window.innerWidth,
      };
    });

    console.log(`Viewport ${vp.name} overflow check:`, overflowCheck);
    responsiveFindings.push({
      viewport: vp.name,
      width: vp.width,
      height: vp.height,
      homeScreenshot: `qa/evidence/responsive/home_${vp.name}.png`,
      adminScreenshot: `qa/evidence/responsive/admin_${vp.name}.png`,
      overflowCheck,
    });
  }

  // 2. Performance Metrics
  console.log('\n--- 2. Performance & Timing Metrics ---');
  await page.setViewport({ width: 1440, height: 900 });

  const navStart = Date.now();
  await page.goto('http://localhost:5000/#/', { waitUntil: 'networkidle0' });
  const navEnd = Date.now();

  const performanceTiming = await page.evaluate(() => {
    const perf = window.performance;
    const nav = perf.getEntriesByType('navigation')[0];
    const paint = perf.getEntriesByType('paint');
    return {
      fcp: paint.find(p => p.name === 'first-contentful-paint')?.startTime || null,
      domInteractive: nav?.domInteractive || null,
      domContentLoaded: nav?.domContentLoadedEventEnd || null,
      loadEventEnd: nav?.loadEventEnd || null,
      memory: perf.memory ? {
        jsHeapSizeLimit: perf.memory.jsHeapSizeLimit,
        totalJSHeapSize: perf.memory.totalJSHeapSize,
        usedJSHeapSize: perf.memory.usedJSHeapSize,
      } : null,
    };
  });

  console.log('Performance Metrics:', {
    totalLoadDurationMs: navEnd - navStart,
    timing: performanceTiming,
  });

  // 3. Accessibility Checks
  console.log('\n--- 3. Accessibility & Keyboard Navigation ---');
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));

  const a11ySummary = await page.evaluate(() => {
    const buttons = document.querySelectorAll('flt-semantics[role="button"]');
    const inputs = document.querySelectorAll('input, flt-semantics[role="textbox"]');
    const textNodes = document.querySelectorAll('flt-semantics');
    return {
      interactiveButtonsCount: buttons.length,
      inputControlsCount: inputs.length,
      semanticsNodesTotal: textNodes.length,
      hasAriaLiveRegion: !!document.querySelector('[aria-live]'),
    };
  });
  console.log('Accessibility Structure:', a11ySummary);

  await browser.close();

  fs.writeFileSync(
    path.join(__dirname, 'evidence', 'responsive_perf_results.json'),
    JSON.stringify(
      {
        responsiveFindings,
        performance: {
          totalLoadDurationMs: navEnd - navStart,
          timing: performanceTiming,
        },
        accessibility: a11ySummary,
      },
      null,
      2
    )
  );

  console.log('\n=== Suite 5 Complete! Results saved to qa/evidence/responsive_perf_results.json ===');
})();

