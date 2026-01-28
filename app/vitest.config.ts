/// <reference types="vitest" />

import { defineConfig } from 'vite';
// import angular from '@analogjs/vite-plugin-angular';  // only if you're using AnalogJS

export default defineConfig({
  // plugins: [angular()],   // optional / only if needed
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test-setup.ts'],  // adjust path if different
    include: ['src/**/*.spec.ts'],
    // reporters: ['default', 'html'],     // optional
    // coverage: { provider: 'v8' },       // optional
  },
});
