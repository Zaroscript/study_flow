/** Fail closed unless both a provider and durable quota storage are configured. */
const LIMIT_BYTES = 32768;
const headers = { 'Content-Type': 'text/plain; charset=utf-8', 'Cache-Control': 'no-store', 'X-Content-Type-Options': 'nosniff' };
const reply = (status: number, message: string) => new Response(message, { status, headers });

async function readJson(req: Request): Promise<any> {
  const reader = req.body?.getReader();
  if (!reader) throw new Error('invalid-body');
  const chunks: Uint8Array[] = []; let size = 0;
  try {
    while (true) { const {value,done} = await reader.read(); if (done) break;
      size += value.byteLength; if (size > LIMIT_BYTES) { await reader.cancel(); throw new RangeError('body-limit'); } chunks.push(value);
    }
  } finally { reader.releaseLock(); }
  const bytes = new Uint8Array(size); let offset = 0; for (const chunk of chunks) { bytes.set(chunk,offset); offset += chunk.length; }
  return JSON.parse(new TextDecoder().decode(bytes));
}

async function permitted(req: Request): Promise<boolean> {
  const url = process.env.UPSTASH_REDIS_REST_URL;
  const token = process.env.UPSTASH_REDIS_REST_TOKEN;
  if (!url || !token || !url.startsWith('https://')) return false;
  // Vercel supplies this header at the trusted edge; do not deploy behind an untrusted proxy.
  const address = req.headers.get('x-vercel-forwarded-for')?.split(',')[0]?.trim();
  if (!address) return false;
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(`${token}:${address}`));
  const key = `enote:ai:${Math.floor(Date.now()/60000)}:${Array.from(new Uint8Array(digest), x=>x.toString(16).padStart(2,'0')).join('')}`;
  const quota = await fetch(`${url.replace(/\/$/,'')}/pipeline`, {
    method: 'POST', headers: { Authorization: `Bearer ${token}`, 'Content-Type':'application/json' },
    body: JSON.stringify([['INCR',key],['EXPIRE',key,120]]), signal: AbortSignal.timeout(3000),
  });
  if (!quota.ok) return false;
  const result = await quota.json();
  return Array.isArray(result) && typeof result[0]?.result === 'number' && result[0].result <= 8;
}

export default async function handler(req: Request): Promise<Response> {
  if (req.method !== 'POST') return new Response('POST required',{status:405,headers:{...headers,Allow:'POST'}});
  const origin = req.headers.get('origin');
  if ((origin && origin !== new URL(req.url).origin) || req.headers.get('sec-fetch-site') === 'cross-site') return reply(403,'Cross-site request rejected');
  if (!req.headers.get('content-type')?.startsWith('application/json')) return reply(415,'JSON required');
  let input: any;
  try { input = await readJson(req); } catch (error) { return reply(error instanceof RangeError ? 413 : 400,'Invalid request body'); }
  const messages = input?.messages;
  if (!Array.isArray(messages) || messages.length<1 || messages.length>16 || messages.some(m=>!m || !['user','assistant','system'].includes(m.role) || typeof m.content!=='string' || !m.content.trim() || m.content.length>10000)) return reply(400,'Invalid messages');
  const upstream = process.env.ENOTE_AI_UPSTREAM_URL;
  if (process.env.ENOTE_AI_ENABLED !== 'true' || !upstream || !upstream.startsWith('https://')) return reply(503,'Remote AI is not configured. Use the labelled local study tools.');
  try {
    if (!await permitted(req)) return reply(429,'AI request limit reached or quota service unavailable');
    const response = await fetch(upstream,{
      method:'POST',headers:{'Content-Type':'application/json',...(process.env.ENOTE_AI_UPSTREAM_TOKEN?{Authorization:`Bearer ${process.env.ENOTE_AI_UPSTREAM_TOKEN}`}:{})},
      body:JSON.stringify({messages,model:process.env.ENOTE_AI_MODEL || 'openai'}),signal:AbortSignal.timeout(12000),redirect:'error',
    });
    if (!response.ok) return reply(502,'AI provider unavailable');
    const text = await response.text();
    if (!text.trim() || text.length>64000 || text.trim().startsWith('<')) return reply(502,'Invalid AI provider response');
    return reply(200,text);
  } catch { return reply(503,'AI service temporarily unavailable'); }
}
