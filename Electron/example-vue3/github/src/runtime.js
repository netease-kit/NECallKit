'use strict';

const path = require('path');
const { pathToFileURL } = require('url');
const { reactive } = require('vue');
const {
  createElectronRuntime,
} = require('@xkit-yx/callkit-runtime-electron');

// uikit-owned setup-config labels: not exposed in the example renderer's
// createSetupConfig — this uikit injects them at runtime.setup time.
const FRAMEWORK_LABEL = 'electron-vue3';
const CHANNEL_LABEL = 'electron';

const DEFAULT_RING_ASSETS = Object.freeze({
  incomingRingUrl: pathToFileURL(
    require.resolve('./assets/audios/avchat_ring.mp3')
  ).href,
  outgoingRingUrl: pathToFileURL(
    require.resolve('./assets/audios/avchat_connecting.mp3')
  ).href,
});

function createCallkitRuntime(options = {}) {
  return createElectronRuntime(
    Object.assign(
      {
        ringAssets: DEFAULT_RING_ASSETS,
        stateFactory: reactive,
        framework: FRAMEWORK_LABEL,
        channel: CHANNEL_LABEL,
      },
      options
    )
  );
}

// mac IPC topology factory — kept on the uikit boundary so the example
// renderer never has to import src/lib/ipc-callkit-runtime.js or set
// framework/channel by hand. Lazy-required so the helper can resolve from
// either the source tree or the packaged app resources.
function isMissingRequestedModule(error, request) {
  return (
    error &&
    error.code === 'MODULE_NOT_FOUND' &&
    typeof error.message === 'string' &&
    error.message.includes(`Cannot find module '${request}'`)
  );
}

function loadIpcRuntimeFactory() {
  const candidates = ['../../src/lib/ipc-callkit-runtime'];
  if (process.resourcesPath) {
    candidates.push(path.join(
      process.resourcesPath,
      'scripts',
      'lib',
      'ipc-callkit-runtime'
    ));
  }

  const missing = [];
  for (const candidate of candidates) {
    try {
      const helper = require(candidate);
      return helper.createIpcCallkitRuntime;
    } catch (error) {
      if (!isMissingRequestedModule(error, candidate)) {
        throw error;
      }
      missing.push(candidate);
    }
  }

  throw new Error(
    'Cannot find ipc-callkit-runtime helper. Tried: ' + missing.join(', ')
  );
}

function createIpcCallkitRuntime(host, options = {}) {
  const factory = loadIpcRuntimeFactory();
  const hostOptions =
    host && typeof host === 'object' && !options.host ? { host } : {};
  return factory(
    host && host.callkit ? host.callkit : host,
    Object.assign(
      {
        ringAssets: DEFAULT_RING_ASSETS,
        framework: FRAMEWORK_LABEL,
        channel: CHANNEL_LABEL,
      },
      hostOptions,
      options
    )
  );
}

module.exports = {
  createCallkitRuntime,
  createIpcCallkitRuntime,
  // 暴露 DEFAULT_RING_ASSETS 让 mac IPC topology 下 ipc-callkit-runtime.js
  // 通过 createIpcCallkitRuntime(host, { ringAssets }) 拿到铃声 file:// URL
  // 和 preload host 权限方法；ring 事件仍在 renderer 侧用 DOM Audio 播放
  // （main 进程没有 DOM Audio）。
  DEFAULT_RING_ASSETS,
};
