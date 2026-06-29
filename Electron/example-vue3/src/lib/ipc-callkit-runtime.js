'use strict';

const { EventEmitter } = require('node:events');

const PERMISSION_DENIED_ERROR_CODE = 'ECALLKIT_PERMISSION_DENIED';
const DEVICE_UNAVAILABLE_ERROR_CODE = 'ECALLKIT_DEVICE_UNAVAILABLE';

function createInitialState() {
  return {
    callInfo: undefined,
    inviteInfo: undefined,
    lastEndInfo: undefined,
    connected: false,
    callStatus: 0,
    callRole: 'none',
    remoteAccount: '',
    callType: 1,
    durationSeconds: 0,
    localAudioEnabled: true,
    localVideoEnabled: true,
    remoteVideoAvailable: false,
    remoteVideoMuted: false,
    remoteAudioMuted: false,
    localAudioMuted: false,
    rtcInitCompleted: false,
    videoCaptureDevices: [],
    currentVideoCaptureDeviceId: '',
    audioRecordingDevices: [],
    currentAudioRecordingDeviceId: '',
    audioPlaybackDevices: [],
    currentAudioPlaybackDeviceId: '',
    noticeText: '',
    diagnostics: undefined,
    permissionDenied: null,
    deviceUnavailable: null,
  };
}

function createInitialCallRecordSnapshot() {
  return {
    records: [],
    adapterState: {
      started: false,
      ready: false,
      error: '',
      historyError: '',
      lastMessageId: '',
      recordCount: 0,
      sourceCounts: {},
    },
  };
}

const ELECTRON_EXTENSION_FIELDS = Object.freeze([
  'pendingSwitchCallType',
  'outgoingSwitchCallType',
]);

const ELECTRON_EXTENSION_BOOLEAN_FIELDS = Object.freeze([
  'remoteDisconnected',
  'localDisconnected',
]);

function mergeState(target, snapshot = {}, options = {}) {
  const preserveLocalMediaGuard = !!options.preserveLocalMediaGuard;
  const previousPermissionDenied = target.permissionDenied;
  const previousDeviceUnavailable = target.deviceUnavailable;

  ELECTRON_EXTENSION_FIELDS.forEach((field) => {
    if (!Object.prototype.hasOwnProperty.call(snapshot, field)) {
      target[field] = undefined;
    }
  });
  ELECTRON_EXTENSION_BOOLEAN_FIELDS.forEach((field) => {
    if (!Object.prototype.hasOwnProperty.call(snapshot, field)) {
      target[field] = false;
    }
  });
  Object.assign(target, snapshot);
  if (preserveLocalMediaGuard) {
    // Main-side runtime snapshots are native state. In IPC topology the media
    // permission/device guards live in the renderer, so a main snapshot with
    // null guard fields must not erase a modal the renderer just raised.
    if (
      previousPermissionDenied &&
      Object.prototype.hasOwnProperty.call(snapshot, 'permissionDenied') &&
      snapshot.permissionDenied == null
    ) {
      target.permissionDenied = previousPermissionDenied;
    }
    if (
      previousDeviceUnavailable &&
      Object.prototype.hasOwnProperty.call(snapshot, 'deviceUnavailable') &&
      snapshot.deviceUnavailable == null
    ) {
      target.deviceUnavailable = previousDeviceUnavailable;
    }
  }
  return target;
}

function normalizeFrame(frame) {
  if (!frame || typeof frame !== 'object') {
    return frame;
  }
  if (Array.isArray(frame.data)) {
    return Object.assign({}, frame, {
      data: Uint8Array.from(frame.data),
    });
  }
  return frame;
}

function normalizeCallType(value, fallback = 1) {
  if (String(value) === '2') {
    return 2;
  }
  if (String(value) === '1') {
    return 1;
  }
  return fallback == null ? 1 : fallback;
}

function normalizeSwitchState(value) {
  const numberValue = Number(value);
  return Number.isFinite(numberValue) ? numberValue : null;
}

function resolvePayloadCallType(payload, fallback) {
  if (payload && typeof payload === 'object') {
    return normalizeCallType(payload.callType, fallback);
  }
  return normalizeCallType(payload, fallback);
}

function resolvePlatform() {
  if (typeof process !== 'undefined' && process && process.platform) {
    return process.platform;
  }
  return '';
}

function createPermissionDeniedError(device) {
  const platform = resolvePlatform();
  const error = new Error('media permission denied: ' + device);
  error.code = PERMISSION_DENIED_ERROR_CODE;
  error.device = device;
  error.platform = platform;
  return error;
}

function createDeviceUnavailableError(device) {
  const error = new Error('media device unavailable: ' + device);
  error.code = DEVICE_UNAVAILABLE_ERROR_CODE;
  error.device = device;
  return error;
}

function isNativeMediaAccessFailure(error) {
  if (!error) {
    return false;
  }
  const context = error.context && typeof error.context === 'object'
    ? error.context
    : null;
  if (context && Number(context.result) === -1) {
    return true;
  }
  const message = String(error.message || error || '');
  return /native code\s+-1\b/i.test(message);
}

// mac IPC topology 下 ring 播放的渲染端实现：
// - main 进程 runtime 的 callEffects 用 publish() 发 {type:'ring', action:'startIncoming'|'startOutgoing'|'stop'}
// - renderer 收到事件后用 DOM Audio 播放（因为主进程没有 window/Audio）
// - ringUrl 由调用方（app.js）用 vue3-uikit 的 DEFAULT_RING_ASSETS 注入到 createIpcCallkitRuntime
// - 同源代码同时 work 在主进程不存在 (window-less) 与 renderer (window 存在) 场景：
//   主进程 require 这文件时 Audio undefined → ringPlayers 全部 no-op 不报错
const RING_KIND_BY_ACTION = {
  startIncoming: 'incoming',
  startOutgoing: 'outgoing',
};

function createRingPlayers(ringAssets) {
  const players = { incoming: null, outgoing: null };
  function getUrl(kind) {
    if (!ringAssets) return '';
    const fieldName = kind === 'incoming' ? 'incomingRingUrl' : 'outgoingRingUrl';
    const value = ringAssets[fieldName];
    return typeof value === 'string' ? value : '';
  }
  function start(kind) {
    if (typeof Audio === 'undefined') return;
    const ringUrl = getUrl(kind);
    if (!ringUrl) return;
    stop();
    let ring = players[kind];
    if (!ring || ring.__necallkitRingUrl !== ringUrl) {
      try {
        ring = new Audio(ringUrl);
      } catch (_error) {
        return;
      }
      ring.loop = true;
      ring.__necallkitRingUrl = ringUrl;
      players[kind] = ring;
    }
    try { ring.currentTime = 0; } catch (_error) {}
    Promise.resolve(ring.play()).catch(() => {});
  }
  function stop() {
    Object.values(players).forEach((ring) => {
      if (!ring) return;
      try { ring.pause(); } catch (_error) {}
      try { ring.currentTime = 0; } catch (_error) {}
    });
  }
  return { start, stop };
}

function createIpcCallkitRuntime(bridge, options = {}) {
  if (!bridge || typeof bridge.invoke !== 'function') {
    throw new Error('createIpcCallkitRuntime requires a callkit IPC bridge');
  }

  const state = createInitialState();
  let callRecordSnapshot = createInitialCallRecordSnapshot();
  const listeners = new Set();
  const recordListeners = new Set();
  const videoRenderers = new Map();
  const ringPlayers = createRingPlayers(options.ringAssets);
  const host = options.host || null;
  const knownDeviceLists = {
    microphone: false,
    camera: false,
  };

  function publishState() {
    const snapshot = { ...state };
    listeners.forEach((listener) => listener(snapshot));
    return snapshot;
  }

  function setPermissionDenied(value) {
    state.permissionDenied = value || null;
    publishState();
  }

  function setDeviceUnavailable(value) {
    state.deviceUnavailable = value || null;
    publishState();
  }

  function publishCallRecords() {
    const snapshot = {
      records: callRecordSnapshot.records.slice(),
      adapterState: { ...callRecordSnapshot.adapterState },
    };
    recordListeners.forEach((listener) => listener(snapshot));
    return snapshot;
  }

  function markKnownDeviceLists(snapshot) {
    if (!snapshot || typeof snapshot !== 'object') {
      return;
    }
    if (Object.prototype.hasOwnProperty.call(snapshot, 'audioRecordingDevices')) {
      knownDeviceLists.microphone = true;
    }
    if (Object.prototype.hasOwnProperty.call(snapshot, 'videoCaptureDevices')) {
      knownDeviceLists.camera = true;
    }
  }

  function applySetupResult(result = {}) {
    if (result.state) {
      markKnownDeviceLists(result.state);
      mergeState(state, result.state);
    }
    if (result.diagnostics) {
      state.diagnostics = result.diagnostics;
    }
    if (Array.isArray(result.callRecords) || result.callRecordAdapterState) {
      callRecordSnapshot = {
        records: Array.isArray(result.callRecords) ? result.callRecords.slice() : [],
        adapterState:
          result.callRecordAdapterState || createInitialCallRecordSnapshot().adapterState,
      };
      publishCallRecords();
    }
    publishState();
  }

  function shouldCheckMediaPermission() {
    return !!(host && typeof host.getMediaPermissionStatus === 'function');
  }

  function raisePermissionDenied(device) {
    const error = createPermissionDeniedError(device);
    setPermissionDenied({
      device,
      platform: error.platform,
    });
    throw error;
  }

  async function ensureMediaPermission(devices) {
    if (!Array.isArray(devices) || devices.length === 0) {
      return;
    }
    if (!shouldCheckMediaPermission()) {
      return;
    }

    if (state.permissionDenied) {
      setPermissionDenied(null);
    }

    let status;
    try {
      status = await host.getMediaPermissionStatus();
    } catch (_error) {
      return;
    }
    if (!status || typeof status !== 'object') {
      return;
    }

    for (const device of devices) {
      const current = status[device];
      if (current === 'granted' || current === 'unknown' || current == null) {
        continue;
      }
      if (
        current === 'not-determined' &&
        typeof host.requestMediaPermission === 'function'
      ) {
        let granted = false;
        try {
          granted = !!(await host.requestMediaPermission(device));
        } catch (_error) {
          granted = false;
        }
        if (granted) {
          continue;
        }
      }
      raisePermissionDenied(device);
    }
  }

  async function requestMediaPermission(device) {
    if (!host || typeof host.requestMediaPermission !== 'function') {
      return false;
    }
    try {
      return !!(await host.requestMediaPermission(device));
    } catch (_error) {
      return false;
    }
  }

  async function confirmMediaPermissionAfterNativeFailure(devices) {
    if (!Array.isArray(devices) || devices.length === 0) {
      return false;
    }
    if (!shouldCheckMediaPermission()) {
      return false;
    }

    let status;
    try {
      status = await host.getMediaPermissionStatus();
    } catch (_error) {
      return false;
    }
    if (!status || typeof status !== 'object') {
      return false;
    }

    const platform = resolvePlatform();
    for (const device of devices) {
      const current = status[device];
      if (current === 'not-determined') {
        if (await requestMediaPermission(device)) {
          continue;
        }
        raisePermissionDenied(device);
      }
      if (current !== 'granted' && current !== 'unknown' && current != null) {
        raisePermissionDenied(device);
      }
      if (
        platform === 'darwin' &&
        current === 'granted' &&
        typeof host.requestMediaPermission === 'function'
      ) {
        if (await requestMediaPermission(device)) {
          continue;
        }
        raisePermissionDenied(device);
      }
    }
    return false;
  }

  async function rethrowMediaPermissionAfterNativeFailure(error, devices) {
    if (!isNativeMediaAccessFailure(error)) {
      return;
    }
    await confirmMediaPermissionAfterNativeFailure(devices);
  }

  async function invokeMediaGuarded(method, payload, devices) {
    await ensureMediaPermission(devices);
    await ensureDeviceAvailability(devices);
    try {
      return await bridge.invoke(method, payload);
    } catch (error) {
      await rethrowMediaPermissionAfterNativeFailure(error, devices);
      throw error;
    }
  }

  function hasDevice(device) {
    if (!knownDeviceLists[device]) {
      return true;
    }
    if (device === 'microphone') {
      return Array.isArray(state.audioRecordingDevices) &&
        state.audioRecordingDevices.length > 0;
    }
    if (device === 'camera') {
      return Array.isArray(state.videoCaptureDevices) &&
        state.videoCaptureDevices.length > 0;
    }
    return true;
  }

  async function refreshDeviceSnapshot() {
    try {
      const nextState = await bridge.invoke('refreshDevices', {});
      if (nextState && typeof nextState === 'object') {
        markKnownDeviceLists(nextState);
        mergeState(state, nextState, { preserveLocalMediaGuard: true });
        publishState();
      }
    } catch (_error) {
      // Keep the last renderer snapshot. If it already says no devices, block
      // before the call action; otherwise fail open and let native report.
    }
  }

  async function ensureDeviceAvailability(devices) {
    if (!Array.isArray(devices) || devices.length === 0) {
      return;
    }
    await refreshDeviceSnapshot();
    if (state.deviceUnavailable) {
      setDeviceUnavailable(null);
    }

    for (const device of devices) {
      if (hasDevice(device)) {
        continue;
      }
      const error = createDeviceUnavailableError(device);
      setDeviceUnavailable({
        device,
      });
      throw error;
    }
  }

  function resolveCallPermissionDevices(callType) {
    return normalizeCallType(callType, 1) === 2
      ? ['microphone', 'camera']
      : ['microphone'];
  }

  function resolveSwitchPermissionDevices(callType) {
    return normalizeCallType(callType, state.callType) === 2
      ? ['camera']
      : ['microphone'];
  }

  function resolveIncomingCallType() {
    return normalizeCallType(
      state.inviteInfo && state.inviteInfo.callType != null
        ? state.inviteInfo.callType
        : state.callType,
      state.callType
    );
  }

  function handleEvent(payload = {}) {
    switch (payload.type) {
      case 'state':
        markKnownDeviceLists(payload.state);
        mergeState(state, payload.state || {}, { preserveLocalMediaGuard: true });
        publishState();
        break;
      case 'call-records:snapshot':
        callRecordSnapshot = {
          records: Array.isArray(payload.records) ? payload.records.slice() : [],
          adapterState:
            payload.adapterState || createInitialCallRecordSnapshot().adapterState,
        };
        publishCallRecords();
        break;
      case 'call-records:adapter-state':
        callRecordSnapshot = {
          records: callRecordSnapshot.records.slice(),
          adapterState:
            payload.adapterState || createInitialCallRecordSnapshot().adapterState,
        };
        publishCallRecords();
        break;
      case 'video-frame': {
        const renderer = videoRenderers.get(Number(payload.rendererId));
        if (
          renderer &&
          renderer.generationId === payload.generationId &&
          !renderer.disposed
        ) {
          renderer.emit('frame', normalizeFrame(payload.frame));
        }
        break;
      }
      case 'ring': {
        // mac IPC topology 下 main 进程 runtime 的 ring callEffects 走这条 IPC 通路：
        //   main runtime startIncomingRing/startOutgoingRing/stopRing →
        //   service.publish({type:'ring', action:'...'}) →
        //   IPC EVENT_CHANNEL → 这里用 DOM Audio 播放
        if (payload.action === 'stop') {
          ringPlayers.stop();
        } else {
          const kind = RING_KIND_BY_ACTION[payload.action];
          if (kind) ringPlayers.start(kind);
        }
        break;
      }
      default:
        break;
    }
  }

  const unsubscribeBridge = typeof bridge.on === 'function'
    ? bridge.on(handleEvent)
    : () => {};

  return {
    __necallkitIpcRuntime: true,
    state,
    neCall: null,
    sdk: null,
    attach() {},
    detach() {},
    destroy() {
      videoRenderers.clear();
      Object.assign(state, createInitialState());
      callRecordSnapshot = createInitialCallRecordSnapshot();
      publishState();
      publishCallRecords();
      return bridge.invoke('destroy', {});
    },
    destroyLocal() {
      unsubscribeBridge();
      videoRenderers.clear();
      ringPlayers.stop();
    },
    subscribe(listener) {
      if (typeof listener !== 'function') {
        return () => {};
      }
      listeners.add(listener);
      listener({ ...state });
      return () => listeners.delete(listener);
    },
    subscribeCallRecords(listener) {
      if (typeof listener !== 'function') {
        return () => {};
      }
      recordListeners.add(listener);
      listener({
        records: callRecordSnapshot.records.slice(),
        adapterState: { ...callRecordSnapshot.adapterState },
      });
      return () => recordListeners.delete(listener);
    },
    getState() {
      return { ...state };
    },
    getDiagnostics() {
      return state.diagnostics;
    },
    getCallRecordSnapshot() {
      return {
        records: callRecordSnapshot.records.slice(),
        adapterState: { ...callRecordSnapshot.adapterState },
      };
    },
    async setup(config) {
      // uikit-owned framework / channel labels: factory captures them so the
      // example renderer never has to fill them in createSetupConfig. Caller
      // values still win — only undefined / empty fields fall back to the
      // factory default.
      const effectiveConfig = Object.assign({}, config);
      if (
        (effectiveConfig.framework == null || effectiveConfig.framework === '') &&
        typeof options.framework === 'string' && options.framework
      ) {
        effectiveConfig.framework = options.framework;
      }
      if (
        (effectiveConfig.channel == null || effectiveConfig.channel === '') &&
        typeof options.channel === 'string' && options.channel
      ) {
        effectiveConfig.channel = options.channel;
      }
      const result = await bridge.invoke('setup', effectiveConfig);
      applySetupResult(result);
      return state.diagnostics;
    },
    async login(config) {
      const result = await bridge.invoke('login', config);
      if (result && result.diagnostics) {
        state.diagnostics = result.diagnostics;
        publishState();
      }
      return state.diagnostics;
    },
    async logout() {
      const result = await bridge.invoke('logout', {});
      if (result && result.diagnostics) {
        state.diagnostics = result.diagnostics;
        publishState();
      }
      return state.diagnostics;
    },
    async call(payload) {
      const devices = resolveCallPermissionDevices(payload && payload.callType);
      return invokeMediaGuarded('call', payload, devices);
    },
    async accept(payload) {
      const devices = resolveCallPermissionDevices(resolveIncomingCallType());
      return invokeMediaGuarded('accept', payload, devices);
    },
    hangup(payload) {
      return bridge.invoke('hangup', payload || {});
    },
    async switchCallType(payload) {
      const switchState = normalizeSwitchState(payload && payload.state);
      if (switchState === 1 || switchState === 2) {
        const devices = resolveSwitchPermissionDevices(
          resolvePayloadCallType(payload, state.callType)
        );
        return invokeMediaGuarded('switchCallType', payload, devices);
      }
      return bridge.invoke('switchCallType', payload);
    },
    refreshDevices() {
      return bridge.invoke('refreshDevices', {});
    },
    setTimeout(seconds) {
      return bridge.invoke('setTimeout', seconds);
    },
    setCallConfig(config) {
      return bridge.invoke('setCallConfig', config);
    },
    getCallConfig() {
      return bridge.invoke('getCallConfig', {});
    },
    getCallInfo() {
      return bridge.invoke('getCallInfo', {});
    },
    async setLocalAudioEnabled(enabled) {
      if (enabled) {
        await ensureMediaPermission(['microphone']);
        await ensureDeviceAvailability(['microphone']);
      }
      state.localAudioEnabled = !!enabled;
      state.localAudioMuted = !state.localAudioEnabled;
      publishState();
      try {
        return await bridge.invoke('setLocalAudioEnabled', !!enabled);
      } catch (error) {
        if (enabled) {
          await rethrowMediaPermissionAfterNativeFailure(error, ['microphone']);
        }
        throw error;
      }
    },
    async setLocalVideoEnabled(enabled) {
      if (enabled) {
        await ensureMediaPermission(['camera']);
        await ensureDeviceAvailability(['camera']);
      }
      state.localVideoEnabled = !!enabled;
      publishState();
      try {
        return await bridge.invoke('setLocalVideoEnabled', !!enabled);
      } catch (error) {
        if (enabled) {
          await rethrowMediaPermissionAfterNativeFailure(error, ['camera']);
        }
        throw error;
      }
    },
    setVideoCaptureDevice(deviceId) {
      state.currentVideoCaptureDeviceId = String(deviceId || '');
      publishState();
      return bridge.invoke('setVideoCaptureDevice', deviceId);
    },
    setAudioRecordingDevice(deviceId) {
      state.currentAudioRecordingDeviceId = String(deviceId || '');
      publishState();
      return bridge.invoke('setAudioRecordingDevice', deviceId);
    },
    setAudioPlaybackDevice(deviceId) {
      state.currentAudioPlaybackDeviceId = String(deviceId || '');
      publishState();
      return bridge.invoke('setAudioPlaybackDevice', deviceId);
    },
    async openPrivacySettings(device) {
      if (!host || typeof host.openPrivacySettings !== 'function') {
        return false;
      }
      try {
        return !!(await host.openPrivacySettings(device));
      } catch (_error) {
        return false;
      }
    },
    dismissPermissionDeniedNotice() {
      if (state.permissionDenied) {
        setPermissionDenied(null);
      }
    },
    dismissDeviceUnavailableNotice() {
      if (state.deviceUnavailable) {
        setDeviceUnavailable(null);
      }
    },
    createVideoRenderer() {
      const renderer = new EventEmitter();
      renderer.rendererId = 0;
      renderer.generationId = 0;
      renderer.disposed = false;
      const ready = bridge.invoke('createVideoRenderer', {}).then((descriptor) => {
        const rendererId = Number(descriptor && descriptor.rendererId);
        if (!Number.isFinite(rendererId) || rendererId <= 0) {
          throw new Error('IPC video renderer descriptor is invalid');
        }
        renderer.rendererId = rendererId;
        renderer.generationId = descriptor.generationId || 0;
        if (!renderer.disposed) {
          videoRenderers.set(rendererId, renderer);
        }
        return {
          rendererId,
          generationId: renderer.generationId,
        };
      });
      renderer.attachToLocalVideo = () =>
        ready.then((descriptor) => {
          if (renderer.disposed) {
            return false;
          }
          return bridge.invoke('attachVideoRenderer', {
            rendererId: descriptor.rendererId,
            generationId: descriptor.generationId,
            target: 'local',
          });
        });
      renderer.attachToRemoteVideo = (remoteAccount) =>
        ready.then((descriptor) => {
          if (renderer.disposed) {
            return false;
          }
          return bridge.invoke('attachVideoRenderer', {
            rendererId: descriptor.rendererId,
            generationId: descriptor.generationId,
            target: 'remote',
            remoteAccount,
          });
        });
      renderer.setMirror = (mirror) =>
        ready.then((descriptor) => {
          if (renderer.disposed) {
            return false;
          }
          return bridge.invoke('setVideoRendererMirror', {
            rendererId: descriptor.rendererId,
            generationId: descriptor.generationId,
            mirror: !!mirror,
          });
        });
      renderer.dispose = async () => {
        if (renderer.disposed) {
          return;
        }
        renderer.disposed = true;
        renderer.removeAllListeners();
        const descriptor = await ready;
        videoRenderers.delete(descriptor.rendererId);
        await bridge.invoke('disposeVideoRenderer', {
          rendererId: descriptor.rendererId,
          generationId: descriptor.generationId,
        });
      };
      return renderer;
    },
  };
}

module.exports = {
  createIpcCallkitRuntime,
};
