// api/ai.ts - Vercel Edge Serverless Proxy for Pollinations AI LLM
// Forwards requests server-side with authentic browser headers to prevent Cloudflare Turnstile blocks

export const config = {
  runtime: 'edge',
};

const UPSTREAM_BASE = 'https://text.pollinations.ai';
const BROWSER_HEADERS: Record<string, string> = {
  'Origin': 'https://pollinations.ai',
  'Referer': 'https://pollinations.ai/',
  'User-Agent':
    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
  'Accept': '*/*',
};

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
};

export default async function handler(req: Request): Promise<Response> {
  // 1. Handle CORS Pre-flight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: CORS_HEADERS,
    });
  }

  try {
    const url = new URL(req.url);

    // 2. Handle POST request (preferred for long texts, summaries, and chat history)
    if (req.method === 'POST') {
      const body = await req.json().catch(() => ({}));
      
      let messages = body.messages;
      if (!Array.isArray(messages) || messages.length === 0) {
        messages = [];
        if (body.system) {
          messages.push({ role: 'system', content: String(body.system) });
        }
        if (body.prompt) {
          messages.push({ role: 'user', content: String(body.prompt) });
        }
      }

      const model = body.model || 'openai';
      const seed = body.seed || Math.floor(Math.random() * 999999);

      const upstreamRes = await fetch(`${UPSTREAM_BASE}/`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          ...BROWSER_HEADERS,
        },
        body: JSON.stringify({
          messages,
          model,
          seed,
        }),
      });

      const responseText = await upstreamRes.text();
      return new Response(responseText, {
        status: upstreamRes.status,
        headers: {
          'Content-Type': 'text/plain; charset=utf-8',
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          ...CORS_HEADERS,
        },
      });
    }

    // 3. Handle GET request (fallback or direct parameterized calls)
    let prompt = url.searchParams.get('prompt') || '';
    if (!prompt) {
      // Check if prompt was passed in pathname: /api/ai/<prompt>
      const pathname = url.pathname.replace(/^\/api\/ai\/?/, '');
      if (pathname) {
        prompt = decodeURIComponent(pathname);
      }
    }

    if (!prompt) {
      return new Response(
        JSON.stringify({ error: 'No prompt provided. Send "prompt" query parameter or POST body.' }),
        {
          status: 400,
          headers: {
            'Content-Type': 'application/json',
            ...CORS_HEADERS,
          },
        }
      );
    }

    const model = url.searchParams.get('model') || 'openai';
    const system = url.searchParams.get('system') || '';
    const seed = url.searchParams.get('seed') || `${Math.floor(Math.random() * 999999)}`;

    const targetUrl = new URL(`${UPSTREAM_BASE}/${encodeURIComponent(prompt)}`);
    targetUrl.searchParams.set('model', model);
    if (system) targetUrl.searchParams.set('system', system);
    if (seed) targetUrl.searchParams.set('seed', seed);

    const upstreamRes = await fetch(targetUrl.toString(), {
      method: 'GET',
      headers: BROWSER_HEADERS,
    });

    const responseText = await upstreamRes.text();
    return new Response(responseText, {
      status: upstreamRes.status,
      headers: {
        'Content-Type': 'text/plain; charset=utf-8',
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        ...CORS_HEADERS,
      },
    });
  } catch (err: any) {
    return new Response(
      JSON.stringify({ error: 'AI Proxy failure', details: err?.message || String(err) }),
      {
        status: 502,
        headers: {
          'Content-Type': 'application/json',
          ...CORS_HEADERS,
        },
      }
    );
  }
}
