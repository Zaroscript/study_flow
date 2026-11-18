import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import path from 'path';
import { fileURLToPath } from 'url';

const projectDirectory = path.dirname(fileURLToPath(import.meta.url));

export default defineConfig({
  plugins: [react()],
  // Hashed bundles live in /bundle (immutable cache); /assets keeps the unhashed public files (fonts, icons, images).
  build: { assetsDir: 'bundle' },
  resolve: {
    alias: {
      'firebase/app': path.resolve(projectDirectory, 'firebase-mock.ts'),
      'firebase/auth': path.resolve(projectDirectory, 'firebase-mock.ts'),
      'firebase/firestore': path.resolve(projectDirectory, 'firebase-mock.ts'),
    },
  },
  server: {
    port: 3000,
    host: true,
    proxy: {
      '/api/ai': {
        target: 'https://text.pollinations.ai',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api\/ai/, ''),
        headers: {
          'Origin': 'https://pollinations.ai',
          'Referer': 'https://pollinations.ai/',
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        },
      },
    },
  },
});
