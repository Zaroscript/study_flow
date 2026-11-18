/* Browser regression suite; uses installed Playwright or Codex's bundled runtime. */
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');
const path = require('node:path');
const os = require('node:os');
const { createRequire } = require('node:module');
const root = path.resolve(__dirname, '..');
let playwright;
try { playwright = require('playwright'); } catch {
  playwright = createRequire(path.join(os.homedir(), '.cache/codex-runtimes/codex-primary-runtime/dependencies/node/package.json'))('playwright');
}
const output = path.join(root, 'screenshots/quality-pass');
const report = { flows: [], layouts: [], accessibility: [], errors: [] };
async function run() {
  const cached = path.join(os.homedir(), 'AppData/Local/ms-playwright');
  const folders = await fs.readdir(cached).catch(()=>[]);
  const candidates = folders.filter(name=>/^chromium-\d+$/.test(name)).sort().reverse();
  const executablePath = process.env.ENOTE_BROWSER_PATH || (candidates[0] && path.join(cached,candidates[0],'chrome-win/chrome.exe'));
  const browser = await playwright.chromium.launch({headless:true,...(executablePath?{executablePath}:{})});
  const context = await browser.newContext({viewport:{width:390,height:844},hasTouch:true});
  const page = await context.newPage();
  page.setDefaultTimeout(7000);
  page.on('pageerror', error=>report.errors.push(error.message));
  const axe = process.env.ENOTE_AXE_PATH || require.resolve('axe-core/axe.min.js');
  const axeAvailable = await fs.access(axe).then(()=>true).catch(()=>false);
  const navigate = async label => {
    const link=page.locator('.sf-sidebar nav').getByRole('link',{name:label,exact:true});
    if (!await link.isVisible()) await page.getByRole('button',{name:await page.locator('html').getAttribute('lang')==='en'?'Open menu':'فتح القائمة',exact:true}).click();
    await link.click();
  };
  const check = name => { report.flows.push(name); console.log(`PASS ${name}`); };
  try {
    await page.goto(process.env.ENOTE_BASE_URL || 'http://localhost:3000/app',{waitUntil:'domcontentloaded'});
    await page.getByLabel('اللغة',{exact:true}).selectOption('en');
    await page.getByLabel('Full name',{exact:true}).fill('Alex Smith');
    await page.getByLabel('Education level',{exact:true}).selectOption('المرحلة الثانوية');
    await page.getByRole('button',{name:'Start your journey',exact:true}).click();
    await navigate('Daily planner');
    await page.getByRole('button',{name:'New task',exact:true}).click();
    await page.getByRole('button',{name:'Save task',exact:true}).click();
    assert.equal(await page.getByRole('dialog').isVisible(),true);
    assert.equal(await page.getByLabel('Task title',{exact:true}).evaluate(e=>e.validity.valueMissing),true);
    await page.getByLabel('Task title',{exact:true}).fill('   ');
    assert.equal(await page.getByLabel('Task title',{exact:true}).evaluate(e=>e.checkValidity()),false);
    await page.getByLabel('Task title',{exact:true}).fill('Quality test task');
    await page.getByLabel('Start time',{exact:true}).fill('14:00');
    await page.getByLabel('End time',{exact:true}).fill('14:00');
    await page.getByRole('button',{name:'Save task',exact:true}).click();
    assert.equal(await page.getByText('End time must be after start time.',{exact:true}).isVisible(),true);
    await page.getByLabel('End time',{exact:true}).fill('15:00');
    await page.getByLabel('Task title',{exact:true}).press('Enter');
    assert.equal(await page.getByRole('heading',{name:'Quality test task',exact:true}).isVisible(),true);
    check('Task validation and Enter submission');
    await page.getByRole('button',{name:'Complete Quality test task',exact:true}).click();
    assert.equal(await page.getByRole('button',{name:'Complete Quality test task',exact:true}).getAttribute('aria-pressed'),'true');
    await page.getByRole('button',{name:'Delete Quality test task',exact:true}).click();
    assert.equal(await page.getByRole('heading',{name:'Quality test task',exact:true}).count(),0);
    await page.getByRole('button',{name:'Undo',exact:true}).click();
    assert.equal(await page.getByRole('heading',{name:'Quality test task',exact:true}).count(),1);
    check('Complete, delete and restore a task');
    await page.reload({waitUntil:'domcontentloaded'});
    assert.equal(await page.locator('html').getAttribute('lang'),'en');
    assert.equal(await page.locator('.sf-page-header h1:visible').innerText(),'Daily planner');
    await navigate('Goals');
    await page.evaluate(()=>history.back());
    await page.waitForFunction(()=>location.hash==='#planner');
    await page.getByRole('heading',{name:'Daily planner',exact:true}).waitFor();
    check('Screen, language and saved task survive reload; Back navigation works');
    await navigate('Goals');
    await page.getByRole('button',{name:'New goal',exact:true}).click();
    await page.getByLabel('Goal title',{exact:true}).fill('Valid goal');
    await page.getByLabel('Total target',{exact:true}).fill('0');
    await page.getByRole('button',{name:'Save goal',exact:true}).click();
    assert.equal(await page.getByLabel('Total target',{exact:true}).evaluate(e=>e.validity.rangeUnderflow),true);
    await page.getByLabel('Total target',{exact:true}).fill('2');
    await page.getByLabel('Current progress',{exact:true}).fill('3');
    await page.getByRole('button',{name:'Save goal',exact:true}).click();
    assert.equal(await page.getByLabel('Current progress',{exact:true}).evaluate(e=>e.validity.rangeOverflow),true);
    await page.keyboard.press('Escape');
    check('Goal validation rejects zero targets and excess progress');
    await navigate('Notes');
    await page.getByRole('button',{name:'New note',exact:true}).click();
    const longContent='A full note that must remain readable.\n'.repeat(25);
    await page.getByLabel('Title',{exact:true}).fill('Quality Notes');
    await page.getByLabel('Content',{exact:true}).fill(longContent);
    await page.getByRole('button',{name:'Save note',exact:true}).click();
    await page.getByLabel('Search notes',{exact:true}).fill('quality notes');
    await page.getByRole('button',{name:'Open Quality Notes',exact:true}).click();
    assert.equal(await page.getByLabel('Content',{exact:true}).inputValue(),longContent);
    await page.getByLabel('Content',{exact:true}).fill(longContent+'Edited');
    await page.getByRole('button',{name:'Save note',exact:true}).click();
    await page.getByRole('button',{name:'Open Quality Notes',exact:true}).click();
    assert.equal((await page.getByLabel('Content',{exact:true}).inputValue()).endsWith('Edited'),true);
    await page.getByRole('button',{name:'Delete note',exact:true}).click();
    await page.getByRole('button',{name:'Undo',exact:true}).click();
    assert.equal(await page.getByRole('button',{name:'Open Quality Notes',exact:true}).count(),1);
    check('Case-insensitive note search, full-content editing and undo');
    await navigate('Focus timer');
    await page.getByRole('button',{name:'Start focusing',exact:true}).click();
    await navigate('Home');
    await page.waitForTimeout(1300);
    await navigate('Focus timer');
    assert.equal(await page.getByRole('button',{name:'Pause',exact:true}).isVisible(),true);
    assert.match(await page.getByRole('timer').getAttribute('aria-label'), /24.*59|24.*58|24.*57/);
    await page.getByRole('button',{name:'Pause',exact:true}).click();
    await page.getByRole('button',{name:'Timer settings (minutes)',exact:true}).click();
    await page.getByLabel('Focus time (minutes)',{exact:true}).fill('0');
    await page.getByRole('button',{name:'Save changes',exact:true}).click();
    assert.equal(await page.getByLabel('Focus time (minutes)',{exact:true}).evaluate(e=>e.validity.rangeUnderflow),true);
    await page.keyboard.press('Escape');
    check('Timer survives navigation and rejects invalid settings');
    await page.getByRole('button',{name:'Open menu',exact:true}).click();
    for(let index=0;index<15;index++){await page.keyboard.press('Tab');assert.equal(await page.evaluate(()=>document.activeElement.closest('.sf-sidebar')!==null),true);}
    assert.equal(await page.locator('main').getAttribute('inert'),'');
    await page.keyboard.press('Escape');
    assert.equal(await page.locator('.sf-sidebar').getAttribute('aria-hidden'),'true');
    await page.waitForTimeout(300);
    check('Drawer traps focus, makes background inert and closes with Escape');
    await navigate('Settings');
    const dataBefore=await page.evaluate(()=>localStorage.getItem('studyflow_data'));
    await page.getByLabel('Language',{exact:true}).selectOption('ar');
    assert.equal(await page.locator('html').getAttribute('dir'),'rtl');
    assert.equal(await page.evaluate(()=>localStorage.getItem('studyflow_data')),dataBefore);
    await page.getByLabel('اللغة',{exact:true}).selectOption('en');
    check('Switching languages preserves all user content');
    const routes=[['dashboard','Home'],['planner','Daily planner'],['pomodoro','Focus timer'],['homework','Homework'],['goals','Goals'],['habits','Habits'],['notes','Notes'],['materials','Materials & Library'],['ai','AI Assistant'],['rewards','Rewards & Trophies'],['settings','Settings']];
    const arabic=['الرئيسية','المخطط اليومي','مؤقت التركيز','الواجبات','الأهداف','العادات','الملاحظات','المكتبة والملازم','المساعد الذكي','المكافآت والجوائز','الإعدادات'];
    await fs.mkdir(path.join(output,'after'),{recursive:true});
    for(const language of ['en','ar']){
      await page.setViewportSize({width:1440,height:1000});
      await navigate(await page.locator('html').getAttribute('lang')==='en'?'Settings':'الإعدادات');
      await page.locator('#app-language').selectOption(language);
      for(const theme of ['light','dark']){
        const current=await page.evaluate(()=>document.body.classList.contains('dark')?'dark':'light');
        if(current!==theme)await page.locator('.sf-topbar-actions button').click();
        for(const width of [390,820,1440]){
          await page.setViewportSize({width,height:width===390?844:1000});
          await page.waitForTimeout(220);
          for(let index=0;index<routes.length;index++){
            const [id,en]=routes[index];await navigate(language==='en'?en:arabic[index]);
            await page.waitForTimeout(80);
            const overflow=await page.evaluate(()=>document.documentElement.scrollWidth>innerWidth+1);
            const unnamed=await page.locator('main button').evaluateAll(elements=>elements.filter(element=>{const rect=element.getBoundingClientRect();return rect.width>0&&rect.height>0&&!element.textContent.trim()&&!element.getAttribute('aria-label')&&!element.title}).length);
            report.layouts.push({id,language,theme,width,overflow,unnamed});
            assert.equal(overflow,false,`${id}: overflow at ${language}/${theme}/${width}`);
            assert.equal(unnamed,0,`${id}: unnamed controls`);
            if(width!==820 && (theme==='light'||language==='en'))await page.screenshot({path:path.join(output,'after',`${language}-${theme}-${width}-${id}.png`),fullPage:true});
            if(axeAvailable && language==='en' && width===1440){
              await page.addScriptTag({path:axe});
              const violations=await page.evaluate(async()=>{const result=await axe.run(document,{runOnly:{type:'tag',values:['wcag2a','wcag2aa','wcag21aa','wcag22aa']}});return result.violations.map(issue=>({id:issue.id,impact:issue.impact,nodes:issue.nodes.map(node=>({target:node.target,summary:node.failureSummary}))}));});
              report.accessibility.push({id,theme,violations});
            }
          }
          console.log(`CHECKED ${language}/${theme}/${width}: ${routes.length} screens`);
        }
      }
    }
    assert.deepEqual(report.errors,[]);
    const failed=report.accessibility.filter(result=>result.violations.length);
    await fs.writeFile(path.join(output,'verification.json'),JSON.stringify(report,null,2));
    console.log(JSON.stringify({flows:report.flows.length,layouts:report.layouts.length,axeScans:report.accessibility.length,axeScreensWithViolations:failed.length,errors:report.errors.length}));
    assert.equal(failed.length,0,'Accessibility findings remain; see verification.json');
  } finally {
    await fs.writeFile(path.join(output,'verification.json'),JSON.stringify(report,null,2));
    await browser.close();
  }
}
run().catch(error=>{console.error(error);process.exitCode=1});
