/* Real gateway, stubbed quota/provider. No external requests or real user data. */
const assert=require('node:assert/strict');
const {createRequire}=require('node:module');
const esbuild=createRequire(require.resolve('vite/package.json'))('esbuild');
(async()=>{
 const build=esbuild.buildSync({entryPoints:['server/ai-gateway.ts'],bundle:true,write:false,format:'esm',platform:'node'});
 const {default:handler}=await import('data:text/javascript;base64,'+Buffer.from(build.outputFiles[0].text).toString('base64'));
 const request=(body,extra={})=>new Request('https://enote.invalid/api/ai',{method:'POST',headers:{'Content-Type':'application/json','Origin':'https://enote.invalid','x-vercel-forwarded-for':'192.0.2.1',...extra},body:JSON.stringify(body)});
 const body={messages:[{role:'user',content:'Synthetic test prompt'}]};
 const oldFetch=global.fetch;const oldEnv={...process.env};let providerCalls=0,quota=0;
 try{
  process.env.ENOTE_AI_ENABLED='false';
  assert.equal((await handler(request(body))).status,503);
  assert.equal((await handler(new Request('https://enote.invalid/api/ai'))).status,405);
  assert.equal((await handler(request(body,{'Origin':'https://other.invalid'}))).status,403);
  assert.equal((await handler(request({messages:[{role:'unknown',content:'x'}]}))).status,400);
  assert.equal((await handler(request({messages:[{role:'user',content:'x'.repeat(40000)}]}))).status,413);
  Object.assign(process.env,{ENOTE_AI_ENABLED:'true',ENOTE_AI_UPSTREAM_URL:'https://provider.invalid/text',UPSTASH_REDIS_REST_URL:'https://quota.invalid',UPSTASH_REDIS_REST_TOKEN:'synthetic-test-token'});
  global.fetch=async(url,init)=>{
   assert.equal(init.method,'POST');assert.ok(!String(url).includes('Synthetic'));
   if(String(url).includes('quota.invalid'))return Response.json([{result:++quota},{result:1}]);
   providerCalls++;return new Response('Synthetic study answer');
  };
  for(let i=0;i<8;i++)assert.equal((await handler(request(body))).status,200);
  assert.equal((await handler(request(body))).status,429);
  assert.equal(providerCalls,8);
  console.log('PASS gateway: method, origin, schema, size, disabled mode, durable quota and POST-only provider');
 }finally{global.fetch=oldFetch;for(const key of Object.keys(process.env))if(!(key in oldEnv))delete process.env[key];Object.assign(process.env,oldEnv);}
})().catch(error=>{console.error(error);process.exitCode=1});
