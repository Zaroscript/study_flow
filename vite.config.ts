import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  // Hashed bundles live in /bundle (immutable cache); /assets keeps the unhashed public files (fonts, icons, images).
  build: { assetsDir: 'bundle' },
  server: { port: 3000, host: true },
});
