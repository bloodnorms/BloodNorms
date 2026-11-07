import puppeteer from 'puppeteer-core';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const CHROME_PATH = 'C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe';

const workspaces = [
  { id: 'dashboard', label: 'Dashboard Cockpit' },
  { id: 'crisis_radar', label: 'Live Crisis Radar' },
  { id: 'needs_human', label: 'Needs Human Queue' },
  // Broadcast Center
  { id: 'broadcast_dispatch', label: 'Dispatch Broadcaster' },
  { id: 'broadcast_audience', label: 'Audience & Geofence' },
  { id: 'broadcast_history', label: 'Campaign History' },
  // AI Voice Studio
  { id: 'voice_simulator', label: 'Voice Simulator Sandbox' },
  { id: 'voice_prompts', label: 'Prompts & Guardrails' },
  { id: 'voice_safety', label: 'Safety Cap & Minutes' },
  // WhatsApp Comms Hub
  { id: 'whatsapp_bot', label: 'Live Assistant Bot' },
  { id: 'whatsapp_templates', label: 'Template Chat Preview' },
  { id: 'whatsapp_telecom', label: 'Telecom Rate Cards' },
  // Blood Camps & Drives
  { id: 'camps_list', label: 'Scheduled Drives' },
  { id: 'camps_create', label: 'Schedule New Drive' },
  // Blood Centers & Stock
  { id: 'banks_directory', label: 'Connected Centers' },
  { id: 'banks_stock', label: '8-Group Stock Matrix' },
  // Donors Registry
  { id: 'donors_list', label: 'Donors Directory' },
  { id: 'donors_location', label: 'Location & Travel Caps' },
  // Hospitals & Shield
  { id: 'hospitals_list', label: 'Verified Hospitals' },
  { id: 'requester_shield', label: 'Requester Abuse Shield' },
  { id: 'community_partners', label: 'Community Partners & NGOs' },
  // Governance & Desk
  { id: 'approvals_queue', label: 'Four-Eyes Approvals' },
  { id: 'data_exports', label: 'Data Exports Engine' },
  { id: 'dpdp_registry', label: 'DPDP Privacy & Erasures' },
  // Platform Settings
  { id: 'settings_killswitch', label: 'Master Platform Killswitch' },
  { id: 'settings_algorithm', label: 'Search Ring Parameters' },
  { id: 'settings_safety', label: 'Clinical Safety Desk' },
  { id: 'settings_audit', label: 'Immutable Audit Logs' },
];

(async () => {
  console.log('=== Starting Suite 2: Admin Workspaces Deep-Dive ===');

  const evidenceDir = path.join(__dirname, 'evidence', 'admin');
  fs.mkdirSync(evidenceDir, { recursive: true });

  const browser = await puppeteer.launch({
    executablePath: CHROME_PATH,
    headless: true,
    args: ['--no-sandbox', '--disable-setuid-sandbox', '--window-size=1600,1000'],
  });

  const page = await browser.newPage();
  await page.setViewport({ width: 1600, height: 1000 });

  const consoleLogs = [];
  const networkErrors = [];

  page.on('console', msg => {
    consoleLogs.push({ type: msg.type(), text: msg.text() });
  });

  page.on('requestfailed', req => {
    networkErrors.push({
      url: req.url(),
      error: req.failure() ? req.failure().errorText : 'failed',
    });
  });

  console.log('Opening http://localhost:5000/#/admin ...');
  await page.goto('http://localhost:5000/#/admin', { waitUntil: 'networkidle0', timeout: 25000 });
  await new Promise(r => setTimeout(r, 4000));

  // Enable semantics
  await page.evaluate(() => {
    const ph = document.querySelector('flt-semantics-placeholder');
    if (ph) ph.click();
  });
  await new Promise(r => setTimeout(r, 1500));

  const workspaceResults = [];

  for (let i = 0; i < workspaces.length; i++) {
    const ws = workspaces[i];
    console.log(`\nTesting Workspace [${i + 1}/${workspaces.length}]: ${ws.label} (${ws.id})`);

    // Click matching semantic button
    const clicked = await page.evaluate(targetLabel => {
      // Find all buttons whose text starts with or includes targetLabel
      const buttons = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
      const match = buttons.find(b => b.innerText && b.innerText.includes(targetLabel));
      if (match) {
        match.click();
        return true;
      }
      // If not expanded, try clicking the parent category or scroll down
      return false;
    }, ws.label);

    if (!clicked) {
      console.log(`Could not find direct button for "${ws.label}". Expanding categories or scrolling...`);
      // Scroll sidebar list
      await page.evaluate(() => {
        const list = document.querySelector('flt-semantics[role="group"]');
        if (list) list.scrollTop += 300;
      });
      await new Promise(r => setTimeout(r, 500));

      // Try again
      await page.evaluate(targetLabel => {
        const buttons = Array.from(document.querySelectorAll('flt-semantics[role="button"]'));
        const match = buttons.find(b => b.innerText && b.innerText.includes(targetLabel));
        if (match) match.click();
      }, ws.label);
    }

    // Wait for view to transition and render
    await new Promise(r => setTimeout(r, 2000));

    const shotFile = `admin_${String(i + 1).padStart(2, '0')}_${ws.id}.png`;
    const shotPath = path.join(evidenceDir, shotFile);
    await page.screenshot({ path: shotPath });

    const size = fs.statSync(shotPath).size;
    console.log(`Captured ${shotFile} (${size} bytes)`);

    workspaceResults.push({
      index: i + 1,
      id: ws.id,
      label: ws.label,
      screenshot: `qa/evidence/admin/${shotFile}`,
      fileSize: size,
      success: size > 20000,
    });
  }

  await browser.close();

  fs.writeFileSync(
    path.join(__dirname, 'evidence', 'admin_workspaces_results.json'),
    JSON.stringify(
      {
        total: workspaces.length,
        workspaces: workspaceResults,
        consoleErrors: consoleLogs.filter(c => c.type === 'error'),
        networkErrors,
      },
      null,
      2
    )
  );

  console.log('\n=== Suite 2 Complete! Results saved to qa/evidence/admin_workspaces_results.json ===');
})();

