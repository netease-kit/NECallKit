'use strict';

const path = require('node:path');

const cliContext = process.env.UNI_CLI_CONTEXT;
const uni = cliContext
  ? require(path.join(
    cliContext,
    'node_modules/@dcloudio/vite-plugin-uni'
  )).default
  : null;

const harmonyExternalDependencies = [
  '@dcloudio/uni-app-runtime',
  '@yunxin/callkit',
  '@yunxin/callkit_ui',
  '@nimsdk/base',
  '@nimsdk/nim',
  '@nimsdk/message',
  '@nimsdk/signalling',
  '@nimsdk/user',
];

module.exports = {
  plugins: cliContext ? [uni()] : [],
  build: {
    rollupOptions: {
      external: process.env.UNI_PLATFORM === 'app-harmony'
        ? harmonyExternalDependencies
        : [],
    },
  },
};
