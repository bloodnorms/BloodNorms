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
  await new Promise(r => setTimeout(r, 3000));

  // Enable semantics
  await page.evaluate(() => {
    const placeholder = document.querySelector('flt-semantics-placeholder');
    if (placeholder) placeholder.click();
  });
  await new Promise(r => setTimeout(r, 2000));

  const semanticNodes = await page.evaluate(() => {
    const nodes = document.querySelectorAll('flt-semantics, [role], [aria-label]');
    return Array.from(nodes).slice(0, 30).map(n => ({
      tagName: n.tagName,
      role: n.getAttribute('role'),
      ariaLabel: n.getAttribute('aria-label'),
      text: n.innerText?.trim(),
    }));
  });

  console.log('Discovered Semantics Nodes count:', semanticNodes.length);
  console.log('Sample Semantic Nodes:', JSON.stringify(semanticNodes.slice(0, 10), null, 2));

  await browser.close();
})();

