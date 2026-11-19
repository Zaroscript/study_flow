/* SEO regression gate for the landing. Plain Node, no dependencies, exit code 1 on any failure.
 *   node scripts/check-seo.cjs [outDir=dist]      checks the BUILT output (run after `pnpm build`)
 *   node scripts/check-seo.cjs --live <baseUrl>   after a deploy: checks status codes/headers on the real site
 * Env SITE_URL overrides the origin from landing-seo.json (same as the build).
 * What it proves offline: per-language static HTML (title/description/canonical/hreflang reciprocity/og/twitter/h1),
 * JSON-LD parses and matches the page copy (and claims no rating/review), sitemap + robots + manifest + social
 * images are consistent with the built files, and a SIMULATION of vercel.json routing (not a Vercel run) returns
 * 200 for real pages and a real 404 for unknown URLs. */
const fs = require('node:fs');
const path = require('node:path');
const { loadCopy } = require('./lib/landing-copy.cjs');

const root = path.resolve(__dirname, '..');
const args = process.argv.slice(2);
const seo = JSON.parse(fs.readFileSync(path.join(root, 'landing-seo.json'), 'utf8'));
const origin = (process.env.SITE_URL || seo.origin).replace(/\/+$/, '');
let failures = 0;
const ok = (label) => console.log(`PASS ${label}`);
const bad = (label, detail = '') => { failures++; console.error(`FAIL ${label}${detail ? `: ${detail}` : ''}`); };
const check = (cond, label, detail) => (cond ? ok(label) : bad(label, detail));
const len = (s) => [...s].length;

if (args[0] === '--live') {
  const base = (args[1] || origin).replace(/\/+$/, '');
  (async () => {
    const get = async (p) => { const r = await fetch(base + p, { redirect: 'manual' }); return { status: r.status, headers: r.headers, text: await r.text() }; };
    const expectations = [
      ['/', 200], ['/en/', 200], ['/en', 200], ['/privacy', 200], ['/robots.txt', 200], ['/sitemap.xml', 200], ['/manifest.json', 200],
      ['/does-not-exist-seo-check', 404], ['/en/does-not-exist', 404],
    ];
    for (const [p, status] of expectations) { const r = await get(p); check(r.status === status, `live ${p} -> ${status}`, `got ${r.status}`); }
    check(/<title>[^<]*(الخصوصية|Privacy)/.test((await get('/privacy')).text), 'live /privacy serves the privacy page (not the app shell)');
    const redirect = await get('/?lang=en');
    check([301, 308].includes(redirect.status) && /\/en\/?(\?.*)?$/.test(redirect.headers.get('location') || ''), 'live /?lang=en redirects permanently to /en/', `${redirect.status} ${redirect.headers.get('location')}`);
    const app = await get('/app');
    check([301, 308].includes(app.status) && /^(\/|https?:\/\/[^/]+\/?)$/.test(app.headers.get('location') || ''), 'live /app redirects to the landing page', `${app.status} ${app.headers.get('location')}`);
    const nf = await get('/does-not-exist-seo-check');
    check(/noindex/i.test(nf.text), '404 page is noindex');
    for (const [p, lang] of [['/', 'ar'], ['/en/', 'en']]) {
      const r = await get(p);
      check(r.text.includes(`<link rel="canonical" href="${origin}${seo[lang].path}"`), `live ${p} canonical is ${origin}${seo[lang].path}`);
    }
    for (const h of ['x-content-type-options', 'referrer-policy']) check(!!(await get('/')).headers.get(h), `live header ${h} present`);
    finish();
  })().catch((e) => { bad('live check crashed', e.message); finish(); });
}

function finish() {
  if (failures) { console.error(`\n${failures} SEO check(s) failed`); process.exit(1); }
  console.log('\nSEO checks passed');
}

function pngSize(file) {
  const b = fs.readFileSync(file);
  if (b.length < 24 || b.toString('ascii', 1, 4) !== 'PNG') return null;
  return { w: b.readUInt32BE(16), h: b.readUInt32BE(20), bytes: b.length };
}
const unescapeHtml = (s) => s.replace(/&quot;/g, '"').replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&amp;/g, '&');
const meta = (html, attr, key) => { const m = html.match(new RegExp(`<meta ${attr}="${key}" content="([^"]*)"`)); return m ? unescapeHtml(m[1]) : null; };
const links = (html, rel) => [...html.matchAll(new RegExp(`<link rel="${rel}"([^>]*)>`, 'g'))].map((m) => ({ href: (m[1].match(/href="([^"]*)"/) || [])[1], hreflang: (m[1].match(/hreflang="([^"]*)"/) || [])[1] }));
const text = (html) => unescapeHtml(html.replace(/<script[\s\S]*?<\/script>/g, '').replace(/<style[\s\S]*?<\/style>/g, '').replace(/<[^>]+>/g, ' ')).replace(/\s+/g, ' ');

// Minimal model of Vercel routing (docs: redirects -> filesystem -> rewrites -> 404; cleanUrls; source patterns). SIMULATION.
function simulateVercel(config, outDir) {
  const toRegex = (source) => new RegExp('^' + source.replace(/[.+?^${}|[\]\\]/g, '\\$&').replace(/\/:\w+\*/g, '(?:/.*)?').replace(/:\w+/g, '[^/]+').replace(/\(\\\.\*\)/g, '(.*)') + '/?$');
  const file = (p) => { const f = path.join(outDir, p); return fs.existsSync(f) && fs.statSync(f).isFile() ? f : null; };
  const headersFor = (p) => {
    const h = {};
    for (const rule of config.headers || []) if (toRegex(rule.source).test(p)) for (const x of rule.headers) h[x.key.toLowerCase()] = x.value;
    return h;
  };
  return (url) => {
    const u = new URL(url, 'http://sim');
    const p = u.pathname;
    if (config.cleanUrls && /\.html$/.test(p) && file(p)) return { status: 308, location: p.replace(/\/index\.html$/, '/').replace(/\.html$/, '') };
    for (const r of config.redirects || []) {
      if (!toRegex(r.source).test(p)) continue;
      if ((r.has || []).every((c) => c.type === 'query' && u.searchParams.get(c.key) === c.value)) return { status: r.permanent ? 308 : 307, location: r.destination };
    }
    const candidates = [p, config.cleanUrls ? `${p}.html` : null, `${p.replace(/\/$/, '')}/index.html`].filter(Boolean);
    for (const c of candidates) { const f = file(c); if (f) return { status: 200, file: path.relative(outDir, f).replace(/\\/g, '/'), headers: headersFor(p) }; }
    for (const r of config.rewrites || []) {
      if (!toRegex(r.source).test(p)) continue;
      if (r.destination.startsWith('/api/')) return { status: 200, file: '(function)', headers: headersFor(p) };
      const f = file(r.destination) || file(`${r.destination}.html`);
      if (f) return { status: 200, file: path.relative(outDir, f).replace(/\\/g, '/'), headers: headersFor(p) };
    }
    return { status: 404, file: '404.html', headers: headersFor(p) };
  };
}

function offline(outDir) {
  const need = (rel) => { const f = path.join(outDir, rel); if (!fs.existsSync(f)) { bad(`built file exists: ${rel}`); return null; } return fs.readFileSync(f, 'utf8'); };
  const copy = loadCopy();
  const pages = { ar: need('index.html'), en: need('en/index.html') };
  if (!pages.ar || !pages.en) return finish();
  const releasePath = path.join(outDir, 'release.json');
  let release = null;
  try { const r = JSON.parse(fs.readFileSync(releasePath, 'utf8')); if (r.available === true && /^\d+\.\d+\.\d+$/.test(r.version)) release = r; } catch {}

  const fileForPath = (p) => (p === '/' ? 'index.html' : p.endsWith('/') ? `${p.slice(1)}index.html` : fs.existsSync(path.join(outDir, `${p.slice(1)}.html`)) ? `${p.slice(1)}.html` : p.slice(1));
  const clusterOf = (html) => links(html, 'alternate').filter((l) => l.hreflang).map((l) => `${l.hreflang}=${l.href}`).sort().join('|');

  for (const lang of ['ar', 'en']) {
    const html = pages[lang];
    const s = seo[lang];
    const tag = `[${lang}]`;
    check(new RegExp(`<html lang="${s.htmlLang}" dir="${lang === 'ar' ? 'rtl' : 'ltr'}">`).test(html), `${tag} <html lang dir> are static and correct`);
    const title = (html.match(/<title>([^<]*)<\/title>/) || [])[1];
    check(title && unescapeHtml(title) === s.title && len(s.title) <= 60, `${tag} title matches landing-seo.json and is <= 60 chars (${len(s.title)})`);
    check(((html.match(/<title>/g) || []).length) === 1, `${tag} exactly one <title>`);
    check(!/>[^<]*(undefined|\[object Object\]|NaN)[^<]*</.test(html.replace(/<script[\s\S]*?<\/script>/g, '')), `${tag} static text has no undefined/[object Object]/NaN`);
    const description = meta(html, 'name', 'description');
    check(description === s.description && len(description) >= 70 && len(description) <= 155, `${tag} meta description matches and is 70-155 chars (${description ? len(description) : 0})`);
    check(!/<meta name="keywords"/.test(html), `${tag} no meta keywords tag`);
    const robotsMeta = meta(html, 'name', 'robots') || '';
    check(/index/.test(robotsMeta) && !/noindex|nofollow/.test(robotsMeta), `${tag} robots meta is indexable`);
    const canon = links(html, 'canonical');
    check(canon.length === 1 && canon[0].href === `${origin}${s.path}`, `${tag} single self-referencing canonical ${origin}${s.path}`, JSON.stringify(canon));
    const cluster = links(html, 'alternate').filter((l) => l.hreflang);
    const expected = [`ar=${origin}${seo.ar.path}`, `en=${origin}${seo.en.path}`, `x-default=${origin}${seo.ar.path}`].sort().join('|');
    check(clusterOf(html) === expected, `${tag} hreflang cluster is ar/en/x-default with absolute URLs`, clusterOf(html));
    check(cluster.some((l) => l.href === `${origin}${s.path}`), `${tag} hreflang cluster includes itself`);
    for (const l of cluster) {
      const target = fileForPath(new URL(l.href).pathname);
      const targetHtml = fs.existsSync(path.join(outDir, target)) ? fs.readFileSync(path.join(outDir, target), 'utf8') : null;
      check(targetHtml !== null && clusterOf(targetHtml) === clusterOf(html) && links(targetHtml, 'canonical')[0].href === l.href, `${tag} hreflang ${l.hreflang} -> ${l.href} exists, is self-canonical and links back (reciprocal)`);
    }
    check(meta(html, 'property', 'og:locale') === s.ogLocale && meta(html, 'property', 'og:url') === `${origin}${s.path}` && meta(html, 'property', 'og:site_name') === 'ENote' && meta(html, 'property', 'og:type') === 'website', `${tag} og:locale/url/site_name/type`);
    check(meta(html, 'property', 'og:title') === s.ogTitle && meta(html, 'property', 'og:description') === s.description, `${tag} og:title/description`);
    const image = meta(html, 'property', 'og:image');
    const imageFile = image && path.join(outDir, new URL(image).pathname);
    const size = imageFile && fs.existsSync(imageFile) ? pngSize(imageFile) : null;
    check(image === `${origin}${s.ogImage}` && size && size.w === Number(meta(html, 'property', 'og:image:width')) && size.h === Number(meta(html, 'property', 'og:image:height')) && size.w === 1200 && size.h === 630 && meta(html, 'property', 'og:image:type') === 'image/png', `${tag} og:image absolute, exists, PNG, 1200x630 as declared`, JSON.stringify(size));
    check(size && size.bytes < 300 * 1024, `${tag} og:image is small (${size ? Math.round(size.bytes / 1024) : '?'} KB < 300 KB)`);
    check(!!meta(html, 'property', 'og:image:alt') && !!meta(html, 'name', 'twitter:image:alt'), `${tag} image alt text present`);
    check(meta(html, 'name', 'twitter:card') === 'summary_large_image' && meta(html, 'name', 'twitter:title') === s.ogTitle && meta(html, 'name', 'twitter:description') === s.description && meta(html, 'name', 'twitter:image') === image, `${tag} twitter card tags`);
    check(meta(html, 'name', 'theme-color') === '#071a34' && !!meta(html, 'name', 'color-scheme') && /<meta name="viewport"/.test(html), `${tag} theme-color, color-scheme, viewport`);
    check(/rel="icon"[^>]*icon-48\.png/.test(html) && /rel="apple-touch-icon"/.test(html) && /rel="manifest"/.test(html), `${tag} favicon, apple-touch-icon, manifest links`);
    for (const href of [...html.matchAll(/<link rel="(?:icon|apple-touch-icon)"[^>]*href="([^"]+)"/g)].map((m) => m[1])) check(fs.existsSync(path.join(outDir, href)), `${tag} icon file exists ${href}`);

    // Static body: one h1, crawlable copy, no hidden-text tricks.
    const h1s = html.match(/<h1[\s>]/g) || [];
    check(h1s.length === 1, `${tag} exactly one <h1> in static HTML`, String(h1s.length));
    const body = text(html.slice(html.indexOf('<body')));
    const c = copy[lang];
    check(body.includes(c.headline[0]) && body.includes(c.headline[1]) && body.includes(c.intro), `${tag} static body contains the headline and intro`);
    check(c.faqs.every(([q, a]) => body.includes(q) && body.includes(a)), `${tag} static body contains every FAQ question and answer`);
    check(!/display:\s*none|visibility:\s*hidden|font-size:\s*0|text-indent:\s*-\d{3,}/.test(html.replace(/html\[data-lang-mismatch\][^}]*}/, '')), `${tag} no hidden-text CSS in the static page`);
    check(/<a [^>]*href="\/privacy"/.test(html), `${tag} static page links to /privacy`);

    // JSON-LD.
    const blocks = [...html.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)].map((m) => m[1]);
    let graph = null;
    try { graph = blocks.map((b) => JSON.parse(b))[0]['@graph']; } catch (e) { bad(`${tag} JSON-LD parses`, e.message); }
    if (!graph) continue;
    ok(`${tag} JSON-LD parses (${blocks.length} block, ${graph.map((n) => n['@type']).join(', ')})`);
    const node = (type) => graph.find((n) => n['@type'] === type);
    for (const type of ['Organization', 'WebSite', 'WebPage', 'MobileApplication', 'FAQPage']) check(!!node(type), `${tag} JSON-LD has ${type}`);
    const raw = JSON.stringify(graph);
    check(!/aggregateRating|ratingValue|reviewCount|"review"|award|interactionStatistic|SearchAction/i.test(raw), `${tag} JSON-LD makes no rating/review/award/download-count/search claims`);
    check(!/"@type":"Person"/.test(raw), `${tag} JSON-LD names no individuals`);
    const faq = node('FAQPage');
    check(faq && faq.mainEntity.length === c.faqs.length && faq.mainEntity.every((q, i) => q.name === c.faqs[i][0] && q.acceptedAnswer.text === c.faqs[i][1] && body.includes(q.name) && body.includes(q.acceptedAnswer.text)), `${tag} FAQPage equals the page FAQ text (and the visible static text)`);
    const app = node('MobileApplication');
    check(app && app.description === c.intro && body.includes(app.description) && !('offers' in app) && app.applicationCategory === 'EducationalApplication' && /^Android/.test(app.operatingSystem), `${tag} MobileApplication matches the page (intro, free, EducationalApplication, Android)`);
    check(release ? app.softwareVersion === release.version && /^Android \d/.test(app.operatingSystem) && !!app.downloadUrl : app.softwareVersion === undefined && app.downloadUrl === undefined && app.operatingSystem === 'Android', `${tag} softwareVersion/downloadUrl follow release.json (${release ? `v${release.version}` : 'absent -> omitted'})`);
    check(release ? body.includes(`${release.version}`) && html.includes(`href="${release.apkUrl}"`) : body.includes(c.androidSoon), `${tag} static page states the same release status as the live page`);
    check(node('WebPage').inLanguage === s.htmlLang && node('WebPage').url === `${origin}${s.path}` && node('WebPage').name === s.title, `${tag} WebPage url/name/inLanguage match`);
  }
  check(pages.ar !== pages.en, 'ar and en HTML are different files');

  // Privacy page: one pinned canonical (the page switches language with ?lang=, so shared URLs must collapse to /privacy).
  const privacyHtml = need('privacy.html');
  if (privacyHtml) {
    const canon = [...privacyHtml.matchAll(/<link rel="canonical" href="([^"]*)"/g)].map((m) => m[1]);
    check(canon.length === 1 && canon[0] === `${origin}/privacy`, `privacy.html has a single canonical ${origin}/privacy`);
  }

  // Sitemap.
  const sm = need('sitemap.xml');
  if (sm) {
    check(/^<\?xml/.test(sm) && (sm.match(/<urlset/g) || []).length === 1 && (sm.match(/<\/urlset>/g) || []).length === 1, 'sitemap.xml is well-formed XML urlset');
    const locs = [...sm.matchAll(/<loc>([^<]+)<\/loc>/g)].map((m) => m[1]);
    check(JSON.stringify(locs.slice().sort()) === JSON.stringify([`${origin}/`, `${origin}/en/`, `${origin}/privacy`].sort()), 'sitemap lists /, /en/ and /privacy exactly (absolute)', locs.join(', '));
    for (const loc of locs) check(fs.existsSync(path.join(outDir, fileForPath(new URL(loc).pathname))), `sitemap URL is a built page: ${loc}`);
    check(!/\/app|release\.json|\/assets\//.test(sm.replace(/xmlns[^"]*"[^"]*"/g, '')), 'sitemap has no /app, release.json or assets');
    check([...sm.matchAll(/<lastmod>([^<]+)<\/lastmod>/g)].every((m) => /^\d{4}-\d{2}-\d{2}$/.test(m[1])) && (sm.match(/<lastmod>/g) || []).length === locs.length, 'sitemap lastmod is a valid date on every URL');
    for (const lang of ['ar', 'en']) check(sm.includes(`<xhtml:link rel="alternate" hreflang="${lang}" href="${origin}${seo[lang].path}" />`), `sitemap carries hreflang=${lang} alternates`);
    check((sm.match(/hreflang="x-default"/g) || []).length === 2, 'sitemap carries x-default for both language URLs');
  }

  // robots.txt.
  const robots = need('robots.txt');
  if (robots) {
    check(robots.split(/\r?\n/).includes(`Sitemap: ${origin}/sitemap.xml`), `robots.txt references ${origin}/sitemap.xml`);
    const disallows = robots.split(/\r?\n/).filter((l) => /^Disallow:/i.test(l)).map((l) => l.split(':')[1].trim()).filter(Boolean);
    check(!disallows.some((d) => ['/', '/en/', '/privacy', '/release.json', '/assets', '/assets/', '/manifest.json'].some((u) => u.startsWith(d))), 'robots.txt does not block /, /en/, /privacy, /release.json, /assets', disallows.join(','));
  }

  // Manifest.
  const manifestText = need('manifest.json');
  if (manifestText) {
    let m = null; try { m = JSON.parse(manifestText); } catch (e) { bad('manifest.json parses', e.message); }
    if (m) {
      check(m.name && m.short_name && m.lang && m.dir && m.start_url && m.display && m.theme_color && m.background_color, 'manifest has name, short_name, lang, dir, start_url, display, theme/background colour');
      check(m.icons.some((i) => i.purpose === 'maskable') && m.icons.some((i) => i.sizes === '192x192') && m.icons.filter((i) => i.sizes === '512x512').length >= 2, 'manifest has 192, 512 and a maskable 512 icon');
      for (const i of m.icons) { const size = pngSize(path.join(outDir, i.src)); check(size && `${size.w}x${size.h}` === i.sizes && !/\s/.test(i.sizes), `manifest icon ${i.src} exists and is really ${i.sizes}`, JSON.stringify(size)); }
    }
  }

  // 404 page and vercel.json routing (simulation).
  const nf = need('404.html');
  if (nf) check(/<meta name="robots" content="[^"]*noindex/.test(nf) && /lang="ar"/.test(nf) && /lang="en"/.test(nf) && /href="\/"/.test(nf), '404.html is bilingual, noindex and links home');
  let config = null; try { config = JSON.parse(fs.readFileSync(path.join(root, 'vercel.json'), 'utf8')); } catch (e) { bad('vercel.json parses', e.message); }
  if (config) {
    check(!(config.rewrites || []).some((r) => /^\/\(\.\*\)$/.test(r.source) || r.source === '/:path*'), 'vercel.json has no catch-all rewrite (no soft-404s)');
    const sim = simulateVercel(config, outDir);
    const expectations = [
      ['/', 200, 'index.html'], ['/en/', 200, 'en/index.html'], ['/en', 200, 'en/index.html'], ['/privacy', 200, 'privacy.html'],
      ['/robots.txt', 200, 'robots.txt'], ['/sitemap.xml', 200, 'sitemap.xml'], ['/manifest.json', 200, 'manifest.json'], ['/release.json', null, null],
      ['/assets/og-enote-ar.png', 200, 'assets/og-enote-ar.png'], ['/does-not-exist', 404, '404.html'], ['/en/nope', 404, '404.html'], ['/privacy/extra', 404, '404.html'],
    ];
    for (const [url, status, fileName] of expectations) {
      const r = sim(url);
      if (url === '/release.json') { check(release ? r.status === 200 : r.status === 404, `[sim] /release.json -> ${release ? 200 : 404} (it is ${release ? 'present' : 'absent: the page shows the "in preparation" state'})`, String(r.status)); continue; }
      check(r.status === status && r.file === fileName, `[sim] ${url} -> ${status} ${fileName}`, `${r.status} ${r.file}`);
    }
    const r1 = sim('/?lang=en'); check([301, 308].includes(r1.status) && r1.location === '/en/', '[sim] /?lang=en -> permanent redirect to /en/', JSON.stringify(r1));
    const r2 = sim('/privacy.html'); check(r2.status === 308 && r2.location === '/privacy', '[sim] /privacy.html -> 308 /privacy (cleanUrls)', JSON.stringify(r2));
    const r3 = sim('/downloads/ENote.apk'); check(r3.status === 307 || r3.status === 308, '[sim] /downloads/* still redirects to GitHub releases', JSON.stringify(r3));
    const r4 = sim('/app'); const r5 = sim('/app/settings');
    check([301, 308].includes(r4.status) && r4.location === '/' && [301, 308].includes(r5.status) && r5.location === '/', '[sim] /app and /app/* redirect to the landing page', JSON.stringify([r4, r5]));
    check(!(config.api || (config.rewrites || []).length), 'vercel.json has no rewrites left (no /api, no app shell)');
    for (const k of ['x-content-type-options', 'referrer-policy', 'x-frame-options']) check(!!sim('/').headers[k] && !!sim('/en/').headers[k], `[sim] security header ${k} on pages`);
    check(sim('/release.json').headers['cache-control'] === 'no-cache' && /immutable/.test(sim('/bundle/index-AbCd1234.js').headers['cache-control'] || '') && !/immutable/.test(sim('/assets/fonts/Cairo.woff2').headers['cache-control'] || '') && !/immutable/.test(sim('/assets/icons/icon-192.png').headers['cache-control'] || ''), '[sim] release.json no-cache; hashed /bundle immutable; unhashed /assets short-lived');
  }
  finish();
}

if (args[0] !== '--live') offline(path.resolve(args[0] || path.join(root, 'dist')));
