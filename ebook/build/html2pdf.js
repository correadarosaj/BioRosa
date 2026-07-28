// html2pdf.js — Renderiza um HTML em PDF usando o Chromium pré-instalado.
// Uso: node html2pdf.js <input.html> <output.pdf>
const { chromium } = require('playwright-core');

const CHROME =
  process.env.CHROME_PATH ||
  '/opt/pw-browsers/chromium-1194/chrome-linux/chrome';

(async () => {
  const [input, output] = process.argv.slice(2);
  if (!input || !output) {
    console.error('Uso: node html2pdf.js <input.html> <output.pdf>');
    process.exit(1);
  }

  const browser = await chromium.launch({
    executablePath: CHROME,
    args: ['--no-sandbox', '--disable-dev-shm-usage'],
  });
  const page = await browser.newPage();
  await page.goto('file://' + input, { waitUntil: 'networkidle' });

  await page.pdf({
    path: output,
    format: 'A5', // sobrescrito por preferCSSPageSize
    preferCSSPageSize: true, // usa @page do print.css (6in x 9in)
    printBackground: true,
    displayHeaderFooter: true,
    headerTemplate: '<span></span>',
    footerTemplate:
      '<div style="width:100%;font-size:8px;color:#888;text-align:center;font-family:sans-serif;">' +
      '<span class="pageNumber"></span></div>',
    margin: { top: '2cm', bottom: '2cm', left: '1.8cm', right: '1.8cm' },
  });

  await browser.close();
  console.log('  -> ' + output);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
