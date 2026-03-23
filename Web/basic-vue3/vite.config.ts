import { resolve } from 'path'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  base: './',
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@xkit-yx/call-kit': resolve(__dirname, '../call-kit/src/index.ts'),
      '@xkit-yx/call-kit-vue3-ui': resolve(
        __dirname,
        'call-kit-ui/src/index.ts'
      ),
      'nim-web-sdk-ng': resolve(__dirname, 'node_modules/nim-web-sdk-ng'),
    },
  },
  server: {
    port: 5175,
    host: '0.0.0.0',
    watch: {
      usePolling: true,
    },
  },
})
