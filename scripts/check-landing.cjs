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

    const open = async (url, manifest, viewport = { width: 1440, height: 900 }, options = {}) => {
      const context = await browser.newContext({ viewport, ...options });
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
      // The closing CTA reveals on scroll (GSAP), so count by DOM rather than by visibility.
      const links = page.locator('a[download]').filter({ hasText: 'Download for Android' });
      assert.equal(await links.count(), 2);
      assert.equal(await links.first().getAttribute('href'), validManifest.apkUrl);
      await context.close();
      console.log('PASS valid manifest shows official download link');
    }

    // 2b. "Get ENote" section: 3 install steps, no fingerprint UI, download is the primary hero action.
    {
      const { context, page } = await open(`${base}/?lang=en`, validManifest);
      const section = page.locator('#get');
      await section.scrollIntoViewIfNeeded();
      assert.ok(!(await section.textContent()).includes(sha), 'the fingerprint is not shown on the page (it lives in the release notes)');
      assert.equal(await section.locator('code, button').count(), 0, 'no fingerprint or copy UI');
      assert.equal(await section.locator('ol li').count(), 3, 'three install steps');
      assert.equal(await section.getByRole('link', { name: 'Download the APK' }).getAttribute('href'), validManifest.apkUrl);
      const firstAction = page.locator('.lp-hero-actions a').first();
      assert.match(await firstAction.innerText(), /Download for Android/, 'download is the first (primary) hero action');
      assert.equal(await page.locator('.lp-nav-cta').getAttribute('href'), validManifest.apkUrl, 'header CTA downloads');
      await context.close();
      console.log('PASS get section (steps, primary download, no fingerprint UI)');
    }

    // 2c. Without a manifest: honest "in preparation" state, anchor CTAs, no hash UI.
    {
      const { context, page } = await open(`${base}/?lang=en`, undefined);
      const section = page.locator('#get');
      assert.match(await section.innerText(), /in preparation/i);
      assert.equal(await section.locator('code').count(), 0);
      const first = page.locator('.lp-hero-actions a').first();
      assert.match(await first.innerText(), /Get ENote/);
      assert.equal(await first.getAttribute('href'), '#get');
      assert.equal(await page.locator('.lp-nav-cta').getAttribute('href'), '#get');
      await context.close();
      console.log('PASS no-release state');
    }

    // 2e. The web app is no longer offered anywhere on the landing (links or copy), in both states and languages.
    for (const [lang, manifest] of [['ar', validManifest], ['en', validManifest], ['ar', undefined], ['en', undefined]]) {
      const { context, page } = await open(`${base}/?lang=${lang}`, manifest);
      assert.equal(await page.locator('a[href="/app"]').count(), 0, `no /app link (${lang})`);
      const text = await page.evaluate(() => document.body.textContent);
      assert.doesNotMatch(text, /web app|نسخة الويب|تطبيق الويب/i, `no web-app copy (${lang})`);
      await context.close();
    }
    console.log('PASS web app removed from links and copy');

    // 2f. Team section + every nav link points at a real section.
    for (const lang of ['ar', 'en']) {
      const { context, page } = await open(`${base}/?lang=${lang}`, undefined);
      const team = page.locator('#team');
      const text = await team.textContent(); // textContent: the entrance animation hides the cards until scrolled into view
      const names = lang === 'ar' ? ['أماني روماني', 'إيريني عاطف'] : ['Amany Romany', 'Ereeny Atef'];
      assert.ok(names.every((n) => text.includes(n)), `both names in the page language (${lang})`);
      assert.ok(text.includes(lang === 'ar' ? 'الصف الثاني الثانوي' : 'Second-year secondary school'), `grade (${lang})`);
      assert.equal(await team.locator('h3').count(), 2);
      const hrefs = await page.locator('header nav a').evaluateAll((els) => els.map((e) => e.getAttribute('href')));
      assert.ok(hrefs.includes('#team'), 'nav links to the team');
      for (const href of hrefs) assert.equal(await page.locator(href).count(), 1, `nav target ${href} exists`);
      await context.close();
    }
    console.log('PASS team section and nav targets');

    // 2g. No mockup is cropped (vertically or horizontally) at phone widths: the old overflow:hidden cut tilted cards.
    for (const width of [320, 390, 500]) {
      const { context, page } = await open(`${base}/?lang=ar`, undefined, { width, height: 900 }, { reducedMotion: 'reduce' });
      const cropped = await page.evaluate(() => {
        const out = [];
        document.querySelectorAll('.lp-feature-art').forEach((art, i) => {
          const a = art.getBoundingClientRect();
          const card = art.firstElementChild.getBoundingClientRect();
          const cut = Math.max(0, a.left - card.left, card.right - a.right, a.top - card.top, card.bottom - a.bottom);
          if (cut > 2) out.push(`feature ${i}: ${Math.round(cut)}px`);
          if (card.left < -1 || card.right > innerWidth + 1) out.push(`feature ${i}: outside viewport`);
        });
        return out;
      });
      assert.deepEqual(cropped, [], `cropped mockups at ${width}px`);
      await context.close();
    }
    console.log('PASS feature mockups are not cropped (320/390/500)');

    // 2h. The hero phone shows its whole screen: the bottom tab bar (.lp-phone-nav, the last child) must sit inside
    //     .lp-phone's overflow clip. scrollHeight/clientHeight are layout metrics, so the phone's rotation cannot skew them.
    for (const width of [320, 390, 500]) {
      const { context, page } = await open(`${base}/?lang=ar`, undefined, { width, height: 900 }, { reducedMotion: 'reduce' });
      const hidden = await page.evaluate(() => {
        const phone = document.querySelector('.lp-hero-art .lp-phone');
        if (!phone.querySelector('.lp-phone-nav')) return Infinity;
        return phone.scrollHeight - phone.clientHeight;
      });
      assert.ok(hidden <= 0, `hero phone tab bar is cut by ${hidden}px at ${width}px`);
      await context.close();
    }
    console.log('PASS hero phone tab bar is not cropped (320/390/500)');

    // 2d. Accessibility: axe finds nothing in both languages, with and without a release, desktop and phone.
    //     reducedMotion keeps the DOM static (no GSAP mid-fade states), so contrast is judged on the real colours.
    {
      const axePath = require.resolve('axe-core/axe.min.js');
      for (const [lang, manifest, viewport] of [
        ['ar', validManifest, { width: 1440, height: 900 }], ['en', validManifest, { width: 1440, height: 900 }],
        ['ar', undefined, { width: 1440, height: 900 }], ['en', undefined, { width: 1440, height: 900 }],
        ['ar', validManifest, { width: 390, height: 844 }], ['en', validManifest, { width: 390, height: 844 }],
      ]) {
        const { context, page } = await open(`${base}/?lang=${lang}`, manifest, viewport, { reducedMotion: 'reduce' });
        await page.addScriptTag({ path: axePath });
        const result = await page.evaluate(() => window.axe.run(document, { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa', 'wcag21a', 'wcag21aa', 'best-practice'] } }));
        const summary = result.violations.map((v) => `${v.id}: ${v.nodes.slice(0, 3).map((n) => n.target.join(' ')).join(' | ')}`);
        assert.deepEqual(summary, [], `axe violations (${lang}, ${manifest ? 'release' : 'no release'}, ${viewport.width}px)`);
        await context.close();
      }
      console.log('PASS axe: 0 violations (ar/en, release/none, 1440/390, incl. best-practice)');
    }

    // 2i. English has its own real URL (/en/): static language/canonical are right, and switching language rewrites URL, title and canonical.
    {
      const { context, page, errors } = await open(`${base}/en/`, undefined);
      assert.equal(await page.locator('html').getAttribute('lang'), 'en');
      assert.equal(await page.locator('html').getAttribute('dir'), 'ltr');
      assert.match(await page.title(), /Study Notes|ENote/i);
      assert.match(await page.locator('link[rel="canonical"]').getAttribute('href'), /\/en\/$/);
      await page.locator('.lp-language').click();
      await page.waitForTimeout(600);
      assert.equal(await page.locator('html').getAttribute('lang'), 'ar');
      assert.equal(new URL(page.url()).pathname, '/', 'switching to Arabic returns to /');
      assert.doesNotMatch(await page.locator('link[rel="canonical"]').getAttribute('href'), /\/en\/$/);
      assert.deepEqual(errors, []);
      await context.close();
      console.log('PASS /en/ real URL and language switch updates URL/canonical');
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
      assert.equal(await page.locator('a[download]').count(), 0, `${label}: no download link anywhere`);
      assert.equal(await page.locator('#get code').count(), 0, `${label}: no fingerprint UI`);
      await context.close();
    }
    console.log('PASS untrusted manifests rejected');

    // 4. Arabic + no horizontal overflow at small widths with the button present.
    for (const width of [320, 390, 820]) {
      const { context, page } = await open(`${base}/?lang=ar`, validManifest, { width, height: 800 });
      assert.equal(await page.locator('html').getAttribute('lang'), 'ar');
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      assert.ok(overflow <= 0, `horizontal overflow ${overflow}px at ${width}`);
      if (width < 801) assert.equal(await page.locator('.lp-nav-cta').isVisible(), false, `header CTA is hidden on phones (${width}px)`);
      await context.close();
    }
    console.log('PASS no horizontal overflow (ar, 320/390/820)');
  } finally {
    await browser?.close();
    server.kill();
  }
}
run().catch((e) => { console.error(e); process.exit(1); });
