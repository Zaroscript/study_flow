const fs=require('node:fs/promises');
const path=require('node:path');
const os=require('node:os');
const {createRequire}=require('node:module');
const {chromium}=createRequire(path.join(os.homedir(),'.cache/codex-runtimes/codex-primary-runtime/dependencies/node/package.json'))('playwright');
(async()=>{
 const output=path.resolve(__dirname,'../screenshots/audit-2026-11-17');await fs.mkdir(output,{recursive:true});
 const browser=await chromium.launch({headless:true,executablePath:path.join(os.homedir(),'AppData/Local/ms-playwright/chromium-1187/chrome-win/chrome.exe')});
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'});
 await context.addInitScript(()=>{localStorage.setItem('studyflow_data',JSON.stringify({profile:{name:'Audit User',grade:'المرحلة الثانوية'}}));});
 const page=await context.newPage();const report={layouts:[],accessibility:[],errors:[],corruption:null};
 page.on('pageerror',e=>report.errors.push(e.message));
 const routes=['dashboard','planner','pomodoro','materials','ai','rewards','homework','goals','habits','notes','settings'];
 const axe=require.resolve('axe-core/axe.min.js');const hasAxe=await fs.access(axe).then(()=>true).catch(()=>false);
 try{
  await page.goto('http://127.0.0.1:3000/app',{waitUntil:'domcontentloaded'});
  await page.locator('.sf-shell').waitFor({timeout:45000});
  for(const language of ['ar','en']){
   await page.evaluate(()=>location.hash='settings');
   await page.locator('#app-language').selectOption(language);
   for(const theme of ['light','dark']){
    const current=await page.evaluate(()=>document.body.classList.contains('dark')?'dark':'light');
    if(current!==theme)await page.locator('.sf-topbar-actions button').click();
    for(const width of [390,1440]){
     await page.setViewportSize({width,height:width===390?844:1000});
     for(const id of routes){
      await page.evaluate(id=>location.hash=id,id);await page.waitForTimeout(180);
      const visible=page.locator(`.screen-${id}:visible`);await visible.waitFor({timeout:10000});
      report.layouts.push({language,theme,width,id,...await page.evaluate(()=>({overflow:document.documentElement.scrollWidth>innerWidth+1,unnamed:[...document.querySelectorAll('main button')].filter(e=>{const r=e.getBoundingClientRect();return r.width>0&&r.height>0&&!e.textContent.trim()&&!e.getAttribute('aria-label')&&!e.title}).length}))});
      if((language==='ar'&&theme==='light'&&width===1440)||(language==='en'&&theme==='dark'&&width===390))await page.screenshot({path:path.join(output,`web-${language}-${theme}-${width}-${id}.png`),fullPage:true});
      if(hasAxe&&language==='en'&&theme==='light'&&width===1440){await page.addScriptTag({path:axe});report.accessibility.push({id,language,theme,width,violations:await page.evaluate(async()=>{const r=await axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}});return r.violations.map(v=>({id:v.id,impact:v.impact,nodes:v.nodes.map(n=>({target:n.target,summary:n.failureSummary})).slice(0,6)}));})});}
     }
     console.log(`Checked ${language}/${theme}/${width}: ${routes.length} screens`);
    }
   }
  }
  const bad=await browser.newContext();await bad.addInitScript(()=>localStorage.setItem('studyflow_data',JSON.stringify({profile:{name:'Audit',grade:'Other'},tasks:null})));
  const badPage=await bad.newPage();const badErrors=[];badPage.on('pageerror',e=>badErrors.push(e.message));
  await badPage.goto('http://127.0.0.1:3000/app',{waitUntil:'domcontentloaded'});await badPage.waitForTimeout(1500);
  report.corruption={fixture:'valid JSON with tasks:null',errors:badErrors,bodyLength:(await badPage.locator('body').innerText()).length};
  await bad.close();
 }catch(e){report.error=e.stack;process.exitCode=1;}finally{await fs.writeFile(path.join(output,'workspace-report.json'),JSON.stringify(report,null,2));console.log(JSON.stringify({layouts:report.layouts.length,overflow:report.layouts.filter(x=>x.overflow),unnamed:report.layouts.filter(x=>x.unnamed),accessibility:report.accessibility,errors:report.errors,corruption:report.corruption,error:report.error},null,2));await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1});
