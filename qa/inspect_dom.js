import puppeteer from 'puppeteer-core';

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

(async () => {
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1440, height: 900 });

  await page.goto('http://localhost:5000/#/', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 4000));

  // Check if flutter semantics placeholder exists
  const semantics = await page.evaluate(() => {
    const fltSemantics = document.querySelector('flt-semantics-placeholder');
    const fltGlass = document.querySelector('flt-glass-pane');
    const canvas = document.querySelector('canvas');
    return {
      hasSemanticsPlaceholder: !!fltSemantics,
      hasGlassPane: !!fltGlass,
      hasCanvas: !!canvas,
      bodyChildren: Array.from(document.body.children).map(c => c.tagName),
    };
  });

  console.log('DOM Architecture:', semantics);
  await browser.close();
})();

