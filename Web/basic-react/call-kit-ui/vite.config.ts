import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
      // dev 模式下用 mock 替换真实 SDK，避免需要真实 NIM 实例
      '@xkit-yx/call-kit': resolve(__dirname, 'demo/mock-call-kit.ts'),
    },
  },
  server: {
    port: 5174,
    watch: {
      usePolling: true,
    },
  },
})
