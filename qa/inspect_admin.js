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

  await page.goto('http://localhost:5000/#/admin', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3500));

  // Enable semantics
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1500));

  const items = await page.evaluate(() => {
    const all = Array.from(document.querySelectorAll('flt-semantics'));
    return all.map((el, i) => ({
      index: i,
      role: el.getAttribute('role'),
      text: el.innerText?.trim()?.replace(/\n/g, ' | '),
    })).filter(x => x.text && x.text.length < 100);
  });

  console.log('Sidebar & Admin Elements:', JSON.stringify(items.slice(0, 40), null, 2));

  await browser.close();
})();

