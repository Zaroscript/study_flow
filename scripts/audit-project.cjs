/* Read-only browser audit. All interactions use an isolated, disposable context. */
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const { createRequire } = require('node:module');
const { chromium } = createRequire(path.join(os.homedir(), '.cache/codex-runtimes/codex-primary-runtime/dependencies/node/package.json'))('playwright');

(async()=>{
 const output=path.resolve(__dirname,'../screenshots/audit-2026-11-17');
 await fs.mkdir(output,{recursive:true});
 const browser=await chromium.launch({headless:true,executablePath:path.join(os.homedir(),'AppData/Local/ms-playwright/chromium-1187/chrome-win/chrome.exe')});
 const page=await browser.newPage({viewport:{width:1440,height:1000}});
 const report={layouts:[],errors:[],flows:[],axe:[],workspace:null};
 page.on('pageerror',e=>report.errors.push(e.message));
 page.setDefaultTimeout(8000);
 try {
  await page.goto('http://127.0.0.1:3000',{waitUntil:'domcontentloaded'});
  await page.evaluate(()=>document.fonts.ready);
  await page.waitForTimeout(1800);
  const axe=require.resolve('axe-core/axe.min.js');
  const hasAxe=await fs.access(axe).then(()=>true).catch(()=>false);
  for(const lang of ['ar','en']){
   if(await page.locator('html').getAttribute('lang')!==lang) await page.getByRole('button',{name:lang==='en'?'English · التبديل إلى الإنجليزية':'العربية · Switch to Arabic',exact:true}).click();
   for(const width of [1440,820,390,320]){
    await page.setViewportSize({width,height:1000});
    await page.evaluate(()=>window.scrollTo(0,0));
    await page.waitForTimeout(1000);
    report.layouts.push(await page.evaluate(()=>({lang:document.documentElement.lang,width:innerWidth,scrollWidth:document.documentElement.scrollWidth,heading:document.querySelector('h1')?.innerText,smallTargets:[...document.querySelectorAll('button,a,summary')].filter(e=>{const r=e.getBoundingClientRect();return r.width>0&&r.height>0&&(r.width<24||r.height<24)}).map(e=>({text:e.textContent?.trim().slice(0,70),w:e.getBoundingClientRect().width,h:e.getBoundingClientRect().height}))})));
    if(width===1440||width===390)await page.screenshot({path:path.join(output,`landing-${lang}-${width}.png`),fullPage:true});
   }
   if(hasAxe){await page.addScriptTag({path:axe});report.axe.push({lang,violations:await page.evaluate(async()=>{const r=await axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}});return r.violations.map(v=>({id:v.id,impact:v.impact,description:v.description,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary})).slice(0,12)}))})});}
  }
  await page.setViewportSize({width:1440,height:1000});
  await page.emulateMedia({reducedMotion:'reduce'});
  await page.emulateMedia({reducedMotion:'reduce'});
  await page.reload({waitUntil:'domcontentloaded'});
  report.flows.push({name:'reduced motion content',result:await page.locator('h1').isVisible()});
  await page.goto('http://127.0.0.1:3000/app',{waitUntil:'domcontentloaded'});
  await page.waitForTimeout(1200);
  report.workspace={title:await page.title(),text:(await page.locator('body').innerText()).slice(0,2200),inputs:await page.locator('input,select').evaluateAll(es=>es.map(e=>({tag:e.tagName,type:e.type,label:e.labels?.[0]?.innerText}))),links:await page.locator('a').evaluateAll(es=>es.map(e=>({text:e.innerText,href:e.getAttribute('href')})))};
  await page.screenshot({path:path.join(output,'workspace-onboarding.png'),fullPage:true});
 }catch(e){report.error=e.stack;process.exitCode=1;}finally{
  await fs.writeFile(path.join(output,'browser-report.json'),JSON.stringify(report,null,2));
  console.log(JSON.stringify(report,null,2));
  await browser.close();
 }
})().catch(e=>{console.error(e);process.exitCode=1});
