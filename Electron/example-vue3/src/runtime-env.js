'use strict';

const fs = require('fs');
const path = require('path');
const { pathToFileURL } = require('url');
const {
  applyElectronCallKitRuntimeEnv,
  resolveElectronCallKitRuntimeEnv,
} = require('@xkit-yx/electron-callkit-vue3-uikit/runtime-env');

const WAKE_LOCK_CHANNEL = 'necallkit:set-wake-lock';
const MEDIA_PERMISSION_QUERY_CHANNEL = 'necallkit:get-media-permission';
const MEDIA_PERMISSION_REQUEST_CHANNEL = 'necallkit:request-media-permission';
const MEDIA_PERMISSION_OPEN_SETTINGS_CHANNEL = 'necallkit:open-privacy-settings';
const AUTO_LOG_DIR_ENV = 'NECALL_AUTO_NATIVE_LOG_DIR';
const AUTO_LOG_DIR_PID_ENV = 'NECALL_AUTO_NATIVE_LOG_DIR_PID';

const PRIVACY_SETTINGS_DEEP_LINKS = Object.freeze({
  darwin: Object.freeze({
    microphone:
      'x-apple.systempreferences:com.apple.preference.security?Privacy_Microphone',
    camera:
      'x-apple.systempreferences:com.apple.preference.security?Privacy_Camera',
  }),
  win32: Object.freeze({
    microphone: 'ms-settings:privacy-microphone',
    camera: 'ms-settings:privacy-webcam',
  }),
  linux: Object.freeze({}),
});

function resolvePrivacySettingsDeepLink(platform, device) {
  const table = PRIVACY_SETTINGS_DEEP_LINKS[platform];
  if (!table) {
    return '';
  }
  return table[device] || '';
}

function safeGetAppPath(app, name) {
  if (!app || typeof app.getPath !== 'function') {
    return '';
  }

  try {
    const value = app.getPath(name);
    return typeof value === 'string' ? value : '';
  } catch (error) {
    console.warn('[necallkit-runtime-env] failed to resolve app path', {
      name,
      message: error && error.message ? error.message : String(error),
    });
    return '';
  }
}

function resolveProcessId(options = {}) {
  const processLike = options.processLike || process;
  const pid = Number(options.pid || (processLike && processLike.pid));
  return Number.isFinite(pid) && pid > 0 ? String(pid) : 'unknown';
}

function resolveNativeLogDirectory(options = {}) {
  const env = options.env || process.env;
  const fsModule = options.fsModule || fs;
  const pathModule = options.pathModule || path;

  if (typeof env.NE_CALL_LOG_DIR === 'string' && env.NE_CALL_LOG_DIR.trim()) {
    return env.NE_CALL_LOG_DIR;
  }

  const userDataPath = safeGetAppPath(options.app, 'userData');
  if (!userDataPath) {
    return '';
  }

  const logDir = pathModule.join(
    userDataPath,
    'necallkit-native',
    `pid-${resolveProcessId(options)}`
  );
  try {
    fsModule.mkdirSync(logDir, { recursive: true });
    return logDir;
  } catch (error) {
    console.warn('[necallkit-runtime-env] failed to prepare native log dir', {
      logDir,
      message: error && error.message ? error.message : String(error),
    });
    return '';
  }
}

function mapRuntimeEnvResult(result) {
  return {
    nodeAddonPath: result.paths.nodeAddonPath,
    desktopBridgePath: result.paths.desktopBridgePath,
    nodeNimRuntimePath: result.paths.nimRuntimePath,
  };
}

function resolveRuntimeEnv(options = {}) {
  return mapRuntimeEnvResult(resolveElectronCallKitRuntimeEnv(options));
}

function applyRuntimeEnv(options = {}) {
  const env = options.env || process.env;
  const currentPid = resolveProcessId(options);
  const hasAutoLogDir = env[AUTO_LOG_DIR_ENV] === '1';

  if (
    !env.NE_CALL_LOG_DIR ||
    (hasAutoLogDir && env[AUTO_LOG_DIR_PID_ENV] !== currentPid)
  ) {
    const logDir = resolveNativeLogDirectory(options);
    if (logDir) {
      env.NE_CALL_LOG_DIR = logDir;
      env[AUTO_LOG_DIR_ENV] = '1';
      env[AUTO_LOG_DIR_PID_ENV] = currentPid;
    }
  }

  return mapRuntimeEnvResult(applyElectronCallKitRuntimeEnv(options));
}

function createHostApi(options = {}) {
  const host = {
    framework: options.framework || '',
  };

  if (options.incomingRingUrl) {
    host.incomingRingUrl = options.incomingRingUrl;
  } else if (options.incomingRingAssetPath) {
    host.incomingRingUrl = (
      options.pathToFileURL || pathToFileURL
    )(options.incomingRingAssetPath).href;
  }

  if (options.outgoingRingUrl) {
    host.outgoingRingUrl = options.outgoingRingUrl;
  } else if (options.outgoingRingAssetPath) {
    host.outgoingRingUrl = (
      options.pathToFileURL || pathToFileURL
    )(options.outgoingRingAssetPath).href;
  }

  const ipcRenderer = options.ipcRenderer;
  const wakeLockChannel = options.wakeLockChannel || WAKE_LOCK_CHANNEL;
  const mediaQueryChannel =
    options.mediaPermissionQueryChannel || MEDIA_PERMISSION_QUERY_CHANNEL;
  const mediaRequestChannel =
    options.mediaPermissionRequestChannel || MEDIA_PERMISSION_REQUEST_CHANNEL;
  const mediaOpenSettingsChannel =
    options.mediaPermissionOpenSettingsChannel ||
    MEDIA_PERMISSION_OPEN_SETTINGS_CHANNEL;

  host.acquireWakeLock = function acquireWakeLock() {
    if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
      return Promise.resolve(0);
    }
    return ipcRenderer.invoke(wakeLockChannel, {
      enabled: true,
    });
  };

  host.releaseWakeLock = function releaseWakeLock() {
    if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
      return Promise.resolve(0);
    }
    return ipcRenderer.invoke(wakeLockChannel, {
      enabled: false,
    });
  };

  host.getMediaPermissionStatus = function getMediaPermissionStatus() {
    if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
      return Promise.resolve({ microphone: 'unknown', camera: 'unknown' });
    }
    return ipcRenderer.invoke(mediaQueryChannel);
  };

  host.requestMediaPermission = function requestMediaPermission(device) {
    if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
      return Promise.resolve(false);
    }
    return ipcRenderer.invoke(mediaRequestChannel, { device });
  };

  host.openPrivacySettings = function openPrivacySettings(device) {
    if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
      return Promise.resolve(false);
    }
    return ipcRenderer.invoke(mediaOpenSettingsChannel, { device });
  };

  return host;
}

function registerWakeLockHandler(options = {}) {
  const ipcMain = options.ipcMain;
  const powerSaveBlocker = options.powerSaveBlocker;
  const wakeLockChannel = options.wakeLockChannel || WAKE_LOCK_CHANNEL;
  let wakeLockId = 0;

  function releaseWakeLock() {
    if (
      wakeLockId &&
      powerSaveBlocker &&
      typeof powerSaveBlocker.isStarted === 'function' &&
      powerSaveBlocker.isStarted(wakeLockId)
    ) {
      powerSaveBlocker.stop(wakeLockId);
    }
    wakeLockId = 0;
  }

  ipcMain.handle(wakeLockChannel, (_event, payload = {}) => {
    if (payload.enabled) {
      if (
        !wakeLockId ||
        !powerSaveBlocker ||
        typeof powerSaveBlocker.isStarted !== 'function' ||
        !powerSaveBlocker.isStarted(wakeLockId)
      ) {
        wakeLockId = powerSaveBlocker.start('prevent-display-sleep');
      }
      return wakeLockId;
    }

    releaseWakeLock();
    return 0;
  });

  return {
    channel: wakeLockChannel,
    release() {
      releaseWakeLock();
      if (typeof ipcMain.removeHandler === 'function') {
        ipcMain.removeHandler(wakeLockChannel);
      }
    },
  };
}

function registerMediaPermissionHandler(options = {}) {
  const ipcMain = options.ipcMain;
  const systemPreferences = options.systemPreferences;
  const shell = options.shell;
  const platform = options.platform || process.platform;
  const queryChannel = options.queryChannel || MEDIA_PERMISSION_QUERY_CHANNEL;
  const requestChannel =
    options.requestChannel || MEDIA_PERMISSION_REQUEST_CHANNEL;
  const openSettingsChannel =
    options.openSettingsChannel || MEDIA_PERMISSION_OPEN_SETTINGS_CHANNEL;

  function safeGetMediaAccessStatus(device) {
    if (
      !systemPreferences ||
      typeof systemPreferences.getMediaAccessStatus !== 'function'
    ) {
      return 'unknown';
    }
    try {
      const status = systemPreferences.getMediaAccessStatus(device);
      return typeof status === 'string' && status ? status : 'unknown';
    } catch (error) {
      console.warn('[necallkit-runtime-env] getMediaAccessStatus failed', {
        device,
        message: error && error.message ? error.message : String(error),
      });
      return 'unknown';
    }
  }

  async function safeAskForMediaAccess(device) {
    if (platform !== 'darwin') {
      return safeGetMediaAccessStatus(device) === 'granted';
    }
    if (
      !systemPreferences ||
      typeof systemPreferences.askForMediaAccess !== 'function'
    ) {
      return safeGetMediaAccessStatus(device) === 'granted';
    }
    try {
      return !!(await systemPreferences.askForMediaAccess(device));
    } catch (error) {
      console.warn('[necallkit-runtime-env] askForMediaAccess failed', {
        device,
        message: error && error.message ? error.message : String(error),
      });
      return false;
    }
  }

  ipcMain.handle(queryChannel, () => ({
    microphone: safeGetMediaAccessStatus('microphone'),
    camera: safeGetMediaAccessStatus('camera'),
  }));

  ipcMain.handle(requestChannel, async (_event, payload = {}) => {
    const device = payload && payload.device;
    if (device !== 'microphone' && device !== 'camera') {
      return false;
    }
    return safeAskForMediaAccess(device);
  });

  ipcMain.handle(openSettingsChannel, async (_event, payload = {}) => {
    const device = payload && payload.device;
    const url = resolvePrivacySettingsDeepLink(platform, device);
    if (!url || !shell || typeof shell.openExternal !== 'function') {
      return false;
    }
    try {
      await shell.openExternal(url);
      return true;
    } catch (error) {
      console.warn('[necallkit-runtime-env] openExternal failed', {
        device,
        url,
        message: error && error.message ? error.message : String(error),
      });
      return false;
    }
  });

  return {
    queryChannel,
    requestChannel,
    openSettingsChannel,
    release() {
      if (typeof ipcMain.removeHandler === 'function') {
        ipcMain.removeHandler(queryChannel);
        ipcMain.removeHandler(requestChannel);
        ipcMain.removeHandler(openSettingsChannel);
      }
    },
  };
}

module.exports = {
  WAKE_LOCK_CHANNEL,
  MEDIA_PERMISSION_QUERY_CHANNEL,
  MEDIA_PERMISSION_REQUEST_CHANNEL,
  MEDIA_PERMISSION_OPEN_SETTINGS_CHANNEL,
  PRIVACY_SETTINGS_DEEP_LINKS,
  applyRuntimeEnv,
  createHostApi,
  registerMediaPermissionHandler,
  registerWakeLockHandler,
  resolveNativeLogDirectory,
  resolvePrivacySettingsDeepLink,
  resolveRuntimeEnv,
};
