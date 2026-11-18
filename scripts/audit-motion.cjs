const fs=require('node:fs/promises'),path=require('node:path'),os=require('node:os');
const {createRequire}=require('node:module');
const {chromium}=createRequire(path.join(os.homedir(),'.cache/codex-runtimes/codex-primary-runtime/dependencies/node/package.json'))('playwright');
(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:path.join(os.homedir(),'AppData/Local/ms-playwright/chromium-1187/chrome-win/chrome.exe')});
 const page=await browser.newPage({viewport:{width:1440,height:1000}});
 const capture=()=>page.evaluate(()=>({scrollY,heading:[...document.querySelectorAll('.lp-hero h1')].map(e=>({text:e.innerText,opacity:getComputedStyle(e).opacity,visibility:getComputedStyle(e).visibility})),phone:[...document.querySelectorAll('.lp-hero-phone-wrap')].map(e=>({opacity:getComputedStyle(e).opacity,visibility:getComputedStyle(e).visibility}))}));
 const out=path.resolve(__dirname,'../screenshots/audit-2026-11-17');
 try{
  await page.goto('http://127.0.0.1:3000/?lang=en',{waitUntil:'domcontentloaded'});await page.waitForTimeout(3500);
  const initial=await capture();const queryLanguage=await page.locator('html').getAttribute('lang');
  await page.evaluate(()=>window.scrollTo({top:0,behavior:'instant'}));await page.waitForTimeout(3500);
  const top=await capture();await page.screenshot({path:path.join(out,'landing-desktop-top.png')});
  await page.emulateMedia({reducedMotion:'reduce'});await page.reload({waitUntil:'domcontentloaded'});await page.waitForTimeout(1000);
  const reduced=await capture();await page.evaluate(()=>window.scrollTo({top:0,behavior:'instant'}));await page.screenshot({path:path.join(out,'landing-desktop-reduced.png')});
  const result={queryLanguage,initial,top,reduced};await fs.writeFile(path.join(out,'motion-report.json'),JSON.stringify(result,null,2));console.log(JSON.stringify(result,null,2));
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
