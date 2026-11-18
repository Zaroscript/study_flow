/* Loads the landing copy (the `copy` object literal) straight from Landing.tsx so static SEO content, the social
 * cards and the regression check can never drift from what the page shows. The literal is plain JS (no TS syntax),
 * so it is evaluated in an isolated vm context. Build-time/dev-time only. */
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');

function loadCopy(file = path.resolve(__dirname, '..', '..', 'Landing.tsx')) {
  const source = fs.readFileSync(file, 'utf8');
  const start = source.indexOf('const copy = {');
  const end = source.indexOf('\nfunction Phone', start);
  if (start < 0 || end < 0) throw new Error('landing-copy: could not locate `const copy = {...};` in Landing.tsx');
  const literal = source.slice(start + 'const copy = '.length, end).trim().replace(/;$/, '');
  const copy = vm.runInNewContext(`(${literal})`, Object.create(null), { timeout: 2000 });
  for (const lang of ['ar', 'en']) {
    if (!copy[lang] || !Array.isArray(copy[lang].faqs) || !Array.isArray(copy[lang].headline)) throw new Error(`landing-copy: copy.${lang} is missing expected fields`);
  }
  return copy;
}
module.exports = { loadCopy };
