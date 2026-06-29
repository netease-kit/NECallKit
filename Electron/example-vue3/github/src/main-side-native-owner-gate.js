'use strict';

function normalizeElectronMajor(versions = {}) {
  const rawVersion = versions && versions.electron;
  const major = Number.parseInt(String(rawVersion || '').split('.')[0], 10);
  return Number.isInteger(major) ? major : 0;
}

function shouldUseMainSideNativeOwner(options = {}) {
  const platform = options.platform || process.platform;
  const versions = options.versions || process.versions || {};
  return platform === 'darwin' && normalizeElectronMajor(versions) >= 24;
}

function assertRuntimeInjectedForMainSideOwner(runtime, options = {}) {
  if (runtime) {
    return;
  }
  if (!shouldUseMainSideNativeOwner(options)) {
    return;
  }
  const error = new Error(
    'Electron CallKit UIKit requires an injected IPC runtime on macOS Electron 24+'
  );
  error.code = 'NECALL_MAIN_SIDE_RUNTIME_REQUIRED';
  throw error;
}

module.exports = {
  assertRuntimeInjectedForMainSideOwner,
  normalizeElectronMajor,
  shouldUseMainSideNativeOwner,
};
