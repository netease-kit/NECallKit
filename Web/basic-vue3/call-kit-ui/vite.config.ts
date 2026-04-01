import { resolve } from 'path'
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'
import dts from 'vite-plugin-dts'

const projectRoot = __dirname
const entry = resolve(projectRoot, 'src/index.ts')
const external = [
  'vue',
  '@xkit-yx/call-kit',
  'nim-web-sdk-ng',
  '@xkit-yx/utils',
  'swiper',
  'swiper/vue',
]

export default defineConfig({
  plugins: [
    vue(),
    dts({
      tsconfigPath: resolve(projectRoot, 'tsconfig.json'),
      entryRoot: resolve(projectRoot, 'src'),
      outDir: 'es',
      insertTypesEntry: true,
      copyDtsFiles: true,
    }),
  ],
  build: {
    emptyOutDir: true,
    cssCodeSplit: true,
    lib: {
      entry,
      name: 'NECallKitVue3UI',
    },
    rollupOptions: {
      external,
      output: [
        {
          format: 'es',
          dir: 'es',
          preserveModules: true,
          preserveModulesRoot: 'src',
          entryFileNames: '[name].js',
          chunkFileNames: 'chunks/[name]-[hash].js',
          assetFileNames: 'assets/[name][extname]',
        },
        {
          format: 'cjs',
          dir: 'lib',
          preserveModules: true,
          preserveModulesRoot: 'src',
          exports: 'named',
          entryFileNames: '[name].js',
          chunkFileNames: 'chunks/[name]-[hash].js',
          assetFileNames: 'assets/[name][extname]',
        },
      ],
    },
  },
})
