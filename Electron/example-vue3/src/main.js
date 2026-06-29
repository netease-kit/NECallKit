'use strict';

const path = require('path');
const {
  BrowserWindow,
  Menu,
  app,
  ipcMain,
  powerSaveBlocker,
  shell,
  systemPreferences,
} = require('electron');
const {
  attachWindowDiagnostics,
  installReloadGuard,
  installProcessDiagnostics,
} = require('./lib/example-window-debug');
const {
  applyRuntimeEnv,
  registerMediaPermissionHandler,
  registerWakeLockHandler,
} = require('./runtime-env');
const {
  createCallkitMainService,
} = require('./lib/callkit-main-service');
const {
  attachRendererWindowCloseLifecycle,
} = require('./lib/window-close-lifecycle');
const {
  shouldUseMainSideNativeOwner,
} = require('./lib/main-side-external-ready-probe');

function readBooleanEnv(value) {
  const normalized = typeof value === 'string' ? value.trim().toLowerCase() : '';
  if (!normalized) {
    return false;
  }
  return ['1', 'true', 'yes', 'on'].includes(normalized);
}

function resolveRemoteDebuggingPort(env = process.env) {
  const enabled = readBooleanEnv(env.NECALL_ELECTRON_ENABLE_REMOTE_DEBUGGING);
  const rawPort =
    typeof env.NECALL_ELECTRON_REMOTE_DEBUGGING_PORT === 'string'
      ? env.NECALL_ELECTRON_REMOTE_DEBUGGING_PORT.trim()
      : '';

  if (!enabled && !rawPort) {
    return null;
  }

  if (!rawPort) {
    return 9222;
  }

  const port = Number(rawPort);
  if (!Number.isInteger(port) || port <= 0) {
    console.warn('[example-vue3] ignoring invalid remote debugging port', rawPort);
    return enabled ? 9222 : null;
  }

  return port;
}

function logRemoteDebuggingStatus(env, remoteDebuggingPort) {
  const rawPort =
    typeof env.NECALL_ELECTRON_REMOTE_DEBUGGING_PORT === 'string'
      ? env.NECALL_ELECTRON_REMOTE_DEBUGGING_PORT.trim()
      : '';

  console.log('[example-vue3] remote debugging status', {
    enabled: Boolean(remoteDebuggingPort),
    port: remoteDebuggingPort || null,
    endpoint: remoteDebuggingPort ? `http://127.0.0.1:${remoteDebuggingPort}` : null,
    envEnableRemoteDebugging: env.NECALL_ELECTRON_ENABLE_REMOTE_DEBUGGING || '',
    envRemoteDebuggingPort: rawPort || '',
  });
}

const remoteDebuggingPort = resolveRemoteDebuggingPort(process.env);
if (remoteDebuggingPort) {
  app.commandLine.appendSwitch('remote-debugging-port', String(remoteDebuggingPort));
}
logRemoteDebuggingStatus(process.env, remoteDebuggingPort);

installProcessDiagnostics({
  label: 'example-vue3',
});
applyRuntimeEnv({ app, env: process.env, strict: true });

const wakeLockLifecycle = registerWakeLockHandler({
  ipcMain,
  powerSaveBlocker,
});
const mediaPermissionLifecycle = registerMediaPermissionHandler({
  ipcMain,
  systemPreferences,
  shell,
});
const callkitMainService = shouldUseMainSideNativeOwner({
  platform: process.platform,
  versions: process.versions,
})
  ? createCallkitMainService({ ipcMain })
  : null;
let callkitMainServiceDestroyed = false;

function createWindow() {
  const window = new BrowserWindow({
    width: 1280,
    height: 840,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: false,
      nodeIntegration: true,
    },
  });

  attachWindowDiagnostics(window, {
    label: 'example-vue3',
  });
  installReloadGuard(window, {
    menu: Menu,
  });

  if (callkitMainService) {
    callkitMainService.attachWindowLifecycle(window);
  } else {
    attachRendererWindowCloseLifecycle(window, { ipcMain });
  }

  window.loadFile(path.join(__dirname, 'renderer', 'index.html')).catch((error) => {
    console.error('[example-vue3] loadFile failed', error);
  });
}

app.whenReady().then(createWindow);

app.on('before-quit', (event) => {
  wakeLockLifecycle.release();
  mediaPermissionLifecycle.release();
  if (callkitMainService && !callkitMainServiceDestroyed) {
    event.preventDefault();
    callkitMainServiceDestroyed = true;
    Promise.resolve(callkitMainService.destroyAsync()).finally(() => {
      app.quit();
    });
  }
});
