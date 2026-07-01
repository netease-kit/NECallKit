'use strict';

const fs = require('node:fs');
const os = require('node:os');
const path = require('node:path');
const { createRequire } = require('node:module');

// B080 后续诊断：Windows 平台 Electron 主进程是 GUI subsystem，console.log
// 容易被吞；把 callRecord.adapter 调试日志同步落盘到 os.tmpdir，路径稳定，
// 用户用 PowerShell `Get-Content $env:TEMP\necallkit-call-record-debug.log` 即可看。
const DEBUG_LOG_FILE_PATH = path.join(
  os.tmpdir(),
  'necallkit-call-record-debug.log'
);
function appendDebugLogToFile(level, label, payload) {
  try {
    const ts = new Date().toISOString();
    let payloadText = '';
    try {
      payloadText =
        payload === undefined ? '' : ' ' + JSON.stringify(payload);
    } catch (_) {
      payloadText = ' [unserializable payload]';
    }
    fs.appendFileSync(
      DEBUG_LOG_FILE_PATH,
      `${ts} [${level}] ${label}${payloadText}\n`,
      'utf8'
    );
  } catch (_) {
    /* swallow: 调试日志失败不影响正常流程 */
  }
}
const {
  createCallRecordMessageAdapter,
} = require('./call-record-message-adapter');
const {
  createExternalNimSession,
} = require('./example-external-nim-session');

const INVOKE_CHANNEL = 'necallkit:runtime:invoke';
const EVENT_CHANNEL = 'necallkit:runtime:event';
const LOGIN_MODE_EXTERNAL = 'external';
const LOGIN_MODE_MANAGED = 'managed';
const DEFAULT_VIDEO_FRAME_INTERVAL_MS = 33;
const CALLKIT_RUNTIME_PACKAGE_NAME = '@xkit-yx/callkit-runtime-electron';
const CALLKIT_RUNTIME_PACKAGE_PATH = [
  'node_modules',
  '@xkit-yx',
  'callkit-runtime-electron',
  'package.json',
];
const ELECTRON_UIKIT_PACKAGE_PATHS = [
  [
    'node_modules',
    '@xkit-yx',
    'electron-callkit-vue3-uikit',
    'package.json',
  ],
];

function createInitialCallRecordAdapterState() {
  return {
    started: false,
    ready: false,
    error: '',
    historyError: '',
    lastMessageId: '',
    recordCount: 0,
    sourceCounts: {},
  };
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

function createManagedUnsupportedError() {
  const error = new Error(
    'managed login is unsupported by the macOS main-side CallKit owner path'
  );
  error.code = 'NECALL_MANAGED_LOGIN_UNSUPPORTED';
  return error;
}

function createOwnerConflictError(message) {
  const error = new Error(message);
  error.code = 'NECALL_MAIN_SIDE_OWNER_CONFLICT';
  return error;
}

function isNumericUid(value) {
  if (typeof value === 'number') {
    return Number.isFinite(value);
  }
  if (typeof value === 'bigint') {
    return true;
  }
  return typeof value === 'string' && /^\d+$/u.test(value.trim());
}

function resolveUidFromCallInfo(callInfo, remoteAccount) {
  if (!callInfo || typeof callInfo !== 'object' || !remoteAccount) {
    return undefined;
  }
  const normalizedRemoteAccount = String(remoteAccount);
  for (const userInfo of [callInfo.callerInfo, callInfo.calleeInfo]) {
    if (
      userInfo &&
      userInfo.accId === normalizedRemoteAccount &&
      userInfo.uid !== undefined &&
      userInfo.uid !== null &&
      String(userInfo.uid).trim()
    ) {
      return userInfo.uid;
    }
  }
  if (
    callInfo.currentAccId === normalizedRemoteAccount &&
    callInfo.rtcInfo &&
    callInfo.rtcInfo.uid !== undefined &&
    callInfo.rtcInfo.uid !== null &&
    String(callInfo.rtcInfo.uid).trim()
  ) {
    return callInfo.rtcInfo.uid;
  }
  return undefined;
}

function toSerializable(value) {
  if (typeof value === 'bigint') {
    return value.toString();
  }
  if (Buffer.isBuffer(value)) {
    return Array.from(value);
  }
  if (ArrayBuffer.isView(value)) {
    return Array.from(value);
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

function normalizeLoginMode(value) {
  return value === LOGIN_MODE_MANAGED ? LOGIN_MODE_MANAGED : LOGIN_MODE_EXTERNAL;
}

function normalizeSetupConfig(config = {}) {
  return {
    appKey: String(config.appKey || config.appkey || '').trim(),
    accountId: String(config.accountId || config.account || '').trim(),
    accountToken: String(config.accountToken || config.token || '').trim(),
    currentUserRtcUid: Number(config.currentUserRtcUid) || 0,
    framework: config.framework || 'electron-main-side-callkit',
    channel: config.channel || 'electron-main',
    initRtcMode: config.initRtcMode || 'global',
    preferredVideoRenderMode: config.preferredVideoRenderMode || 'auto',
  };
}

function toRuntimeSetupConfig(config) {
  const runtimeConfig = Object.assign({}, config);
  delete runtimeConfig.accountToken;
  return runtimeConfig;
}

function createDefaultExternalSession() {
  return createExternalNimSession({
    externalOwnerMode: 'node-nim',
    requireV2: true,
    scope: 'main-side-callkit-service',
  });
}

function collectPackagedRuntimeRequireRoots(resourcesPath) {
  if (!resourcesPath) {
    return [];
  }
  const appRoot = path.join(resourcesPath, 'app');
  return [
    path.join(appRoot, 'package.json'),
    ...ELECTRON_UIKIT_PACKAGE_PATHS.map((segments) =>
      path.join(appRoot, ...segments)
    ),
  ];
}

function requireCallkitRuntimeElectron() {
  const resourcesPath = process.resourcesPath || '';
  for (const packageJsonPath of collectPackagedRuntimeRequireRoots(resourcesPath)) {
    if (!fs.existsSync(packageJsonPath)) {
      continue;
    }
    const packagedRuntimePackageJsonPath = path.join(
      path.dirname(packageJsonPath),
      ...CALLKIT_RUNTIME_PACKAGE_PATH
    );
    try {
      return createRequire(packageJsonPath)(CALLKIT_RUNTIME_PACKAGE_NAME);
    } catch (error) {
      if (fs.existsSync(packagedRuntimePackageJsonPath)) {
        throw error;
      }
    }
  }
  return require(CALLKIT_RUNTIME_PACKAGE_NAME);
}

function createDefaultRuntime(options = {}) {
  const { createElectronRuntime } = requireCallkitRuntimeElectron();
  return createElectronRuntime(options);
}

function safeSend(webContents, payload) {
  if (!webContents || typeof webContents.send !== 'function') {
    return false;
  }
  if (
    typeof webContents.isDestroyed === 'function' &&
    webContents.isDestroyed()
  ) {
    return false;
  }
  webContents.send(EVENT_CHANNEL, toSerializable(payload));
  return true;
}

function safeSendRaw(webContents, payload) {
  if (!webContents || typeof webContents.send !== 'function') {
    return false;
  }
  if (
    typeof webContents.isDestroyed === 'function' &&
    webContents.isDestroyed()
  ) {
    return false;
  }
  webContents.send(EVENT_CHANNEL, payload);
  return true;
}

function getWebContentsId(webContents) {
  if (!webContents || webContents.id === undefined || webContents.id === null) {
    return null;
  }
  return webContents.id;
}

function createCallkitMainService(options = {}) {
  const ipcMain = options.ipcMain;
  const invokeChannel = options.invokeChannel || INVOKE_CHANNEL;
  const eventChannel = options.eventChannel || EVENT_CHANNEL;
  const createExternalSession =
    options.createExternalSession || createDefaultExternalSession;
  const createRuntime = options.createRuntime || createDefaultRuntime;
  const callRecordLimit = options.callRecordLimit || 10;
  const callRecordHistoryLimit =
    options.callRecordHistoryLimit === undefined
      ? 20
      : options.callRecordHistoryLimit;
  const videoFrameIntervalMs =
    options.videoFrameIntervalMs === undefined
      ? DEFAULT_VIDEO_FRAME_INTERVAL_MS
      : Math.max(0, Number(options.videoFrameIntervalMs) || 0);
  const subscribers = new Map();
  const subscriberCleanup = new Map();
  let externalSession = null;
  let runtime = null;
  let runtimeAttached = false;
  let runtimeUnsubscribe = null;
  let callRecordAdapter = null;
  let activeAccountId = '';
  let pendingSetupAccountId = '';
  let nextVideoGenerationId = 1;
  const videoRenderers = new Map();
  let lastRuntimeState = {};
  let lastCallRecords = [];
  let lastCallRecordAdapterState = createInitialCallRecordAdapterState();

  function getOrCreateExternalSession() {
    if (!externalSession) {
      externalSession = createExternalSession({
        scope: 'main-side-callkit-service',
      });
    }
    return externalSession;
  }

  function publish(payload) {
    const serializable = toSerializable(payload);
    subscribers.forEach((webContents) => safeSend(webContents, {
      channel: eventChannel,
      ...serializable,
    }));
  }

  function publishTo(webContents, payload) {
    safeSend(webContents, toSerializable(payload));
  }

  function normalizeVideoFrame(frame) {
    if (!frame || typeof frame !== 'object') {
      return frame;
    }
    const normalizedFrame = {};
    Object.keys(frame).forEach((key) => {
      if (key !== 'data' && typeof frame[key] !== 'function') {
        normalizedFrame[key] = toSerializable(frame[key]);
      }
    });
    const data = frame.data;
    if (Buffer.isBuffer(data) || ArrayBuffer.isView(data)) {
      normalizedFrame.data = new Uint8Array(
        data.buffer,
        data.byteOffset || 0,
        data.byteLength === undefined ? data.length : data.byteLength
      );
    } else if (data instanceof ArrayBuffer) {
      normalizedFrame.data = new Uint8Array(data);
    } else if (Array.isArray(data)) {
      normalizedFrame.data = Uint8Array.from(data);
    } else if (data !== undefined) {
      normalizedFrame.data = data;
    }
    return normalizedFrame;
  }

  function clearPendingVideoFrame(rendererEntry) {
    if (!rendererEntry) {
      return;
    }
    if (rendererEntry.frameTimer) {
      clearTimeout(rendererEntry.frameTimer);
      rendererEntry.frameTimer = null;
    }
    rendererEntry.pendingFrame = null;
  }

  function sendVideoFrame(rendererEntry, frame) {
    if (!rendererEntry) {
      return false;
    }
    const targetWebContents =
      rendererEntry.webContents ||
      (rendererEntry.webContentsId !== null &&
      rendererEntry.webContentsId !== undefined
        ? subscribers.get(rendererEntry.webContentsId)
        : null);
    const payload = {
      channel: eventChannel,
      type: 'video-frame',
      rendererId: rendererEntry.rendererId,
      generationId: rendererEntry.generationId,
      frame,
    };
    if (targetWebContents) {
      return safeSendRaw(targetWebContents, payload);
    }
    if (
      rendererEntry.webContentsId === null ||
      rendererEntry.webContentsId === undefined
    ) {
      let sent = false;
      subscribers.forEach((webContents) => {
        sent = safeSendRaw(webContents, payload) || sent;
      });
      return sent;
    }
    return false;
  }

  function flushPendingVideoFrame(rendererEntry) {
    if (!rendererEntry) {
      return false;
    }
    if (rendererEntry.frameTimer) {
      clearTimeout(rendererEntry.frameTimer);
      rendererEntry.frameTimer = null;
    }
    const frame = rendererEntry.pendingFrame;
    rendererEntry.pendingFrame = null;
    if (!frame) {
      return false;
    }
    return sendVideoFrame(rendererEntry, frame);
  }

  function scheduleVideoFrame(rendererId, generationId, frame) {
    const current = videoRenderers.get(rendererId);
    if (!current || current.generationId !== generationId) {
      return;
    }
    current.pendingFrame = normalizeVideoFrame(frame);
    if (current.frameTimer) {
      return;
    }
    current.frameTimer = setTimeout(() => {
      const latest = videoRenderers.get(rendererId);
      if (!latest || latest.generationId !== generationId) {
        return;
      }
      flushPendingVideoFrame(latest);
    }, videoFrameIntervalMs);
    if (typeof current.frameTimer.unref === 'function') {
      current.frameTimer.unref();
    }
  }

  function disposeNativeVideoRenderer(rendererEntry, options = {}) {
    if (
      !rendererEntry ||
      !rendererEntry.nativeRenderer ||
      typeof rendererEntry.nativeRenderer.dispose !== 'function'
    ) {
      return undefined;
    }
    if (options.flushPendingFrame) {
      flushPendingVideoFrame(rendererEntry);
    } else {
      clearPendingVideoFrame(rendererEntry);
    }
    try {
      const result = rendererEntry.nativeRenderer.dispose();
      if (result && typeof result.catch === 'function') {
        result.catch(() => {});
      }
      return result;
    } catch (_error) {
      // Best effort cleanup during window teardown.
    }
    return undefined;
  }

  function cleanupVideoRenderersForWebContents(webContentsId) {
    if (webContentsId === null || webContentsId === undefined) {
      return;
    }
    videoRenderers.forEach((rendererEntry, rendererId) => {
      if (rendererEntry.webContentsId !== webContentsId) {
        return;
      }
      videoRenderers.delete(rendererId);
      disposeNativeVideoRenderer(rendererEntry);
    });
  }

  function removeSubscriber(webContentsId, options = {}) {
    if (webContentsId === null || webContentsId === undefined) {
      return;
    }
    subscribers.delete(webContentsId);
    const cleanup = subscriberCleanup.get(webContentsId);
    subscriberCleanup.delete(webContentsId);
    if (!options.fromDestroyedEvent && typeof cleanup === 'function') {
      cleanup();
    }
    cleanupVideoRenderersForWebContents(webContentsId);
  }

  function registerSubscriber(webContents) {
    const webContentsId = getWebContentsId(webContents);
    if (webContentsId === null) {
      return null;
    }
    subscribers.set(webContentsId, webContents);
    if (
      !subscriberCleanup.has(webContentsId) &&
      typeof webContents.once === 'function'
    ) {
      const onDestroyed = () => {
        removeSubscriber(webContentsId, { fromDestroyedEvent: true });
      };
      webContents.once('destroyed', onDestroyed);
      subscriberCleanup.set(webContentsId, () => {
        if (typeof webContents.off === 'function') {
          webContents.off('destroyed', onDestroyed);
        } else if (typeof webContents.removeListener === 'function') {
          webContents.removeListener('destroyed', onDestroyed);
        }
      });
    }
    return webContentsId;
  }

  function rendererBelongsToContext(rendererEntry, context = {}) {
    if (!rendererEntry) {
      return false;
    }
    if (
      rendererEntry.webContentsId === null ||
      rendererEntry.webContentsId === undefined ||
      context.webContentsId === null ||
      context.webContentsId === undefined
    ) {
      return true;
    }
    return rendererEntry.webContentsId === context.webContentsId;
  }

  // mac IPC topology 下 runtime 在主进程，DOM Audio 不可用；用 callEffects 把
  // startIncomingRing/startOutgoingRing/stopRing 转发成 IPC event，让 renderer 端
  // ipc-callkit-runtime.js 用 DOM Audio 播放。
  function createServiceRingCallEffects() {
    return {
      async startIncomingRing() {
        publish({ type: 'ring', action: 'startIncoming' });
      },
      async startOutgoingRing() {
        publish({ type: 'ring', action: 'startOutgoing' });
      },
      async stopRing() {
        publish({ type: 'ring', action: 'stop' });
      },
    };
  }

  function getOrCreateRuntime() {
    if (!runtime) {
      runtime = createRuntime({
        scope: 'main-side-callkit-service',
        callEffects: createServiceRingCallEffects(),
      });
    }
    return runtime;
  }

  function attachRuntime() {
    runtime = getOrCreateRuntime();
    if (!runtimeAttached && runtime && typeof runtime.attach === 'function') {
      runtime.attach();
      runtimeAttached = true;
    }
    if (!runtimeUnsubscribe && runtime && typeof runtime.subscribe === 'function') {
      runtimeUnsubscribe = runtime.subscribe((state) => {
        lastRuntimeState = state || {};
        retryPendingVideoBindings();
        publish({
          type: 'state',
          state,
        });
      });
    }
    return runtime;
  }

  function readDiagnostics() {
    if (runtime && typeof runtime.getDiagnostics === 'function') {
      return runtime.getDiagnostics();
    }
    if (runtime && typeof runtime.getState === 'function') {
      const state = runtime.getState();
      return state && state.diagnostics;
    }
    return undefined;
  }

  function syncDefaultCallRecordProvider() {
    if (
      runtime &&
      runtime.sdk &&
      typeof runtime.sdk.setCallRecordProvider === 'function'
    ) {
      runtime.sdk.setCallRecordProvider(false);
      return true;
    }
    return false;
  }

  function resolveRemoteRtcUid(remoteAccount) {
    const normalizedRemoteAccount =
      remoteAccount === undefined || remoteAccount === null
        ? ''
        : String(remoteAccount).trim();
    if (!normalizedRemoteAccount) {
      return undefined;
    }
    if (runtime && typeof runtime.getUidByAccId === 'function') {
      const rtcUid = runtime.getUidByAccId(normalizedRemoteAccount);
      if (rtcUid !== undefined && rtcUid !== null && String(rtcUid).trim()) {
        return rtcUid;
      }
    }
    if (runtime && typeof runtime.getState === 'function') {
      const runtimeState = runtime.getState();
      if (runtimeState && typeof runtimeState === 'object') {
        lastRuntimeState = runtimeState;
        const rtcUid = resolveUidFromCallInfo(
          runtimeState.callInfo,
          normalizedRemoteAccount
        );
        if (rtcUid !== undefined) {
          return rtcUid;
        }
      }
    }
    const stateRtcUid = resolveUidFromCallInfo(
      lastRuntimeState && lastRuntimeState.callInfo,
      normalizedRemoteAccount
    );
    if (stateRtcUid !== undefined) {
      return stateRtcUid;
    }
    if (isNumericUid(remoteAccount)) {
      return remoteAccount;
    }
    return undefined;
  }

  function bindRemoteVideoRenderer(rendererEntry) {
    if (
      !rendererEntry ||
      !rendererEntry.nativeRenderer ||
      typeof rendererEntry.nativeRenderer.attachToRemoteVideo !== 'function'
    ) {
      return false;
    }
    if (!rendererEntry.pendingRemoteAccount) {
      rendererEntry.nativeRenderer.attachToRemoteVideo();
      return true;
    }
    const rtcUid = resolveRemoteRtcUid(rendererEntry.pendingRemoteAccount);
    if (rtcUid === undefined) {
      return false;
    }
    rendererEntry.pendingRemoteAccount = '';
    rendererEntry.nativeRenderer.attachToRemoteVideo(rtcUid);
    return true;
  }

  function retryPendingVideoBindings() {
    videoRenderers.forEach((rendererEntry) => {
      if (!rendererEntry.pendingRemoteAccount) {
        return;
      }
      try {
        bindRemoteVideoRenderer(rendererEntry);
      } catch (_error) {}
    });
  }

  async function stopCallRecordAdapter() {
    if (!callRecordAdapter) {
      return lastCallRecordAdapterState;
    }
    lastCallRecordAdapterState = callRecordAdapter.stop();
    callRecordAdapter = null;
    return lastCallRecordAdapterState;
  }

  async function startCallRecordAdapter(setupConfig) {
    await stopCallRecordAdapter();
    callRecordAdapter = createCallRecordMessageAdapter({
      externalSession,
      selfAccountId: setupConfig.accountId,
      records: lastCallRecords,
      limit: callRecordLimit,
      historyLimit: callRecordHistoryLimit,
      onRecords(records, detail) {
        lastCallRecords = records.slice();
        lastCallRecordAdapterState =
          (detail && detail.state) || lastCallRecordAdapterState;
        publish({
          type: 'call-records:snapshot',
          records: lastCallRecords,
          adapterState: lastCallRecordAdapterState,
        });
      },
      onDebugLog(level, label, payload) {
        // B080 后续诊断：除了 publish 到 renderer（IPC runtime 当前未消费），还
        // 同步两路本地输出：
        //   1) console.log 到 main 进程 stdout（部分 dev 终端可见）
        //   2) appendDebugLogToFile 落盘到 os.tmpdir/necallkit-call-record-debug.log
        //      （Windows GUI subsystem 吞 stdout 时这是唯一稳定查看路径）
        try {
          const logger =
            level === 'error'
              ? console.error
              : level === 'warn'
                ? console.warn
                : console.log;
          logger(
            `[callkit-main-service][${level}] ${label}`,
            JSON.stringify(payload || {}, null, 2)
          );
        } catch (_) { /* swallow */ }
        appendDebugLogToFile(level, label, payload);
        publish({
          type: 'debug',
          level,
          label,
          payload,
        });
      },
    });
    lastCallRecordAdapterState = await callRecordAdapter.start();
    publish({
      type: 'call-records:adapter-state',
      adapterState: lastCallRecordAdapterState,
    });
    return lastCallRecordAdapterState;
  }

  async function setupExternal(payload = {}) {
    const setupConfig = normalizeSetupConfig(payload);
    if (
      pendingSetupAccountId &&
      pendingSetupAccountId !== setupConfig.accountId
    ) {
      throw createOwnerConflictError(
        `main-side CallKit owner setup is already in progress for account ${pendingSetupAccountId}`
      );
    }
    if (activeAccountId && activeAccountId !== setupConfig.accountId) {
      throw createOwnerConflictError(
        `main-side CallKit owner already owns account ${activeAccountId}`
      );
    }
    pendingSetupAccountId = setupConfig.accountId;
    externalSession = getOrCreateExternalSession();
    runtime = getOrCreateRuntime();
    try {
      const externalLogin = await externalSession.login(setupConfig);
      attachRuntime();
      const diagnostics = await runtime.setup(toRuntimeSetupConfig(setupConfig));
      const latestDiagnostics = readDiagnostics() || diagnostics;
      activeAccountId = setupConfig.accountId;
      syncDefaultCallRecordProvider();
      const callRecordAdapterState = await startCallRecordAdapter(setupConfig);
      return {
        externalLogin,
        diagnostics: latestDiagnostics,
        state: typeof runtime.getState === 'function' ? runtime.getState() : {},
        callRecords: lastCallRecords,
        callRecordAdapterState,
      };
    } finally {
      if (pendingSetupAccountId === setupConfig.accountId) {
        pendingSetupAccountId = '';
      }
    }
  }

  async function invoke(method, payload = {}, context = {}) {
    if (method === 'setup') {
      const loginMode = normalizeLoginMode(payload.loginMode);
      if (loginMode === LOGIN_MODE_MANAGED) {
        throw createManagedUnsupportedError();
      }
      return setupExternal(payload);
    }
    if (method === 'login') {
      throw createManagedUnsupportedError();
    }
    if (method === 'destroy') {
      await destroyRuntimeOwner({
        publishUpdates: true,
      });
      return {
        records: lastCallRecords,
        adapterState: lastCallRecordAdapterState,
      };
    }

    runtime = getOrCreateRuntime();
    switch (method) {
      case 'getState':
        return typeof runtime.getState === 'function' ? runtime.getState() : {};
      case 'getDiagnostics':
        return readDiagnostics();
      case 'call':
      case 'accept':
      case 'logout':
        return runtime[method](payload);
      case 'hangup':
      case 'switchCallType':
      case 'setTimeout':
      case 'setCallConfig':
      case 'setLocalAudioEnabled':
      case 'setLocalVideoEnabled':
      case 'setVideoCaptureDevice':
      case 'setAudioRecordingDevice':
      case 'setAudioPlaybackDevice':
      case 'refreshDevices':
        return runtime[method](payload);
      case 'getCallConfig':
        return typeof runtime.getCallConfig === 'function'
          ? runtime.getCallConfig()
          : null;
      case 'getCallInfo':
        return typeof runtime.getCallInfo === 'function'
          ? runtime.getCallInfo()
          : null;
      case 'getCallRecords':
        return {
          records: lastCallRecords,
          adapterState: lastCallRecordAdapterState,
        };
      case 'createVideoRenderer': {
        if (typeof runtime.createVideoRenderer !== 'function') {
          const error = new Error('main-side runtime does not support video renderer');
          error.code = 'NECALL_VIDEO_RENDERER_UNSUPPORTED';
          throw error;
        }
        const nativeRenderer = await runtime.createVideoRenderer();
        const rendererId = Number(nativeRenderer && nativeRenderer.rendererId);
        const generationId = nextVideoGenerationId;
        nextVideoGenerationId += 1;
        if (!Number.isFinite(rendererId) || rendererId <= 0) {
          const error = new Error('main-side video renderer returned invalid rendererId');
          error.code = 'NECALL_VIDEO_RENDERER_INVALID';
          throw error;
        }
        const descriptor = {
          rendererId,
          generationId,
          webContentsId: context.webContentsId,
          webContents: context.webContents,
          nativeRenderer,
          pendingFrame: null,
          frameTimer: null,
          pendingRemoteAccount: '',
        };
        videoRenderers.set(rendererId, descriptor);
        if (typeof nativeRenderer.on === 'function') {
          nativeRenderer.on('frame', (frame) => {
            scheduleVideoFrame(rendererId, generationId, frame);
          });
        }
        return {
          rendererId,
          generationId,
        };
      }
      case 'attachVideoRenderer': {
        const rendererEntry = videoRenderers.get(Number(payload.rendererId));
        if (
          !rendererEntry ||
          rendererEntry.generationId !== payload.generationId ||
          !rendererBelongsToContext(rendererEntry, context)
        ) {
          return false;
        }
        const nativeRenderer = rendererEntry.nativeRenderer;
        if (
          payload.target === 'local' &&
          typeof nativeRenderer.attachToLocalVideo === 'function'
        ) {
          await nativeRenderer.attachToLocalVideo();
          return true;
        }
        if (
          payload.target === 'remote' &&
          typeof nativeRenderer.attachToRemoteVideo === 'function'
        ) {
          rendererEntry.pendingRemoteAccount =
            payload.remoteAccount === undefined || payload.remoteAccount === null
              ? ''
              : String(payload.remoteAccount);
          return bindRemoteVideoRenderer(rendererEntry);
        }
        return false;
      }
      case 'setVideoRendererMirror': {
        const rendererEntry = videoRenderers.get(Number(payload.rendererId));
        if (
          rendererEntry &&
          rendererEntry.generationId === payload.generationId &&
          rendererBelongsToContext(rendererEntry, context) &&
          typeof rendererEntry.nativeRenderer.setMirror === 'function'
        ) {
          await rendererEntry.nativeRenderer.setMirror(!!payload.mirror);
          return true;
        }
        return false;
      }
      case 'disposeVideoRenderer': {
        const rendererEntry = videoRenderers.get(Number(payload.rendererId));
        if (
          rendererEntry &&
          rendererEntry.generationId === payload.generationId &&
          rendererBelongsToContext(rendererEntry, context)
        ) {
          videoRenderers.delete(Number(payload.rendererId));
          await disposeNativeVideoRenderer(rendererEntry, {
            flushPendingFrame: true,
          });
          return true;
        }
        return false;
      }
      default: {
        const error = new Error(`Unsupported CallKit IPC runtime method: ${method}`);
        error.code = 'NECALL_IPC_UNSUPPORTED_METHOD';
        throw error;
      }
    }
  }

  async function handleInvoke(event, request = {}) {
    const webContents = event && event.sender;
    const webContentsId = registerSubscriber(webContents);
    try {
      return toSerializable(await invoke(request.method, request.payload, {
        webContents,
        webContentsId,
      }));
    } catch (error) {
      const publicError = describeError(error);
      if (publicError.code) {
        const nextError = new Error(publicError.message);
        nextError.code = publicError.code;
        throw nextError;
      }
      throw error;
    }
  }

  if (ipcMain && typeof ipcMain.handle === 'function') {
    ipcMain.handle(invokeChannel, handleInvoke);
  }

  // B080：caller 进程被中断（before-quit / SIGINT / SIGTERM 等可拦截信号）
  // 时，先尝试调 runtime.hangup() 主动挂断，让标准 caller-only 派发路径产生一条
  // IM call message，避免"进程死了 → 主叫被叫双方都没有话单"。
  // 仅覆盖可拦截的中断（before-quit / 信号），kill -9 / 硬崩溃不在本路径承诺范围内。
  let processTerminatingHandled = false;
  const DEFAULT_HANGUP_GRACE_MS = 1500;
  const DEFAULT_HANGUP_FLUSH_MS = 300;

  function readActiveCallSnapshot() {
    let runtimeState = lastRuntimeState;
    if (runtime && typeof runtime.getState === 'function') {
      try {
        const fresh = runtime.getState();
        if (fresh && typeof fresh === 'object') {
          runtimeState = fresh;
          lastRuntimeState = fresh;
        }
      } catch (_) { /* swallow，fallback 到 lastRuntimeState */ }
    }
    const callStatus = Number(runtimeState && runtimeState.callStatus);
    const callInfo = (runtimeState && runtimeState.callInfo) || {};
    const inviteInfo = (runtimeState && runtimeState.inviteInfo) || {};
    const callId =
      (callInfo && callInfo.callId) || (inviteInfo && inviteInfo.callId) || '';
    return {
      active: Number.isFinite(callStatus) && callStatus !== 0,
      callStatus: Number.isFinite(callStatus) ? callStatus : 0,
      callId: callId || '',
    };
  }

  async function handleProcessTerminating(options = {}) {
    if (processTerminatingHandled) {
      return { skipped: 'already-handled' };
    }
    processTerminatingHandled = true;

    const reason = options.reason || 'process-terminating';
    const graceMs = Number.isFinite(Number(options.graceMs))
      ? Math.max(0, Number(options.graceMs))
      : DEFAULT_HANGUP_GRACE_MS;
    const flushMs = Number.isFinite(Number(options.flushMs))
      ? Math.max(0, Number(options.flushMs))
      : DEFAULT_HANGUP_FLUSH_MS;

    if (!runtime || typeof runtime.hangup !== 'function') {
      publish({
        type: 'debug',
        level: 'info',
        label: 'callkit.process.terminating.skip',
        payload: { reason, why: 'no-runtime-hangup' },
      });
      return { reason, hangupTriggered: false, why: 'no-runtime-hangup' };
    }

    const snapshot = readActiveCallSnapshot();
    if (!snapshot.active) {
      publish({
        type: 'debug',
        level: 'info',
        label: 'callkit.process.terminating.skip',
        payload: { reason, why: 'idle', snapshot },
      });
      return { reason, hangupTriggered: false, why: 'idle', ...snapshot };
    }

    publish({
      type: 'debug',
      level: 'info',
      label: 'callkit.process.terminating.hangup',
      payload: { reason, snapshot, graceMs, flushMs },
    });

    try {
      const payload = snapshot.callId ? { callId: snapshot.callId } : {};
      const hangupPromise = Promise.resolve(runtime.hangup(payload));
      let timedOut = false;
      let timeoutTimer = null;
      const guarded = await new Promise((resolve) => {
        timeoutTimer = setTimeout(() => {
          timedOut = true;
          timeoutTimer = null;
          resolve({ ok: false, error: new Error('hangup_grace_timeout') });
        }, graceMs);
        hangupPromise.then(
          (value) => {
            if (timeoutTimer) {
              clearTimeout(timeoutTimer);
              timeoutTimer = null;
            }
            resolve({ ok: true, value });
          },
          (error) => {
            if (timeoutTimer) {
              clearTimeout(timeoutTimer);
              timeoutTimer = null;
            }
            resolve({ ok: false, error });
          }
        );
      });

      // 给 native V2NIM send call record message 一点点 flush 时间，再走 destroy。
      // 进程退出前的尽力而为：不阻塞太久。
      if (flushMs > 0) {
        await new Promise((resolve) => {
          setTimeout(resolve, flushMs);
        });
      }

      if (guarded.ok) {
        publish({
          type: 'debug',
          level: 'info',
          label: 'callkit.process.terminating.hangup.ok',
          payload: { reason, snapshot },
        });
        return { reason, hangupTriggered: true, timedOut: false, snapshot };
      }

      publish({
        type: 'debug',
        level: 'error',
        label: 'callkit.process.terminating.hangup.failed',
        payload: {
          reason,
          snapshot,
          timedOut,
          error: describeError(guarded.error),
        },
      });
      return {
        reason,
        hangupTriggered: true,
        timedOut,
        snapshot,
        error: describeError(guarded.error).message,
      };
    } catch (error) {
      publish({
        type: 'debug',
        level: 'error',
        label: 'callkit.process.terminating.hangup.threw',
        payload: { reason, snapshot, error: describeError(error) },
      });
      return {
        reason,
        hangupTriggered: false,
        snapshot,
        error: describeError(error).message,
      };
    }
  }

  // B080：窗口正常关闭时如果通话中，先 preventDefault → 走 hangup hook
  // → 完成后强制 destroy 窗口。所有副作用都在 service 内部，consumer 只需把
  // window 注入一次。kill -9 / 硬崩溃 / 窗口被外部强杀不在拦截范围内。
  function attachWindowLifecycle(browserWindow) {
    if (
      !browserWindow ||
      typeof browserWindow.on !== 'function' ||
      typeof browserWindow.destroy !== 'function'
    ) {
      return false;
    }
    let pendingCloseHangup = false;
    browserWindow.on('close', (event) => {
      if (pendingCloseHangup) {
        return;
      }
      pendingCloseHangup = true;
      if (event && typeof event.preventDefault === 'function') {
        event.preventDefault();
      }
      publish({
        type: 'debug',
        level: 'info',
        label: 'callkit.window.close.intercept',
        payload: { snapshot: readActiveCallSnapshot() },
      });
      Promise.resolve(
        handleProcessTerminating({ reason: 'window-close' })
      )
        .catch((error) => {
          publish({
            type: 'debug',
            level: 'error',
            label: 'callkit.window.close.hangup_failed',
            payload: { error: describeError(error) },
          });
        })
        .finally(() => {
          if (
            typeof browserWindow.isDestroyed !== 'function' ||
            !browserWindow.isDestroyed()
          ) {
            try {
              browserWindow.destroy();
            } catch (_) { /* swallow，让 app 后续 quit 流程兜底 */ }
          }
        });
    });
    return true;
  }

  async function destroyRuntimeOwner(options = {}) {
    const publishUpdates = !!options.publishUpdates;
    if (runtimeUnsubscribe) {
      try { runtimeUnsubscribe(); } catch (_) { /* swallow */ }
      runtimeUnsubscribe = null;
    }
    if (callRecordAdapter) {
      try { callRecordAdapter.stop(); } catch (_) { /* swallow */ }
      callRecordAdapter = null;
    }
    videoRenderers.forEach((rendererEntry) => {
      try { disposeNativeVideoRenderer(rendererEntry); } catch (_) { /* swallow */ }
    });
    videoRenderers.clear();
    if (runtimeAttached && runtime && typeof runtime.detach === 'function') {
      try { runtime.detach(); } catch (_) { /* swallow */ }
    }
    runtimeAttached = false;
    if (runtime && typeof runtime.destroy === 'function') {
      try { runtime.destroy(); } catch (_) { /* swallow */ }
    }
    runtime = null;
    if (externalSession && typeof externalSession.destroy === 'function') {
      try { await externalSession.destroy(); } catch (_) { /* swallow */ }
    } else if (externalSession && typeof externalSession.logout === 'function') {
      try { await externalSession.logout(); } catch (_) { /* swallow */ }
    }
    externalSession = null;
    activeAccountId = '';
    pendingSetupAccountId = '';
    lastCallRecords = [];
    lastCallRecordAdapterState = createInitialCallRecordAdapterState();
    if (publishUpdates) {
      publish({
        type: 'call-records:snapshot',
        records: lastCallRecords,
        adapterState: lastCallRecordAdapterState,
      });
    }
  }

  async function destroyService() {
    // 在解 IPC handler 之前先做一次进程中断 hangup 尝试，覆盖 before-quit 路径；
    // 失败或 idle 都不阻塞后续 destroy。
    try {
      await handleProcessTerminating({ reason: 'destroy-service' });
    } catch (_) { /* swallow，进入正常 teardown */ }

    if (ipcMain && typeof ipcMain.removeHandler === 'function') {
      ipcMain.removeHandler(invokeChannel);
    }
    subscriberCleanup.forEach((cleanup) => {
      if (typeof cleanup === 'function') {
        cleanup();
      }
    });
    subscriberCleanup.clear();
    subscribers.clear();
    await destroyRuntimeOwner();
  }

  return {
    channels: {
      event: eventChannel,
      invoke: invokeChannel,
    },
    destroy() {
      return destroyService();
    },
    destroyAsync() {
      return destroyService();
    },
    getCallRecords() {
      return {
        records: lastCallRecords.slice(),
        adapterState: Object.assign({}, lastCallRecordAdapterState),
      };
    },
    handleInvoke,
    invoke,
    attachRuntime,
    registerSubscriber,
    publishRing(payload = {}) {
      publish(Object.assign({ type: 'ring' }, payload));
    },
    // B080：暴露给 main.js 的进程中断 hook。在 destroyService / 窗口关闭
    // 等正常退出路径内部使用；幂等。
    handleProcessTerminating,
    // B080：把"窗口正常关闭时通话中先 hangup 再关"的逻辑收敛进 service，
    // consumer 创建 BrowserWindow 后只需调一次 service.attachWindowLifecycle(win)，
    // 无需自己写 close handler + preventDefault + window.destroy() 这一套。
    attachWindowLifecycle,
  };
}

module.exports = {
  EVENT_CHANNEL,
  INVOKE_CHANNEL,
  createCallkitMainService,
  createDefaultRuntime,
  createDefaultExternalSession,
};
