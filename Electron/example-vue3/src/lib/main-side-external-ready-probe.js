'use strict';

const fs = require('node:fs');
const path = require('node:path');

const DEFAULT_FRAMEWORK = 'electron-main-side-external-ready-probe';
const DEFAULT_CHANNEL = 'electron-main';

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

function describeError(error) {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: error.code,
    };
  }
  return {
    name: 'Error',
    message: String(error || ''),
  };
}

function toSerializable(value) {
  if (typeof value === 'bigint') {
    return value.toString();
  }
  if (Array.isArray(value)) {
    return value.map((item) => toSerializable(item));
  }
  if (value && typeof value === 'object') {
    const result = {};
    Object.keys(value).forEach((key) => {
      const nextValue = value[key];
      if (typeof nextValue !== 'function') {
        result[key] = toSerializable(nextValue);
      }
    });
    return result;
  }
  return value;
}

function writeJson(filePath, payload) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.writeFileSync(filePath, `${JSON.stringify(toSerializable(payload), null, 2)}\n`);
}

function appendJsonLine(filePath, payload) {
  fs.mkdirSync(path.dirname(filePath), { recursive: true });
  fs.appendFileSync(filePath, `${JSON.stringify(toSerializable(payload))}\n`);
}

function normalizeSetupConfig(config = {}) {
  return {
    appKey: String(config.appKey || config.appkey || '').trim(),
    accountId: String(config.accountId || config.account || '').trim(),
    accountToken: String(config.accountToken || config.token || '').trim(),
    currentUserRtcUid: Number(config.currentUserRtcUid) || 0,
    framework: config.framework || DEFAULT_FRAMEWORK,
    channel: config.channel || DEFAULT_CHANNEL,
    initRtcMode: config.initRtcMode || 'global',
    preferredVideoRenderMode: config.preferredVideoRenderMode || 'auto',
  };
}

function validateConfig(config) {
  if (!config.appKey) {
    throw new Error('main-side external-ready probe requires appKey');
  }
  if (!config.accountId) {
    throw new Error('main-side external-ready probe requires accountId');
  }
  if (!config.accountToken) {
    throw new Error('main-side external-ready probe requires accountToken');
  }
}

function createGateError() {
  const error = new Error(
    'main-side native owner probe is gated to macOS Electron 24+'
  );
  error.code = 'NECALL_MAIN_SIDE_PROBE_GATE_DISABLED';
  return error;
}

function createNotReadyError(diagnostics) {
  const error = new Error('external-ready probe did not reach ready diagnostics');
  error.code = 'NECALL_MAIN_SIDE_EXTERNAL_NOT_READY';
  error.diagnostics = diagnostics;
  return error;
}

function isExternalReady(diagnostics, accountId) {
  if (!diagnostics || typeof diagnostics !== 'object') {
    return false;
  }
  if (diagnostics.mode !== 'external') {
    return false;
  }
  if (diagnostics.readyState !== 'ready') {
    return false;
  }
  if (
    diagnostics.currentAccountId &&
    String(diagnostics.currentAccountId) !== accountId
  ) {
    return false;
  }
  return true;
}

async function callSetup(sdk, setupConfig) {
  if (sdk && typeof sdk.setupAsync === 'function') {
    return sdk.setupAsync(setupConfig);
  }
  if (sdk && typeof sdk.setup === 'function') {
    return sdk.setup(setupConfig);
  }
  throw new Error('electron-callkit-sdk setup/setupAsync is unavailable');
}

function readDiagnostics(sdk) {
  if (!sdk || typeof sdk.getDiagnostics !== 'function') {
    return null;
  }
  return sdk.getDiagnostics();
}

function destroySafely(target) {
  if (!target || typeof target.destroy !== 'function') {
    return undefined;
  }
  return target.destroy();
}

function createDefaultExternalSessionFactory() {
  const {
    createExternalNimSession,
  } = require('./example-external-nim-session');
  return (options = {}) =>
    createExternalNimSession(
      Object.assign(
        {
          externalOwnerMode: 'node-nim',
          requireV2: true,
        },
        options
      )
    );
}

function createDefaultSdkFactory() {
  return () => {
    const sdkModule = require('@xkit-yx/electron-callkit-sdk');
    if (
      !sdkModule ||
      !sdkModule.NECall ||
      typeof sdkModule.NECall.getInstance !== 'function'
    ) {
      throw new Error('electron-callkit-sdk NECall.getInstance is unavailable');
    }
    return sdkModule.NECall.getInstance();
  };
}

function applyDefaultRuntimeEnv(options = {}) {
  const {
    applyElectronCallKitRuntimeEnv,
  } = require('@xkit-yx/electron-callkit-sdk/runtime-env');
  return applyElectronCallKitRuntimeEnv(options);
}

function createMainSideExternalReadyProbe(options = {}) {
  const runDir = path.resolve(
    options.runDir || path.join(process.cwd(), 'out', 'main-side-external-ready-probe')
  );
  const summaryPath = options.summaryPath || path.join(runDir, 'summary.json');
  const eventsPath = options.eventsPath || path.join(runDir, 'events.jsonl');
  const platform = options.platform || process.platform;
  const versions = options.versions || process.versions || {};
  const pid = Number(options.pid || process.pid);
  const now = typeof options.now === 'function'
    ? options.now
    : () => new Date().toISOString();
  const createExternalSession =
    options.createExternalSession || createDefaultExternalSessionFactory();
  const createSdk = options.createSdk || createDefaultSdkFactory();
  const applyRuntimeEnv = options.applyRuntimeEnv || applyDefaultRuntimeEnv;

  function createBaseResult() {
    const electronMajor = normalizeElectronMajor(versions);
    const gate = {
      enabled: shouldUseMainSideNativeOwner({ platform, versions }),
      platform,
      electronVersion: versions.electron || '',
      electronMajor,
    };
    return {
      success: false,
      startedAt: now(),
      completedAt: '',
      gate,
      process: {
        pid,
        platform,
        electronVersion: versions.electron || '',
        nodeVersion: versions.node || process.versions.node || '',
      },
      externalLogin: null,
      runtimeEnv: null,
      diagnostics: null,
      messageServiceAvailable: false,
      error: null,
    };
  }

  function log(event, payload = {}) {
    appendJsonLine(eventsPath, {
      event,
      time: now(),
      pid,
      ...payload,
    });
  }

  async function run(inputConfig = {}) {
    const result = createBaseResult();
    let externalSession = null;
    let sdk = null;

    try {
      fs.mkdirSync(runDir, { recursive: true });
      log('probe:start', {
        gate: result.gate,
        process: result.process,
      });

      if (!result.gate.enabled) {
        throw createGateError();
      }

      const setupConfig = normalizeSetupConfig(inputConfig);
      validateConfig(setupConfig);

      result.runtimeEnv = applyRuntimeEnv({
        strict: true,
      });
      log('runtime-env:apply:success', {
        runtimeEnv: result.runtimeEnv,
      });

      externalSession = createExternalSession({
        scope: 'main-side-external-ready-probe',
      });
      sdk = createSdk({
        scope: 'main-side-external-ready-probe',
      });

      log('external-login:start', {
        accountId: setupConfig.accountId,
      });
      result.externalLogin = await externalSession.login(setupConfig);
      log('external-login:success', {
        result: result.externalLogin,
        currentAccountId:
          typeof externalSession.getCurrentAccountId === 'function'
            ? externalSession.getCurrentAccountId()
            : '',
        messageServiceAvailable:
          typeof externalSession.getV2MessageService === 'function'
            ? !!externalSession.getV2MessageService()
            : false,
      });

      const nativeSetupConfig = Object.assign({}, setupConfig);
      delete nativeSetupConfig.accountToken;

      log('sdk-setup:start', {
        accountId: nativeSetupConfig.accountId,
        framework: nativeSetupConfig.framework,
        channel: nativeSetupConfig.channel,
      });
      await callSetup(sdk, nativeSetupConfig);
      result.diagnostics = readDiagnostics(sdk);
      result.messageServiceAvailable =
        typeof externalSession.getV2MessageService === 'function'
          ? !!externalSession.getV2MessageService()
          : false;
      log('sdk-setup:success', {
        diagnostics: result.diagnostics,
        messageServiceAvailable: result.messageServiceAvailable,
      });

      if (!isExternalReady(result.diagnostics, setupConfig.accountId)) {
        throw createNotReadyError(result.diagnostics);
      }

      result.success = true;
      result.completedAt = now();
      log('probe:success', {
        diagnostics: result.diagnostics,
      });
      writeJson(summaryPath, result);
      return result;
    } catch (error) {
      result.success = false;
      result.completedAt = now();
      if (
        error &&
        error.code === 'NECALL_RUNTIME_ENV_INCOMPLETE' &&
        error.diagnostics &&
        !result.runtimeEnv
      ) {
        result.runtimeEnv = error.diagnostics;
      } else if (error && error.diagnostics && !result.diagnostics) {
        result.diagnostics = error.diagnostics;
      }
      result.error = describeError(error);
      log('probe:error', {
        error: result.error,
        diagnostics: result.diagnostics,
      });
      writeJson(summaryPath, result);
      throw error;
    } finally {
      try {
        await destroySafely(externalSession);
      } catch (error) {
        log('external-destroy:error', {
          error: describeError(error),
        });
      }
      try {
        await destroySafely(sdk);
      } catch (error) {
        log('sdk-destroy:error', {
          error: describeError(error),
        });
      }
    }
  }

  return {
    eventsPath,
    run,
    runDir,
    summaryPath,
  };
}

module.exports = {
  createMainSideExternalReadyProbe,
  normalizeElectronMajor,
  shouldUseMainSideNativeOwner,
};
