/* Landing regression check against the production build (dist/): run `pnpm build` first.
 * Covers: ?lang=en, no auto-scroll on first visit, download button only for a valid
 * release manifest pointing at the official GitHub release, no horizontal overflow. */
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const { spawn } = require('node:child_process');
const { createRequire } = require('node:module');
const root = path.resolve(__dirname, '..');
let playwright;
try { playwright = require('playwright'); } catch {
  playwright = createRequire(path.join(os.homedir(), '.cache/codex-runtimes/codex-primary-runtime/dependencies/node/package.json'))('playwright');
}
const PORT = Number(process.env.ENOTE_LANDING_PORT || 4173);
const base = `http://127.0.0.1:${PORT}`;
const sha = 'a'.repeat(64);
const validManifest = {
  available: true, version: '1.0.0', sha256: sha, sizeBytes: 52428800,
  apkUrl: 'https://github.com/Zaroscript/study_flow/releases/download/v1.0.0/ENote-1.0.0.apk',
};

async function waitForServer() {
  for (let i = 0; i < 60; i++) {
    try { if ((await fetch(base)).ok) return; } catch {}
    await new Promise((r) => setTimeout(r, 500));
  }
  throw new Error('preview server did not start');
}

async function run() {
  const vite = path.join(root, 'node_modules/vite/bin/vite.js');
  const server = spawn(process.execPath, [vite, 'preview', '--port', String(PORT), '--host', '127.0.0.1', '--strictPort'], { cwd: root, stdio: 'ignore' });
  let browser;
  try {
    await waitForServer();
    const cached = path.join(os.homedir(), 'AppData/Local/ms-playwright');
    const folders = await fs.readdir(cached).catch(() => []);
    const candidates = folders.filter((n) => /^chromium-\d+$/.test(n)).sort().reverse();
    const executablePath = process.env.ENOTE_BROWSER_PATH || (candidates[0] && path.join(cached, candidates[0], 'chrome-win/chrome.exe'));
    browser = await playwright.chromium.launch({ headless: true, ...(executablePath ? { executablePath } : {}) });

    const open = async (url, manifest, viewport = { width: 1440, height: 900 }) => {
      const context = await browser.newContext({ viewport });
      const page = await context.newPage();
      const errors = [];
      page.on('pageerror', (e) => errors.push(e.message));
      await page.route('**/release.json', (route) => manifest === undefined
        ? route.fulfill({ status: 404, contentType: 'text/html', body: 'not found' })
        : route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(manifest) }));
      await page.goto(url, { waitUntil: 'networkidle' });
      await page.waitForTimeout(1500);
      return { context, page, errors };
    };

    // 1. English via query, first visit does not scroll away from the hero.
    {
      const { context, page, errors } = await open(`${base}/?lang=en`, undefined);
      assert.equal(await page.locator('html').getAttribute('lang'), 'en');
      assert.equal(await page.locator('html').getAttribute('dir'), 'ltr');
      assert.ok((await page.evaluate(() => scrollY)) < 50, 'page must start at the top');
      assert.equal(await page.getByRole('link', { name: /Download for Android/ }).count(), 0, 'no download without a manifest');
      assert.deepEqual(errors, []);
      await context.close();
      console.log('PASS ?lang=en, starts at hero, no download without manifest');
    }

    // 2. Valid manifest shows the official download link in both CTAs.
    {
      const { context, page } = await open(`${base}/?lang=en`, validManifest);
      const links = page.getByRole('link', { name: /Download for Android \(52\.4 MB\)/ });
      assert.equal(await links.count(), 2);
      assert.equal(await links.first().getAttribute('href'), validManifest.apkUrl);
      await context.close();
      console.log('PASS valid manifest shows official download link');
    }

    // 3. Untrusted / malformed manifests must never produce a link.
    for (const [label, manifest] of [
      ['foreign host', { ...validManifest, apkUrl: 'https://evil.example/ENote-1.0.0.apk' }],
      ['wrong repo', { ...validManifest, apkUrl: 'https://github.com/someone/else/releases/download/v1.0.0/ENote-1.0.0.apk' }],
      ['not available', { ...validManifest, available: false }],
      ['bad sha', { ...validManifest, sha256: 'xyz' }],
      ['bad version', { ...validManifest, version: '1.0' }],
      ['http scheme', { ...validManifest, apkUrl: 'http://github.com/Zaroscript/study_flow/releases/download/v1.0.0/ENote-1.0.0.apk' }],
      ['javascript scheme', { ...validManifest, apkUrl: 'javascript:alert(1)//github.com/Zaroscript/study_flow/releases/download/v1.0.0/ENote.apk' }],
      ['lookalike host', { ...validManifest, apkUrl: 'https://github.com.evil.example/Zaroscript/study_flow/releases/download/v1.0.0/ENote-1.0.0.apk' }],
      ['dot-dot tag', { ...validManifest, apkUrl: 'https://github.com/Zaroscript/study_flow/releases/download/../../../evil/ENote-1.0.0.apk' }],
      ['query string', { ...validManifest, apkUrl: validManifest.apkUrl + '?x=1' }],
    ]) {
      const { context, page } = await open(`${base}/`, manifest);
      assert.equal(await page.getByRole('link', { name: /Download for Android|تنزيل لأندرويد/ }).count(), 0, label);
      await context.close();
    }
    console.log('PASS untrusted manifests rejected');

    // 4. Arabic + no horizontal overflow at small widths with the button present.
    for (const width of [320, 390, 820]) {
      const { context, page } = await open(`${base}/?lang=ar`, validManifest, { width, height: 800 });
      assert.equal(await page.locator('html').getAttribute('lang'), 'ar');
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      assert.ok(overflow <= 0, `horizontal overflow ${overflow}px at ${width}`);
      await context.close();
    }
    console.log('PASS no horizontal overflow (ar, 320/390/820)');
  } finally {
    await browser?.close();
    server.kill();
  }
}
run().catch((e) => { console.error(e); process.exit(1); });
