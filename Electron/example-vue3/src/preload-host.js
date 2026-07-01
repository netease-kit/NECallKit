'use strict';

const {
  createHostApi,
} = require('./runtime-env');
const {
  createCallkitIpcBridge,
} = require('./lib/callkit-ipc-bridge');
const {
  installRendererWindowCloseBridge,
} = require('./lib/window-close-lifecycle');

function installPreloadBridge(options = {}) {
  const host = createHostApi(options);
  if (options.callkitIpc) {
    host.callkit = options.callkitIpc;
  } else if (options.ipcRenderer) {
    host.callkit = createCallkitIpcBridge(options.ipcRenderer);
  }
  const windowTarget =
    options.windowTarget ||
    (typeof window !== 'undefined' ? window : null);

  if (windowTarget) {
    windowTarget.electronCallkitHost = host;
  }
  if (options.ipcRenderer) {
    installRendererWindowCloseBridge({
      ipcRenderer: options.ipcRenderer,
      windowTarget,
    });
  }

  return host;
}

module.exports = {
  installPreloadBridge,
};
