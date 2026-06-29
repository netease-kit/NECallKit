'use strict';

const vueCore = require('@xkit-yx/callkit-vue3-core');
const { CallViewProvider } = require('./components/CallViewProvider');

function createCallkitRuntime(options) {
  return require('./runtime').createCallkitRuntime(options);
}

function createIpcCallkitRuntime(host, options) {
  return require('./runtime').createIpcCallkitRuntime(host, options);
}

function applyElectronCallKitRuntimeEnv(options) {
  return require('@xkit-yx/electron-callkit-sdk/runtime-env')
    .applyElectronCallKitRuntimeEnv(options);
}

function resolveElectronCallKitRuntimeEnv(options) {
  return require('@xkit-yx/electron-callkit-sdk/runtime-env')
    .resolveElectronCallKitRuntimeEnv(options);
}

function getDefaultRingAssets() {
  return require('./runtime').DEFAULT_RING_ASSETS;
}

module.exports = Object.assign({}, vueCore, {
  CallViewProvider,
  applyElectronCallKitRuntimeEnv,
  createCallkitRuntime,
  createIpcCallkitRuntime,
  resolveElectronCallKitRuntimeEnv,
  // mac IPC topology 下渲染端用：拿 file:// URL 给 ipc-callkit-runtime 的 Audio 播放
  get DEFAULT_RING_ASSETS() {
    return getDefaultRingAssets();
  },
});
