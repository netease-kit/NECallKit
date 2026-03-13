import pkg from './package.json'
import typescript from 'rollup-plugin-typescript2'
import commonjs from 'rollup-plugin-commonjs'
import { terser } from 'rollup-plugin-terser'
import { nodeResolve } from '@rollup/plugin-node-resolve'
import json from '@rollup/plugin-json'

const plugins = [
  typescript({
    tsconfig: './tsconfig.json',
    useTsconfigDeclarationDir: true,
  }),
  nodeResolve({
    mainFields: ['jsnext', 'preferBuiltins', 'browser'],
  }),
  commonjs(),
  json(),
  terser(),
].filter(Boolean)

export default [
  {
    input: './src/index.ts',
    output: [
      {
        file: pkg.module,
        format: 'esm',
        exports: 'named',
      },
      {
        file: pkg.main,
        format: 'cjs',
        exports: 'named',
      },
    ],
    plugins,
    external: [
      '../package.json',
      ...Object.keys(pkg.dependencies || {}),
      ...Object.keys(pkg.peerDependencies || {}),
    ],
  },
  {
    input: './src/index.wx.ts',
    output: [
      {
        file: pkg.miniprogram + '/index.js',
        format: 'cjs',
        exports: 'named',
      },
      {
        file: pkg.miniprogram + '/index.esm.js',
        format: 'esm',
        exports: 'named',
      },
    ],
    plugins,
  },
]
