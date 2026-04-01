import { resolve } from 'path'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  base: './',
  plugins: [vue()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      '@xkit-yx/call-kit-vue3-ui': resolve(
        __dirname,
        'call-kit-ui/src/index.ts'
      ),
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
