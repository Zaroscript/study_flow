/* One-off asset generator for the landing's SEO/social images (NOT part of the Vercel build:
 * Vercel has no Chromium). Re-run after changing the icon or the headline copy, then commit the PNGs.
 *   node scripts/make-seo-assets.cjs
 * Needs `sharp` (NOT a declared dependency: install it temporarily, e.g. `pnpm add -D sharp --no-save`) and the repo's `playwright`
 * with a Chromium (ENOTE_BROWSER_PATH or the cached playwright chromium, same lookup as check-landing.cjs).
 * Outputs: public/assets/icons/*.png (favicon/apple-touch/manifest icons), public/assets/og-enote-{ar,en}.png (1200x630). */
const fs = require('node:fs');
const path = require('node:path');
let sharp;
try { sharp = require('sharp'); } catch { console.error('make-seo-assets needs the dev-only package `sharp` (not a project dependency): run `pnpm add -D sharp --no-save` or install it temporarily, then re-run.'); process.exit(1); }
const { loadCopy } = require('./lib/landing-copy.cjs');

const root = path.resolve(__dirname, '..');
const source = path.join(root, 'public', 'assets', 'enote-icon.png');
const iconDir = path.join(root, 'public', 'assets', 'icons');
const fontDir = path.join(root, 'public', 'assets', 'fonts');

async function makeIcons() {
  fs.mkdirSync(iconDir, { recursive: true });
  // The source has a light 1-5px rim and rounded corners; an inset crop gives a clean opaque navy square.
  const plate = await sharp(source).extract({ left: 80, top: 80, width: 864, height: 864 }).toBuffer();
  const write = (name, buffer) => sharp(buffer).png({ compressionLevel: 9, palette: true, quality: 95, effort: 10 }).toFile(path.join(iconDir, name));
  for (const size of [48, 96, 192, 512]) await write(`icon-${size}.png`, await sharp(plate).resize(size, size).toBuffer());
  await write('apple-touch-icon.png', await sharp(plate).resize(180, 180).toBuffer()); // opaque: iOS applies its own mask
  // Maskable: the artwork must live inside the central 80% safe zone, on a bleed that survives any mask shape.
  const size = 512;
  const art = Math.round(size * 0.7);
  const feather = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${art}" height="${art}"><rect x="${art * 0.06}" y="${art * 0.06}" width="${art * 0.88}" height="${art * 0.88}" rx="${art * 0.12}" fill="#fff"/><filter id="b"><feGaussianBlur stdDeviation="${art * 0.03}"/></filter></svg>`.replace('fill="#fff"/>', 'fill="#fff" filter="url(#b)"/>'));
  const mask = await sharp(feather).resize(art, art).ensureAlpha().extractChannel(3).toBuffer();
  const { channels } = await sharp(await sharp(plate).extract({ left: 0, top: 250, width: 40, height: 360 }).toBuffer()).stats();
  const bg = await sharp({ create: { width: size, height: size, channels: 3, background: { r: Math.round(channels[0].mean), g: Math.round(channels[1].mean), b: Math.round(channels[2].mean) } } }).png().toBuffer();
  const foreground = await sharp(plate).resize(art, art).joinChannel(mask).png().toBuffer();
  const offset = Math.round((size - art) / 2);
  await write('icon-maskable-512.png', await sharp(bg).composite([{ input: foreground, left: offset, top: offset }]).toBuffer());
}

async function makeCards() {
  const { chromium } = require('playwright');
  const cacheRoot = path.join(process.env.LOCALAPPDATA || '', 'ms-playwright');
  let executablePath = process.env.ENOTE_BROWSER_PATH;
  if (!executablePath && fs.existsSync(cacheRoot)) {
    const dir = fs.readdirSync(cacheRoot).filter((d) => /^chromium-\d+$/.test(d)).sort().pop();
    if (dir) executablePath = path.join(cacheRoot, dir, 'chrome-win', 'chrome.exe');
  }
  const browser = await chromium.launch({ headless: true, ...(executablePath && fs.existsSync(executablePath) ? { executablePath } : {}) });
  const copy = loadCopy();
  const cards = {
    ar: { dir: 'rtl', lang: 'ar', font: 'Cairo', a: copy.ar.headline[0], b: copy.ar.headline[1], sub: 'تطبيق أندرويد للملاحظات وخطط المذاكرة', tags: ['ملاحظات', 'خطط', 'بومودورو 3D', 'مكافآت'] },
    en: { dir: 'ltr', lang: 'en', font: 'Manrope', a: copy.en.headline[0], b: copy.en.headline[1], sub: 'An Android app for notes, study plans and a 3D flip-clock Pomodoro timer', tags: ['Notes', 'Plans', '3D Pomodoro', 'Rewards'] },
  };
  const iconUri = `data:image/png;base64,${fs.readFileSync(path.join(iconDir, 'icon-512.png')).toString('base64')}`;
  const fontUri = (file) => `data:font/ttf;base64,${fs.readFileSync(path.join(fontDir, file)).toString('base64')}`;
  for (const [key, c] of Object.entries(cards)) {
    const page = await browser.newPage({ viewport: { width: 1200, height: 630 }, deviceScaleFactor: 1 });
    await page.setContent(`<!doctype html><html lang="${c.lang}" dir="${c.dir}"><meta charset="utf-8"><style>
      @font-face{font-family:Cairo;src:url(${fontUri('Cairo.ttf')});font-weight:200 1000}
      @font-face{font-family:Manrope;src:url(${fontUri('Manrope.ttf')});font-weight:200 800}
      *{box-sizing:border-box;margin:0}
      body{width:1200px;height:630px;overflow:hidden;font-family:${c.font},sans-serif;color:#f7f9ff;
        background:radial-gradient(900px 520px at 85% 15%,rgba(47,133,246,.32),transparent 60%),radial-gradient(700px 420px at 10% 100%,rgba(255,178,63,.20),transparent 60%),#071a34;
        display:flex;align-items:center;justify-content:space-between;padding:0 84px;gap:56px}
      .copy{flex:1}
      .brand{direction:ltr;text-align:${key === 'ar' ? 'right' : 'left'};font:800 34px/1 Manrope,sans-serif;letter-spacing:.01em;margin-bottom:28px;color:#b2c2d7}
      .brand i{font-style:normal;color:#ffb23f}
      h1{font-weight:800;font-size:${key === 'ar' ? 74 : 88}px;line-height:${key === 'ar' ? 1.35 : 1.08};letter-spacing:${key === 'ar' ? 0 : '-.025em'}}
      h1 span{display:block;color:#ffb23f}
      p{margin-top:26px;font-size:${key === 'ar' ? 27 : 30}px;line-height:1.5;color:#b2c2d7;font-weight:500;max-width:640px}
      .tags{display:flex;gap:12px;margin-top:34px;flex-wrap:wrap}
      .tags b{font-size:22px;font-weight:700;padding:8px 20px;border-radius:999px;border:2px solid rgba(178,194,215,.35);color:#f7f9ff}
      img{width:330px;height:330px;border-radius:76px;box-shadow:0 30px 80px rgba(0,0,0,.45),0 0 0 2px rgba(255,255,255,.08)}
    </style><body><div class="copy"><div class="brand">ENote<i>.</i></div><h1>${c.a}<span>${c.b}</span></h1><p>${c.sub}</p><div class="tags">${c.tags.map((t) => `<b>${t}</b>`).join('')}</div></div><img src="${iconUri}" width="330" height="330" alt=""></body></html>`);
    await page.evaluate(() => document.fonts.ready);
    const shot = await page.screenshot({ type: 'png' });
    await sharp(shot).png({ compressionLevel: 9, palette: true, quality: 90, effort: 10, dither: 1 }).toFile(path.join(root, 'public', 'assets', `og-enote-${key}.png`));
    await page.close();
  }
  await browser.close();
}

(async () => {
  await makeIcons();
  console.log('OK icons written to public/assets/icons');
  await makeCards();
  console.log('OK social cards written to public/assets/og-enote-{ar,en}.png');
})().catch((e) => { console.error(e); process.exit(1); });
