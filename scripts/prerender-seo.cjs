/* Post-build SEO prerender (plain Node, no browser: safe on Vercel).
 *   node scripts/prerender-seo.cjs [outDir=dist]
 * Takes the Vite-built <outDir>/index.html and emits one real, language-specific HTML file per language:
 *   <outDir>/index.html     Arabic  (https://site/)
 *   <outDir>/en/index.html  English (https://site/en/)
 * Each file gets its own title/description/canonical/hreflang cluster/Open Graph/Twitter tags, JSON-LD
 * (MobileApplication, Organization, WebSite, WebPage, FAQPage) and a crawlable static copy of the page text inside
 * #root (React replaces it on mount). Texts come from landing-seo.json (meta) and the `copy` object of Landing.tsx
 * (body + FAQ), so nothing is typed twice. It also writes <outDir>/sitemap.xml and <outDir>/robots.txt.
 * Env: SITE_URL overrides the origin in landing-seo.json (set it when the real production/custom domain differs);
 *      SEO_LASTMOD (YYYY-MM-DD) overrides the sitemap lastmod (default: build date, UTC). */
const fs = require('node:fs');
const path = require('node:path');
const { loadCopy } = require('./lib/landing-copy.cjs');

const root = path.resolve(__dirname, '..');
const outDir = path.resolve(process.argv[2] || path.join(root, 'dist'));
const seo = JSON.parse(fs.readFileSync(path.join(root, 'landing-seo.json'), 'utf8'));
const origin = (process.env.SITE_URL || seo.origin).replace(/\/+$/, '');
const lastmod = process.env.SEO_LASTMOD || new Date().toISOString().slice(0, 10);
const copy = loadCopy();
const LANGS = ['ar', 'en'];
const RELEASES_PAGE = 'https://github.com/Zaroscript/study_flow/releases/latest';
// Keep identical to RELEASE_URL / parseRelease in Landing.tsx: the static page may only claim what the live page shows.
const RELEASE_URL = /^https:\/\/github\.com\/Zaroscript\/study_flow\/releases\/(?:latest\/download|download\/[A-Za-z0-9._-]+)\/ENote[A-Za-z0-9._-]*\.apk$/;

const fail = (message) => { console.error(`FAIL prerender-seo: ${message}`); process.exit(1); };
const esc = (value) => String(value).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
const abs = (p) => `${origin}${p}`;
const ldJson = (data) => JSON.stringify(data).replace(/</g, '\\u003c').split(String.fromCharCode(0x2028)).join('\\u2028').split(String.fromCharCode(0x2029)).join('\\u2029');

function readRelease() {
  try {
    const r = JSON.parse(fs.readFileSync(path.join(outDir, 'release.json'), 'utf8'));
    const ok = r && r.available === true && /^\d+\.\d+\.\d+$/.test(r.version || '') && RELEASE_URL.test(r.apkUrl || '') && /^[a-f0-9]{64}$/.test(r.sha256 || '') && r.sizeBytes > 0;
    return ok ? r : null;
  } catch { return null; }
}
const release = readRelease();

function criticalCss() {
  let fonts = '';
  try { fonts = fs.readFileSync(path.join(outDir, 'assets', 'fonts', 'fonts.css'), 'utf8').trim(); } catch { fonts = ''; }
  return `${fonts}
html{background:#071a34;color-scheme:dark}
body{margin:0;background:#071a34;color:#f7f9ff;font-family:Cairo,Manrope,system-ui,sans-serif;line-height:1.7}
html[data-lang-mismatch] #root{visibility:hidden}
#seo-static{max-width:860px;margin:0 auto;padding:20px 20px 56px}
#seo-static a{color:#ffb23f}
#seo-static header{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:28px}
#seo-static .brand{font:800 1.5rem/1 Manrope,sans-serif;color:#f7f9ff;text-decoration:none}
#seo-static .brand span{color:#ffb23f}
#seo-static h1{font-size:clamp(2.1rem,8vw,3.8rem);line-height:1.2;margin:.3em 0 .4em;font-weight:800}
#seo-static h1 span{display:block;color:#ffb23f}
#seo-static h2{font-size:clamp(1.4rem,4.5vw,2rem);line-height:1.3;margin:1.8em 0 .5em}
#seo-static h3{font-size:1.15rem;margin:1.2em 0 .3em}
#seo-static p,#seo-static li{color:#b2c2d7;font-size:1.05rem}
#seo-static .lead{font-size:1.2rem;color:#e3ebf7}
#seo-static ol{padding-inline-start:1.4em}
#seo-static footer{margin-top:3em;padding-top:1.2em;border-top:1px solid rgba(178,194,215,.25);display:flex;flex-wrap:wrap;gap:8px 20px;align-items:center}`;
}

function headTags(lang) {
  const s = seo[lang];
  const pageUrl = abs(s.path);
  const other = LANGS.find((l) => l !== lang);
  const font = 'Cairo';
  const tags = [
    `<title>${esc(s.title)}</title>`,
    `<meta name="description" content="${esc(s.description)}" />`,
    `<meta name="robots" content="index, follow, max-snippet:-1, max-image-preview:large, max-video-preview:-1" />`,
    `<link rel="canonical" href="${pageUrl}" />`,
    ...LANGS.map((l) => `<link rel="alternate" hreflang="${seo[l].hreflang}" href="${abs(seo[l].path)}" />`),
    `<link rel="alternate" hreflang="x-default" href="${abs(seo.ar.path)}" />`,
    `<meta name="theme-color" content="#071a34" />`,
    `<meta name="color-scheme" content="dark" />`,
    `<meta name="application-name" content="ENote" />`,
    `<meta property="og:type" content="website" />`,
    `<meta property="og:site_name" content="ENote" />`,
    `<meta property="og:url" content="${pageUrl}" />`,
    `<meta property="og:title" content="${esc(s.ogTitle)}" />`,
    `<meta property="og:description" content="${esc(s.description)}" />`,
    `<meta property="og:locale" content="${s.ogLocale}" />`,
    `<meta property="og:locale:alternate" content="${seo[other].ogLocale}" />`,
    `<meta property="og:image" content="${abs(s.ogImage)}" />`,
    `<meta property="og:image:type" content="image/png" />`,
    `<meta property="og:image:width" content="1200" />`,
    `<meta property="og:image:height" content="630" />`,
    `<meta property="og:image:alt" content="${esc(s.ogImageAlt)}" />`,
    `<meta name="twitter:card" content="summary_large_image" />`,
    `<meta name="twitter:title" content="${esc(s.ogTitle)}" />`,
    `<meta name="twitter:description" content="${esc(s.description)}" />`,
    `<meta name="twitter:image" content="${abs(s.ogImage)}" />`,
    `<meta name="twitter:image:alt" content="${esc(s.ogImageAlt)}" />`,
    `<link rel="icon" type="image/png" sizes="48x48" href="/assets/icons/icon-48.png" />`,
    `<link rel="icon" type="image/png" sizes="192x192" href="/assets/icons/icon-192.png" />`,
    `<link rel="apple-touch-icon" sizes="180x180" href="/assets/icons/apple-touch-icon.png" />`,
    `<link rel="manifest" href="/manifest.json" />`,
    ...['Cairo', 'Manrope'].map((font) => `<link rel="preload" href="/assets/fonts/${font}.woff2" as="font" type="font/woff2" crossorigin />`),
    `<style>${criticalCss()}</style>`,
    `<script type="application/ld+json">${ldJson(jsonLd(lang))}</script>`,
  ];
  return tags.map((t) => `    ${t}`).join('\n');
}

function jsonLd(lang) {
  const s = seo[lang];
  const c = copy[lang];
  const pageUrl = abs(s.path);
  const logo = { '@type': 'ImageObject', url: abs('/assets/icons/icon-512.png'), width: 512, height: 512 };
  const app = {
    '@type': 'MobileApplication',
    '@id': abs('/#app'),
    name: 'ENote',
    url: abs('/'),
    description: c.intro,
    applicationCategory: 'EducationalApplication',
    operatingSystem: release ? 'Android 7.0+' : 'Android',
    inLanguage: ['ar', 'en'],
    image: abs('/assets/icons/icon-512.png'),
    featureList: c.features.map((f) => f[0]),
    publisher: { '@id': abs('/#organization') },
  };
  if (release) { app.softwareVersion = release.version; app.downloadUrl = RELEASES_PAGE; }
  return {
    '@context': 'https://schema.org',
    '@graph': [
      { '@type': 'Organization', '@id': abs('/#organization'), name: 'ENote', url: abs('/'), logo },
      { '@type': 'WebSite', '@id': abs('/#website'), url: abs('/'), name: 'ENote', inLanguage: ['ar', 'en'], publisher: { '@id': abs('/#organization') } },
      {
        '@type': 'WebPage', '@id': `${pageUrl}#webpage`, url: pageUrl, name: s.title, description: s.description, inLanguage: s.htmlLang,
        isPartOf: { '@id': abs('/#website') }, about: { '@id': abs('/#app') },
        primaryImageOfPage: { '@type': 'ImageObject', url: abs(s.ogImage), width: 1200, height: 630 },
      },
      app,
      {
        '@type': 'FAQPage', '@id': `${pageUrl}#faq`, url: pageUrl, inLanguage: s.htmlLang,
        mainEntity: c.faqs.map(([q, a]) => ({ '@type': 'Question', name: q, acceptedAnswer: { '@type': 'Answer', text: a } })),
      },
    ],
  };
}

function bodyHtml(lang) {
  const c = copy[lang];
  const ar = lang === 'ar';
  const s = seo[lang];
  const other = LANGS.find((l) => l !== lang);
  const mb = release ? (release.sizeBytes / 1e6).toFixed(1) : '';
  const releaseLine = release
    ? ar
      ? `الإصدار <bdi dir="ltr">${esc(release.version)}</bdi> · <bdi dir="ltr">${mb} MB</bdi> · أندرويد 7.0 فأعلى`
      : `Version ${esc(release.version)} · ${mb} MB · Android 7.0+`
    : ar ? 'نسخة Android قيد التجهيز.' : 'Android release in preparation.';
  const download = release
    ? `<p><a href="${esc(release.apkUrl)}" rel="noopener" download>${ar ? 'تنزيل لأندرويد' : 'Download for Android'}</a></p>`
    : `<p>${esc(c.androidSoon)}</p>`;
  const list = (items, tag = 'h2') => items.map(([title, text]) => `<section><${tag}>${esc(title)}</${tag}><p>${esc(text)}</p></section>`).join('');
  return `
<div id="seo-static" lang="${s.htmlLang}" dir="${ar ? 'rtl' : 'ltr'}">
  <header>
    <a class="brand" href="${s.path}" aria-label="ENote">ENote<span>.</span></a>
    <nav aria-label="${ar ? 'اللغة' : 'Language'}"><a href="${seo[other].path}" hreflang="${seo[other].hreflang}" lang="${seo[other].htmlLang}">${esc(c.lang)}</a></nav>
  </header>
  <main>
    <h1>${esc(c.headline[0])} <span>${esc(c.headline[1])}</span></h1>
    <p class="lead">${esc(c.intro)}</p>
    ${download}
    <p>${releaseLine}</p>
    <section id="idea"><h2>${esc(c.storyTitle.join(' '))}</h2><p>${esc(c.storyBody)}</p></section>
    <div id="features">${list(c.features.map((f) => [f[0], f[1]]))}</div>
    <h2>${esc(c.extrasTitle)}</h2>
    ${list(c.extras, 'h3')}
    <section id="get"><h2>${esc(c.getTitle)}</h2><p>${esc(c.getBody)}</p>${download}<h3>${esc(c.installTitle)}</h3><ol>${c.installSteps.map((x) => `<li>${esc(x)}</li>`).join('')}</ol></section>
    <section id="team"><h2>${esc(c.teamTitle.join(' '))}</h2><p>${esc(c.teamBody)}</p></section>
    <section id="questions"><h2>${esc(c.faqTitle)}</h2>${c.faqs.map(([q, a]) => `<h3>${esc(q)}</h3><p>${esc(a)}</p>`).join('')}</section>
    <section><h2>${esc(c.cta.join(' '))}</h2><p>${esc(c.ctaBody)}</p></section>
  </main>
  <footer>
    <span>${esc(c.footer)}</span>
    <a href="#get">${esc(c.footerGet)}</a>
    <a href="/privacy">${ar ? 'الخصوصية' : 'Privacy'}</a>
    <a href="${seo[other].path}" hreflang="${seo[other].hreflang}" lang="${seo[other].htmlLang}">${esc(c.lang)}</a>
  </footer>
</div>
`;
}

function render(template, lang) {
  const s = seo[lang];
  let html = template;
  const must = (re, label) => { if (!re.test(html)) fail(`marker not found in ${path.join(outDir, 'index.html')}: ${label}`); };
  must(/<!-- seo:head:start -->[\s\S]*?<!-- seo:head:end -->/, 'seo:head');
  must(/<!-- seo:body -->[\s\S]*?<!-- \/seo:body -->/, 'seo:body');
  must(/<html[^>]*>/, '<html>');
  html = html.replace(/<!--\s*SEO block:[\s\S]*?-->/, ''); // authoring note for index.html, not for production
  html = html.replace(/<html[^>]*>/, `<html lang="${s.htmlLang}" dir="${lang === 'ar' ? 'rtl' : 'ltr'}">`);
  html = html.replace(/<!-- seo:head:start -->[\s\S]*?<!-- seo:head:end -->/, () => `<!-- seo:head:start -->\n${headTags(lang)}\n    <!-- seo:head:end -->`);
  html = html.replace(/<!-- seo:body -->[\s\S]*?<!-- \/seo:body -->/, () => `<!-- seo:body -->${bodyHtml(lang)}<!-- /seo:body -->`);
  return html;
}

function sitemap() {
  const alternates = [...LANGS.map((l) => `    <xhtml:link rel="alternate" hreflang="${seo[l].hreflang}" href="${abs(seo[l].path)}" />`), `    <xhtml:link rel="alternate" hreflang="x-default" href="${abs(seo.ar.path)}" />`].join('\n');
  const entry = (loc, extra = '', priority = '') => `  <url>\n    <loc>${loc}</loc>\n    <lastmod>${lastmod}</lastmod>${priority}${extra}\n  </url>`;
  return `<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">
${LANGS.map((l) => entry(abs(seo[l].path), `\n${alternates}`)).join('\n')}
${entry(abs('/privacy'))}
</urlset>
`;
}

const indexFile = path.join(outDir, 'index.html');
if (!fs.existsSync(indexFile)) fail(`${indexFile} not found: run vite build first`);
const template = fs.readFileSync(indexFile, 'utf8');
const rendered = Object.fromEntries(LANGS.map((l) => [l, render(template, l)]));
for (const l of LANGS) {
  // Fail the build loudly instead of shipping a placeholder like 'undefined' when a copy key is renamed.
  const text = rendered[l].replace(/<script[\s\S]*?<\/script>/g, '');
  if (/>[^<]*(undefined|\[object Object\]|NaN)[^<]*</.test(text)) fail(`static ${l} page contains undefined/[object Object]/NaN: a copy key used by the prerenderer is missing in Landing.tsx`);
}
fs.mkdirSync(path.join(outDir, 'en'), { recursive: true });
fs.writeFileSync(path.join(outDir, 'index.html'), rendered.ar);
fs.writeFileSync(path.join(outDir, 'en', 'index.html'), rendered.en);
fs.writeFileSync(path.join(outDir, 'sitemap.xml'), sitemap());
const privacyFile = path.join(outDir, 'privacy.html');
if (fs.existsSync(privacyFile)) {
  // The page switches language client-side with ?lang=, so pin one canonical URL (origin follows SITE_URL).
  let privacy = fs.readFileSync(privacyFile, 'utf8').replace(/<link rel="canonical"[^>]*>\s*/g, '');
  privacy = privacy.replace('</head>', `<link rel="canonical" href="${abs('/privacy')}" />
</head>`);
  fs.writeFileSync(privacyFile, privacy);
}
const robotsFile = path.join(outDir, 'robots.txt');
if (fs.existsSync(robotsFile)) {
  const robots = fs.readFileSync(robotsFile, 'utf8').replace(/^Sitemap:.*$/m, `Sitemap: ${abs('/sitemap.xml')}`);
  fs.writeFileSync(robotsFile, robots);
}
console.log(`OK prerender-seo: ${origin} | index.html (ar), en/index.html (en), sitemap.xml (lastmod ${lastmod}) | release.json ${release ? `v${release.version}` : 'absent/invalid -> "in preparation" wording, no softwareVersion/downloadUrl'}`);
