"""One-time, assertion-guarded source migration for the audited web defects."""
from pathlib import Path
import re

p=Path('Landing.tsx'); s=p.read_text(encoding='utf8')
s,count=re.subn(r'<a\b(?=[^>]*href="/downloads/ENote-v1\.0\.0\.apk")[\s\S]*?</a>', '', s)
assert count==4, count
s=s.replace("return localStorage.getItem('enote_landing_language') === 'en' ? 'en' : 'ar';", "const requested = new URLSearchParams(location.search).get('lang');\n      return requested === 'en' || requested === 'ar' ? requested : localStorage.getItem('enote_landing_language') === 'en' ? 'en' : 'ar';")
s=s.replace("localStorage.setItem('enote_landing_language', language);", "localStorage.setItem('enote_landing_language', language);\n      const url = new URL(location.href); url.searchParams.set('lang', language); history.replaceState(null, '', url);\n      document.querySelector('meta[name=\"description\"]')?.setAttribute('content', t.intro);")
start=s.index('  // Auto-scroll active tab');end=s.index('  const changeScene',start)
s=s[:start]+s[end:]
s=s.replace('const changeScene = (next: Scene) => {','const changeScene = (next: Scene) => {\n    const activeTab = document.getElementById(`tab-${next}`);\n    if (activeTab?.parentElement) { const bar = activeTab.parentElement; const tabBox = activeTab.getBoundingClientRect(); const barBox = bar.getBoundingClientRect(); bar.scrollBy({ left: tabBox.left - barBox.left - (barBox.width - tabBox.width) / 2, behavior: matchMedia(\'(prefers-reduced-motion: reduce)\').matches ? \'instant\' : \'smooth\' }); }')
s=s.replace('<div className="lp-strip" aria-label=', '<div className="lp-strip" role="group" aria-label=')
s=s.replace("gsap.fromTo(\n        '.lp-demo-panel',", "if (matchMedia('(prefers-reduced-motion: reduce)').matches) return;\n      gsap.fromTo(\n        '.lp-demo-panel',")
# Honest platform status remains visible without offering unverified bytes.
s=s.replace('<div className="lp-hero-foot">', '<p className="lp-release-status">{ar ? \'نسخة Android قيد التجهيز؛ جرّب نسخة الويب الآن.\' : \'Android release in preparation. Try the web app today.\'}</p><div className="lp-hero-foot">')
s=s.replace('ذكاء اصطناعي حقيقي', 'مساعد دراسي').replace('Real AI', 'Study assistant').replace('real AI', 'study assistance')
p.write_text(s,encoding='utf8')
p=Path('StatisticsCharts.tsx');s=p.read_text(encoding='utf8').replace('<AreaChart data=', '<AreaChart accessibilityLayer={false} data=').replace('<PieChart>', '<PieChart accessibilityLayer={false}>');p.write_text(s,encoding='utf8')
p=Path('FlipClock.tsx');s=p.read_text(encoding='utf8');s=s.replace("aria-label={t('الدقائق:","role=\"img\" aria-label={t('الدقائق:").replace("aria-label={t('الثواني:","role=\"img\" aria-label={t('الثواني:");p.write_text(s,encoding='utf8')
p=Path('redesign.css');s=p.read_text(encoding='utf8').replace('color: #10b981;', 'color: #137052;').replace('opacity: 0.75;', 'opacity: 1;');s+='\n/* Readable states on both composite surfaces. */\n.sf-reward-pill.locked { color: var(--ink); }\n.sf-reward-card.locked .text-gray-400 { color: var(--muted); }\n.sf-reward-card .text-amber-500 { color: #885700; background: #fff2d8; }\n.sf-ai-phase .text-indigo-500, .sf-ai-phase .text-indigo-600 { color: #5142ae; }\n.dark .sf-ai-phase .text-indigo-500, .dark .sf-ai-phase .text-indigo-600 { color: #cabdff; }\n';p.write_text(s,encoding='utf8')
p=Path('landing.css');s=p.read_text(encoding='utf8')+'\n.lp-release-status {color:#b2c2d7;font-size:12px;margin-top:20px!important}\n';p.write_text(s,encoding='utf8')
p=Path('scripts/check-web.cjs');s=p.read_text(encoding='utf8').replace("page.locator('.sf-page-header h1').innerText()", "page.locator('.sf-page-header h1:visible').innerText()").replace("'http://localhost:3000'", "'http://localhost:3000/app'");p.write_text(s,encoding='utf8')
