/* Executes the real proxy handler with a fake upstream. No request leaves this process. */
const fs = require('node:fs/promises');
const path = require('node:path');
const { createRequire } = require('node:module');
const esbuild = createRequire(require.resolve('vite/package.json'))('esbuild');
(async()=>{
 const source=await fs.readFile(path.resolve(__dirname,'../api/ai.ts'),'utf8');
 const {code}=esbuild.transformSync(source,{loader:'ts',format:'esm'});
 const {default:handler}=await import('data:text/javascript;base64,'+Buffer.from(code).toString('base64'));
 const originalFetch=global.fetch;
 const calls=[];
 global.fetch=async(url,init)=>{calls.push({url:String(url),method:init?.method,bodyBytes:Buffer.byteLength(init?.body||'')});return new Response('stubbed upstream',{status:200});};
 const results=[];
 try{
  for(const body of [{messages:[{role:'user',content:'sample'}]},{messages:[{role:'unknown',content:'x'.repeat(300000)}],model:'unvalidated-model'}]){
   const before=calls.length;
   const res=await handler(new Request('https://audit.invalid/api/ai',{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)}));
   results.push({authenticated:false,inputBytes:Buffer.byteLength(JSON.stringify(body)),status:res.status,upstreamCalled:calls.length>before,cors:res.headers.get('Access-Control-Allow-Origin')});
  }
 }finally{global.fetch=originalFetch;}
 console.log(JSON.stringify({network:'stubbed; no external requests',results,calls},null,2));
})().catch(e=>{console.error(e);process.exitCode=1});
