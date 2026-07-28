// render-cover.js — Renderiza assets/cover.html em PNG 1600x2560 (padrão KDP).
// Uso: node render-cover.js <input.html> <output.png>
const { chromium } = require('playwright-core');
const CHROME =
  process.env.CHROME_PATH ||
  '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

(async () => {
  const [input, output] = process.argv.slice(2);
  const browser = await chromium.launch({
    executablePath: CHROME,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  const page = await browser.newPage({
    viewport: { width: 1600, height: 2560 },
    deviceScaleFactor: 1,
  });
  await page.goto('file://' + input, { waitUntil: 'networkidle' });
  await page.screenshot({ path: output, clip: { x: 0, y: 0, width: 1600, height: 2560 } });
  await browser.close();
  console.log('  -> ' + output);
})().catch((e) => { console.error(e); process.exit(1); });
