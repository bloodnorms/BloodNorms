import fs from 'fs';
import path from 'path';
import http from 'http';
import { fileURLToPath } from 'url';
import puppeteer from 'puppeteer-core';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const results = {
  timestamp: new Date().toISOString(),
  secretsLeak: {},
  voiceGateway: {},
  inputHazards: {},
  formulaInjection: {},
  governance: {},
};

(async () => {
  console.log('=== Starting Suite 4: Security Testing & Attack Mindset Audit ===');

  // 1. Audit Client Bundle for Secret Leaks
  console.log('\n--- 1. Secret Leak Audit (RSK-01 / BUG-001) ---');
  const webBuildDir = path.join(__dirname, '..', 'build', 'web');
  const assetsEnvPath = path.join(__dirname, '..', 'assets', '.env');
  const bundledAssetPath1 = path.join(webBuildDir, 'assets', 'assets', '.env');
  const bundledAssetPath2 = path.join(webBuildDir, 'assets', '.env');

  const assetsEnvExists = fs.existsSync(assetsEnvPath);
  const bundled1Exists = fs.existsSync(bundledAssetPath1);
  const bundled2Exists = fs.existsSync(bundledAssetPath2);

  results.secretsLeak.assetsEnvExists = assetsEnvExists;
  results.secretsLeak.bundledInBuildWeb_assets_assets = bundled1Exists;
  results.secretsLeak.bundledInBuildWeb_assets = bundled2Exists;

  console.log('assets/.env exists in repo:', assetsEnvExists);
  console.log('bundled into build/web/assets/assets/.env:', bundled1Exists);
  console.log('bundled into build/web/assets/.env:', bundled2Exists);

  if (bundled1Exists || bundled2Exists) {
    const leakedContent = fs.readFileSync(bundled1Exists ? bundledAssetPath1 : bundledAssetPath2, 'utf8');
    const hasServiceRole = leakedContent.includes('SUPABASE_SERVICE_ROLE_KEY');
    const hasJwtSecret = leakedContent.includes('SUPABASE_JWT_SECRET');
    const hasGeminiKey = leakedContent.includes('GEMINI_API_KEY');
    const hasWaToken = leakedContent.includes('WHATSAPP_SYSTEM_ACCESS_TOKEN');

    results.secretsLeak.leakedVariables = {
      SUPABASE_SERVICE_ROLE_KEY: hasServiceRole,
      SUPABASE_JWT_SECRET: hasJwtSecret,
      GEMINI_API_KEY: hasGeminiKey,
      WHATSAPP_SYSTEM_ACCESS_TOKEN: hasWaToken,
    };

    console.log('CRITICAL ALERT: Secrets bundled into client web build assets!');
    console.log('Leaked Keys Detected:', results.secretsLeak.leakedVariables);
  }

  // Check HTTP access to .env via web server
  const checkHttpAsset = urlPath => {
    return new Promise(resolve => {
      http.get(`http://localhost:5000/${urlPath}`, res => {
        let body = '';
        res.on('data', d => (body += d));
        res.on('end', () => {
          resolve({ status: res.statusCode, length: body.length, isSecret: body.includes('SUPABASE_SERVICE_ROLE_KEY') });
        });
      }).on('error', e => resolve({ error: e.message }));
    });
  };

  const httpCheck1 = await checkHttpAsset('assets/assets/.env');
  const httpCheck2 = await checkHttpAsset('assets/.env');
  console.log('HTTP access to /assets/assets/.env:', httpCheck1);
  console.log('HTTP access to /assets/.env:', httpCheck2);
  results.secretsLeak.httpAccessAssetsAssets = httpCheck1;
  results.secretsLeak.httpAccessAssets = httpCheck2;

  // 2. Voice Gateway Security & Health Check
  console.log('\n--- 2. Voice Gateway Health & Endpoints ---');
  const vgHealth = await new Promise(resolve => {
    http.get('http://localhost:8080/health', res => {
      let data = '';
      res.on('data', d => (data += d));
      res.on('end', () => {
        resolve({ status: res.statusCode, body: data, headers: res.headers });
      });
    }).on('error', e => resolve({ error: e.message }));
  });
  console.log('Voice Gateway /health response:', vgHealth);
  results.voiceGateway.health = vgHealth;

  // 3. Formula Injection in CSV Export
  console.log('\n--- 3. CSV Formula Injection Audit ---');
  const dataExportFile = path.join(__dirname, '..', 'lib', 'features', 'admin_console', 'widgets', 'data_exports_view.dart');
  if (fs.existsSync(dataExportFile)) {
    const code = fs.readFileSync(dataExportFile, 'utf8');
    // Check if formula characters (=, +, -, @) are escaped or prefixed with single quote
    const sanitizesFormulas = code.includes("startsWith('=')") || code.includes("replaceFirst('=',") || code.includes("sanitize") || code.includes("quote");
    results.formulaInjection = {
      file: 'lib/features/admin_console/widgets/data_exports_view.dart',
      hasSanitization: sanitizesFormulas,
      finding: sanitizesFormulas ? 'Sanitization logic present' : 'Vulnerable to CSV Formula Injection (=, +, -, @ not escaped with tab or quote)',
    };
    console.log('CSV Formula Injection Status:', results.formulaInjection);
  }

  // 4. Form Hazards: XSS and SQLi Attack Testing via Real Browser
  console.log('\n--- 4. Form Hazards & XSS / SQLi Payloads ---');
  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1440,900'],
  });

  const page = await browser.newPage();
  let dialogTriggered = false;
  let dialogMessage = '';
  page.on('dialog', async dialog => {
    dialogTriggered = true;
    dialogMessage = dialog.message();
    console.log(`[ALERT/DIALOG INTERCEPTED]: ${dialog.type()} "${dialog.message()}"`);
    await dialog.dismiss();
  });

  await page.goto('http://localhost:5000/#/details', { waitUntil: 'networkidle0' });
  await new Promise(r => setTimeout(r, 3000));
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1000));

  // Inject attack payloads into input fields
  const xssPayload = '<script>alert("QA_XSS")</script><img src=x onerror=alert("QA_IMG_XSS")>';
  const sqliPayload = "' OR '1'='1' --";

  const inputsDiscovered = await page.evaluate((xss, sqli) => {
    const inputs = Array.from(document.querySelectorAll('input'));
    if (inputs.length >= 2) {
      inputs[0].value = xss;
      inputs[0].dispatchEvent(new Event('input', { bubbles: true }));
      inputs[1].value = sqli;
      inputs[1].dispatchEvent(new Event('input', { bubbles: true }));
      return { count: inputs.length, injected: true };
    }
    return { count: inputs.length, injected: false };
  }, xssPayload, sqliPayload);

  console.log('Payload Injection Result:', inputsDiscovered);
  await new Promise(r => setTimeout(r, 2000));

  const evidenceDir = path.join(__dirname, 'evidence', 'security');
  fs.mkdirSync(evidenceDir, { recursive: true });
  await page.screenshot({ path: path.join(evidenceDir, 'sec_01_payload_inputs.png') });

  results.inputHazards = {
    xssPayload,
    sqliPayload,
    dialogTriggered,
    dialogMessage,
    sanitizedInDOM: !dialogTriggered,
    screenshot: 'qa/evidence/security/sec_01_payload_inputs.png',
  };

  // 5. Audit Four-Eyes Governance Separation
  console.log('\n--- 5. Four-Eyes Governance Separation Check ---');
  const controllerFile = path.join(__dirname, '..', 'lib', 'features', 'admin_console', 'controllers', 'admin_console_controller.dart');
  if (fs.existsSync(controllerFile)) {
    const code = fs.readFileSync(controllerFile, 'utf8');
    const enforcesFourEyes = code.includes('requires_approval') || code.includes('> 200') || code.includes('eligible_count');
    results.governance = {
      fourEyesThresholdEnforced: enforcesFourEyes,
      makerCheckerSeparation: code.includes('maker_id') || code.includes('checker_id') || code.includes('requires_approval'),
    };
    console.log('Governance Check Status:', results.governance);
  }

  await browser.close();

  fs.writeFileSync(
    path.join(__dirname, 'evidence', 'security_audit_results.json'),
    JSON.stringify(results, null, 2)
  );

  console.log('\n=== Suite 4 Finished! Evidence saved to qa/evidence/security_audit_results.json ===');
})();

