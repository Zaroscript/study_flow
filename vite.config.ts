import { defineConfig, type Plugin } from 'vite';
import react from '@vitejs/plugin-react';

// Production (Vercel, cleanUrls) serves /privacy from privacy.html. Vite's dev and preview servers fall back to
// index.html for extension-less paths, which opened the landing page instead. Mirror cleanUrls for that page.
const privacyCleanUrl = (): Plugin => {
  const rewrite = (req: { url?: string }, _res: unknown, next: () => void) => {
    if (req.url && /^\/privacy(?=[?#]|$)/.test(req.url)) req.url = req.url.replace(/^\/privacy/, '/privacy.html');
    next();
  };
  return {
    name: 'enote-privacy-clean-url',
    configureServer: (server) => void server.middlewares.use(rewrite),
    configurePreviewServer: (server) => void server.middlewares.use(rewrite),
  };
};

export default defineConfig({
  plugins: [react(), privacyCleanUrl()],
  // Hashed bundles live in /bundle (immutable cache); /assets keeps the unhashed public files (fonts, icons, images).
  build: { assetsDir: 'bundle' },
  server: { port: 3000, host: true },
});
