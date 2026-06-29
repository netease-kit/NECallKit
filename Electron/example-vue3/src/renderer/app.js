'use strict';

const { h, onBeforeUnmount, ref, watch } = require('vue');
const {
  DemoShellView,
  createDemoShellApp,
  describeError,
  isInCallSnapshot,
  resolveHomeActionToastNotice,
  resolveDebugEnabled,
  useDemoShellState,
} = require('./demo-shell');
const {
  CallViewProvider,
  createCallkitRuntime,
  DEFAULT_RING_ASSETS,
} = require('@xkit-yx/electron-callkit-vue3-uikit');
const {
  createExternalNimSession,
} = require('../lib/example-external-nim-session');
const {
  createCallRecordMessageAdapter,
} = require('../lib/call-record-message-adapter');
const {
  DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
  normalizeDefaultCallRecords,
} = require('../lib/call-record-cache');
const {
  upsertCallRecord,
} = require('../lib/call-records');
const {
  createIpcCallkitRuntime,
} = require('@xkit-yx/electron-callkit-vue3-uikit');
const {
  shouldUseMainSideNativeOwner,
} = require('../lib/main-side-external-ready-probe');
const {
  createRendererWindowCloseHandler,
} = require('../lib/renderer-window-close-handler');

const STORAGE_KEY = 'necallkit.electron.example-vue3.form';
const DEBUG_STORAGE_KEY = 'necallkit.electron.example-vue3.debug';
const LOGIN_MODE = {
  MANAGED: 'managed',
  EXTERNAL: 'external',
};
const INFO_PROMPT_DURATION_MS = 10000;
const DEFAULT_EXTERNAL_READY_TIMEOUT_MS = 5000;
const DEFAULT_EXTERNAL_READY_POLL_MS = 50;
const DEFAULT_FORM = {
  appKey: '',
  accountId: '',
  accountToken: '',
  currentUserRtcUid: '',
  invitee: '',
  callType: 1,
  callTimeoutSeconds: '30',
  enableOffline: true,
  enableSwitchVideoConfirm: false,
  enableSwitchAudioConfirm: false,
  loginMode: LOGIN_MODE.EXTERNAL,
};

function normalizeLoginMode(value) {
  return value === LOGIN_MODE.MANAGED ? LOGIN_MODE.MANAGED : LOGIN_MODE.EXTERNAL;
}

function normalizeElectronFormField(key, value, fallbackValue) {
  switch (key) {
    case 'callType':
      return Number(value) === 1 ? 1 : 2;
    case 'callTimeoutSeconds':
      return String(value ?? '').replace(/\D/g, '').slice(0, 3);
    case 'enableOffline':
      return value !== false;
    case 'enableSwitchVideoConfirm':
    case 'enableSwitchAudioConfirm':
      return Boolean(value);
    case 'loginMode':
      return normalizeLoginMode(value);
    default:
      return typeof value === 'string' ? value : fallbackValue;
  }
}

function buildCallConfig(form) {
  return {
    enableOffline: form.enableOffline !== false,
    enableSwitchVideoConfirm: !!form.enableSwitchVideoConfirm,
    enableSwitchAudioConfirm: !!form.enableSwitchAudioConfirm,
  };
}

function toPromptSerializableValue(value) {
  if (typeof value === 'bigint') {
    return value.toString();
  }
  if (Array.isArray(value)) {
    return value.map((item) => toPromptSerializableValue(item));
  }
  if (value && typeof value === 'object') {
    const result = {};
    Object.keys(value).forEach((key) => {
      result[key] = toPromptSerializableValue(value[key]);
    });
    return result;
  }
  return value;
}

async function readCallInfoPromptPayload(runtime) {
  // mac packaged Electron 24+ 拓扑下 runtime.sdk === null，必须先走 runtime
  // facade（IPC 路径返回 Promise；in-renderer 路径返回同步值，被 Promise.resolve
  // 透传）。仅当 runtime 没有暴露对应 facade 时才回退到 runtime.sdk.* 兼容旧路径。
  const sdk = runtime && runtime.sdk;
  const callInfo =
    runtime && typeof runtime.getCallInfo === 'function'
      ? await Promise.resolve(runtime.getCallInfo())
      : sdk && typeof sdk.getCallInfo === 'function'
        ? sdk.getCallInfo()
        : null;
  const callConfig =
    runtime && typeof runtime.getCallConfig === 'function'
      ? await Promise.resolve(runtime.getCallConfig())
      : sdk && typeof sdk.getCallConfig === 'function'
        ? sdk.getCallConfig()
        : null;
  return {
    getCallInfo: callInfo == null ? null : toPromptSerializableValue(callInfo),
    getCallConfig: callConfig == null ? null : toPromptSerializableValue(callConfig),
  };
}

function formatCallInfoPromptText(payload) {
  const value = payload && typeof payload === 'object' ? payload : {};
  const callInfo = Object.prototype.hasOwnProperty.call(value, 'getCallInfo')
    ? value.getCallInfo
    : null;
  const callConfig = Object.prototype.hasOwnProperty.call(value, 'getCallConfig')
    ? value.getCallConfig
    : null;
  return [
    'getCallInfo',
    JSON.stringify(callInfo, null, 2),
    '',
    'getCallConfig',
    JSON.stringify(callConfig, null, 2),
  ].join('\n');
}

function renderCallInfoPromptControl(prompt, onShow) {
  return [
    h(
      'button',
      {
        class: 'call-info-button',
        type: 'button',
        'aria-label': '查看通话信息和配置',
        title: '查看通话信息和配置',
        onClick: onShow,
      },
      '?'
    ),
    prompt
      ? h('div', { class: 'call-info-toast', role: 'status' }, [
          h('div', { class: 'call-info-toast-title' }, '通话信息'),
          h('pre', { class: 'call-info-toast-content' }, prompt.text || ''),
        ])
      : null,
  ];
}

function resolveCallTimeoutSeconds(form) {
  const seconds = Number.parseInt(String(form.callTimeoutSeconds ?? '').trim(), 10);
  if (!Number.isFinite(seconds) || seconds <= 0) {
    return null;
  }
  return seconds;
}

function readRuntimeState(runtime) {
  if (runtime && typeof runtime.getState === 'function') {
    return runtime.getState();
  }

  if (runtime && runtime.state && typeof runtime.state === 'object') {
    return runtime.state;
  }

  return {};
}

function readRuntimeDiagnostics(runtime) {
  if (runtime && typeof runtime.getDiagnostics === 'function') {
    return runtime.getDiagnostics();
  }

  const state = readRuntimeState(runtime);
  if (state && Object.prototype.hasOwnProperty.call(state, 'diagnostics')) {
    return state.diagnostics;
  }

  return undefined;
}

function isMediaGuardError(error) {
  return !!(
    error &&
    (error.code === 'ECALLKIT_PERMISSION_DENIED' ||
      error.code === 'ECALLKIT_DEVICE_UNAVAILABLE')
  );
}

function delay(ms) {
  if (!ms || ms <= 0) {
    return Promise.resolve();
  }
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function normalizeNonNegativeDuration(value, fallback) {
  const numberValue = Number(value);
  return Number.isFinite(numberValue) && numberValue >= 0 ? numberValue : fallback;
}

function createSetupConfig(form) {
  // framework / channel are intentionally NOT set here — the uikit's
  // createCallkitRuntime / createIpcCallkitRuntime factories inject them
  // ('electron-vue3' / 'electron') at runtime.setup time so the example
  // demo never has to know these labels.
  const config = {
    appKey: form.appKey.trim(),
    accountId: form.accountId.trim(),
    accountToken: form.accountToken.trim(),
    currentUserRtcUid: Number(form.currentUserRtcUid) || 0,
  };
  const initRtcMode = process.env.NECALL_EXAMPLE_INIT_RTC_MODE;
  const preferredVideoRenderMode =
    process.env.NECALL_EXAMPLE_PREFERRED_VIDEO_RENDER_MODE;
  if (initRtcMode) {
    config.initRtcMode = String(initRtcMode).trim();
  }
  if (preferredVideoRenderMode) {
    config.preferredVideoRenderMode = String(preferredVideoRenderMode).trim();
  }
  return config;
}

function normalizeRuntimeSetupConfig(config = {}) {
  // framework / channel are uikit-internal labels (see createSetupConfig);
  // they are not part of the example's caller-facing config and therefore
  // don't participate in this equality check.
  return {
    accountId: String(config.accountId || '').trim(),
    appKey: String(config.appKey || '').trim(),
    currentUserRtcUid: Number(config.currentUserRtcUid) || 0,
    initRtcMode: config.initRtcMode || 'global',
    preferredVideoRenderMode: config.preferredVideoRenderMode || 'auto',
  };
}

function isSameRuntimeSetupConfig(left, right) {
  if (!left || !right) {
    return false;
  }
  const normalizedLeft = normalizeRuntimeSetupConfig(left);
  const normalizedRight = normalizeRuntimeSetupConfig(right);
  return Object.keys(normalizedLeft).every(
    (key) => normalizedLeft[key] === normalizedRight[key]
  );
}

function resolveExampleExternalOwnerMode(options = {}) {
  return (
    options.externalOwnerMode ||
    process.env.NECALL_EXAMPLE_EXTERNAL_OWNER_MODE ||
    'node-nim'
  );
}

function resolveDefaultRuntime(options = {}) {
  const host =
    options.host || (typeof window !== 'undefined' ? window.electronCallkitHost : null);
  if (
    shouldUseMainSideNativeOwner({
      platform: process.platform,
      versions: process.versions,
    })
  ) {
    if (host && host.callkit) {
      // mac IPC topology：把 vue3-uikit 的 DEFAULT_RING_ASSETS（file:// URL）注入给
      // ipc-callkit-runtime，让它在收到 main 端的 'ring' IPC 事件时用 DOM Audio 播铃声
      // （main 进程没有 window/Audio，DOM-based ring 路径只能跑在 renderer）
      return createIpcCallkitRuntime(host, {
        ringAssets: DEFAULT_RING_ASSETS,
      });
    }
    const error = new Error(
      'Electron CallKit example requires an injected IPC runtime on macOS Electron 24+'
    );
    error.code = 'NECALL_MAIN_SIDE_RUNTIME_REQUIRED';
    throw error;
  }
  return createCallkitRuntime();
}

function createExampleExternalNimSession(options = {}) {
  const sessionOptions = Object.assign({}, options, {
    externalOwnerMode: resolveExampleExternalOwnerMode(options),
    requireV2: options.requireV2 !== undefined ? !!options.requireV2 : true,
    requireFn: options.nodeNimRequire || options.requireFn || require,
    resolveFn: options.nodeNimResolve || options.resolveFn || require.resolve,
  });

  if (options.nodeNimModule) {
    sessionOptions.nimModule = options.nodeNimModule;
  }

  return createExternalNimSession(sessionOptions);
}

function ensureExternalReady(diagnostics, accountId) {
  if (!diagnostics) {
    throw new Error('CallKit diagnostics missing after external setup');
  }
  if (diagnostics.mode !== LOGIN_MODE.EXTERNAL) {
    throw new Error(`Expected external diagnostics mode, got ${diagnostics.mode || 'unknown'}`);
  }
  if (diagnostics.currentAccountId && diagnostics.currentAccountId !== accountId) {
    throw new Error(
      `CallKit runtime current account mismatch: expected ${accountId}, got ${diagnostics.currentAccountId}`
    );
  }
  if (diagnostics.readyState !== 'ready') {
    return {
      degraded: true,
      message:
        diagnostics.currentAccountId && diagnostics.currentAccountId === accountId
          ? 'External runtime account is visible, but the native bridge cannot confirm IM-ready yet. ' +
            'This is allowed for legacy bridge / without-nim packaging; IM-ready actions will still fail-fast until diagnostics turns ready.'
          : `External runtime setup completed without IM-ready diagnostics: ${diagnostics.reason || 'UNKNOWN'}`,
    };
  }
  return {
    degraded: false,
    message: '',
  };
}

async function waitForExternalReady(runtime, accountId, options = {}, initialDiagnostics) {
  const timeoutMs = normalizeNonNegativeDuration(
    options.externalReadyTimeoutMs,
    DEFAULT_EXTERNAL_READY_TIMEOUT_MS
  );
  const pollMs = normalizeNonNegativeDuration(
    options.externalReadyPollMs,
    DEFAULT_EXTERNAL_READY_POLL_MS
  );
  const deadline = Date.now() + timeoutMs;
  let diagnostics = initialDiagnostics;

  while (true) {
    if (!diagnostics) {
      diagnostics = readRuntimeDiagnostics(runtime);
    }

    const externalSetupState = ensureExternalReady(diagnostics, accountId);
    if (!externalSetupState.degraded) {
      return {
        diagnostics,
        externalSetupState,
      };
    }

    if (Date.now() >= deadline) {
      const reason = diagnostics && diagnostics.reason ? diagnostics.reason : 'UNKNOWN';
      throw new Error(
        `External runtime not ready after setup: ${reason}`
      );
    }

    const remainingMs = Math.max(0, deadline - Date.now());
    await delay(Math.max(1, Math.min(pollMs || 1, remainingMs || 1)));
    diagnostics = readRuntimeDiagnostics(runtime);
  }
}

function ensureManagedReady(diagnostics, accountId) {
  if (!diagnostics) {
    throw new Error('CallKit diagnostics missing after managed login');
  }

  if (diagnostics.mode !== LOGIN_MODE.MANAGED) {
    throw new Error(`Expected managed diagnostics mode, got ${diagnostics.mode || 'unknown'}`);
  }

  if (diagnostics.readyState !== 'ready') {
    throw new Error(
      `Managed runtime not ready after login: ${diagnostics.reason || 'UNKNOWN'}`
    );
  }

  if (diagnostics.currentAccountId && diagnostics.currentAccountId !== accountId) {
    throw new Error(
      `CallKit runtime current account mismatch: expected ${accountId}, got ${diagnostics.currentAccountId}`
    );
  }
}

function createExampleApp(options = {}) {
  const runtime = options.runtime || resolveDefaultRuntime(options);
      // Expose the instance to window for local manual debugging.
  if (typeof window !== 'undefined') {
    window.$callkit = runtime;
  }
  const callInfoPrompt = ref(null);
  let callInfoPromptTimer = null;
  const storage = options.storage || (typeof window !== 'undefined' ? window.localStorage : null);
  const host =
    options.host || (typeof window !== 'undefined' ? window.electronCallkitHost : null);
  const locationSearch =
    options.locationSearch !== undefined
      ? options.locationSearch
      : typeof window !== 'undefined' &&
          window.location &&
          typeof window.location.search === 'string'
        ? window.location.search
        : '';
  const externalNimSessionFactory =
    options.externalNimSessionFactory ||
    ((sessionOptions) =>
      createExampleExternalNimSession(
        Object.assign({}, sessionOptions, {
          nodeNimModule: options.nodeNimModule,
          nodeNimRequire: options.nodeNimRequire,
          nodeNimResolve: options.nodeNimResolve,
          resourcesPath: options.resourcesPath,
          stagedNativeAddonPath: options.stagedNativeAddonPath,
          externalOwnerMode: options.externalOwnerMode,
        })
      ));

  return createDemoShellApp({
    name: 'ElectronVue3ExampleApp',
    setup() {
      const shell = useDemoShellState({
        storage,
        storageKey: STORAGE_KEY,
        debugStorageKey: DEBUG_STORAGE_KEY,
        callRecordStorageKey: `${STORAGE_KEY}.default-call-records`,
        locationSearch,
        initialForm: Object.assign({}, DEFAULT_FORM, options.initialForm || {}),
        persistFormKeys: [
          'enableOffline',
          'enableSwitchVideoConfirm',
          'enableSwitchAudioConfirm',
        ],
        initialInitialized: options.initialInitialized,
        initialRuntimeDiagnostics:
          options.initialRuntimeDiagnostics || runtime.getDiagnostics?.() || runtime.state?.diagnostics,
        debugEnabled:
          options.debugEnabled !== undefined
            ? !!options.debugEnabled
            : resolveDebugEnabled(locationSearch, storage, DEBUG_STORAGE_KEY),
        // When autoLogin is disabled by the host, remembered login is skipped.
        autoLogin: options.autoLogin,
        normalizeField: normalizeElectronFormField,
      });

      let activeOwnership = shell.initialized.value
        ? normalizeLoginMode(shell.form.loginMode)
        : null;
      let externalSession = null;
      let callRecordAdapter = null;
      const useMainSideRuntime = !!runtime.__necallkitIpcRuntime;
      function applyMainSideCallRecordSnapshot(snapshot = {}) {
        const records = Array.isArray(snapshot.records) ? snapshot.records : [];
        // Empty IPC snapshots describe adapter lifecycle; they must not erase persisted renderer cache.
        if (records.length > 0) {
          const mergedRecords = records.reduce(
            (currentRecords, record) =>
              upsertCallRecord(currentRecords, record, {
                limit: DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
              }),
            normalizeDefaultCallRecords(shell.callRecords.value, {
              limit: DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
            })
          );
          shell.setCallRecords(mergedRecords);
        }
        shell.setCallRecordAdapterState(snapshot.adapterState);
      }
      const unsubscribeMainSideCallRecords =
        useMainSideRuntime && typeof runtime.subscribeCallRecords === 'function'
          ? runtime.subscribeCallRecords((snapshot) => {
              applyMainSideCallRecordSnapshot(snapshot);
            })
          : null;
      let activeRuntimeSetupConfig = shell.initialized.value
        ? createSetupConfig(shell.form)
        : null;
      let activeRuntimeSetupMode = shell.initialized.value
        ? normalizeLoginMode(shell.form.loginMode)
        : null;
      let homeNoticeToastKey = '';
      let kickedOfflineLogoutInFlight = false;
      let lifecycleOperation = Promise.resolve();
      let lifecycleOperationPending = false;
      let lifecycleOperationId = 0;

      function runLifecycleOperation(operation) {
        let nextOperation;
        if (lifecycleOperationPending) {
          nextOperation = lifecycleOperation.catch(() => {}).then(operation);
        } else {
          try {
            nextOperation = Promise.resolve(operation());
          } catch (error) {
            nextOperation = Promise.reject(error);
          }
        }

        const operationId = ++lifecycleOperationId;
        lifecycleOperationPending = true;
        lifecycleOperation = nextOperation
          .catch(() => {})
          .finally(() => {
            if (operationId === lifecycleOperationId) {
              lifecycleOperationPending = false;
            }
          });
        return nextOperation;
      }

      function syncRuntimeState() {
        shell.setRuntimeState(readRuntimeState(runtime));
      }

      function refreshDiagnostics() {
        try {
          if (typeof runtime.getDiagnostics === 'function') {
            shell.setRuntimeDiagnostics(runtime.getDiagnostics());
          } else {
            shell.setRuntimeDiagnostics(runtime.state && runtime.state.diagnostics);
          }

          if (runtime.sdk && typeof runtime.sdk.getVersion === 'function') {
            shell.setSdkVersion(runtime.sdk.getVersion());
          }

          if (runtime.sdk && typeof runtime.sdk.getBridgeDiagnostics === 'function') {
            shell.setBridgeDiagnostics(runtime.sdk.getBridgeDiagnostics());
          }
        } catch (error) {
          shell.appendLog('error', 'getBridgeDiagnostics', describeError(error));
        }
      }

      function syncCallConfig() {
        const setCallConfigFn =
          typeof runtime.setCallConfig === 'function'
            ? (cfg) => runtime.setCallConfig(cfg)
            : runtime.sdk && typeof runtime.sdk.setCallConfig === 'function'
              ? (cfg) => runtime.sdk.setCallConfig(cfg)
              : null;
        if (!setCallConfigFn) {
          return false;
        }

        const nextCallConfig = buildCallConfig(shell.form);
        setCallConfigFn(nextCallConfig);
        shell.appendLog('info', 'setCallConfig', nextCallConfig);
        return true;
      }

      function syncCallTimeout() {
        const setTimeoutFn =
          typeof runtime.setTimeout === 'function'
            ? (sec) => runtime.setTimeout(sec)
            : runtime.sdk && typeof runtime.sdk.setTimeout === 'function'
              ? (sec) => runtime.sdk.setTimeout(sec)
              : null;
        if (!setTimeoutFn) {
          return false;
        }

        const seconds = resolveCallTimeoutSeconds(shell.form);
        if (!seconds) {
          return false;
        }

        setTimeoutFn(seconds);
        shell.appendLog('info', 'setTimeout', { seconds });
        return true;
      }

      function syncDefaultCallRecordProvider() {
        if (!runtime.sdk || typeof runtime.sdk.setCallRecordProvider !== 'function') {
          return false;
        }

        try {
          runtime.sdk.setCallRecordProvider(false);
          shell.appendLog('info', 'setCallRecordProvider', {
            enabled: false,
            owner: 'desktop-default',
          });
          return true;
        } catch (error) {
          shell.appendLog('warn', 'setCallRecordProvider.unavailable', {
            enabled: false,
            owner: 'desktop-default',
            message: describeError(error),
            code: error && error.code ? error.code : undefined,
          });
          return false;
        }
      }

      function syncInitializedCallConfig() {
        if (!shell.initialized.value) {
          return;
        }
        try {
          syncCallConfig();
        } catch (error) {
          shell.appendLog('error', 'setCallConfig', describeError(error));
        }
      }

      function syncInitializedCallTimeout() {
        if (!shell.initialized.value) {
          return;
        }
        try {
          syncCallTimeout();
        } catch (error) {
          shell.appendLog('error', 'setTimeout', describeError(error));
        }
      }

      function stopCallRecordAdapter() {
        if (!callRecordAdapter) {
          return;
        }
        const state = callRecordAdapter.stop();
        callRecordAdapter = null;
        shell.setCallRecordAdapterState(state);
      }

      async function startCallRecordAdapter(setupConfig) {
        if (useMainSideRuntime) {
          if (typeof runtime.getCallRecordSnapshot === 'function') {
            const snapshot = runtime.getCallRecordSnapshot();
            applyMainSideCallRecordSnapshot(snapshot);
          }
          return;
        }
        stopCallRecordAdapter();
        callRecordAdapter = createCallRecordMessageAdapter({
          externalSession,
          selfAccountId: setupConfig.accountId,
          records: shell.callRecords.value,
          limit: DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
          historyLimit: 20,
          onRecords(records, detail) {
            shell.setCallRecords(records);
            shell.setCallRecordAdapterState(detail && detail.state);
          },
          onDebugLog(level, label, payload) {
            shell.appendLog(level, label, payload);
          },
        });

        const state = await callRecordAdapter.start();
        shell.setCallRecordAdapterState(state);
        shell.appendLog(state.ready ? 'info' : 'error', 'callRecord.adapter.state', state);
      }

      async function showCallInfoPrompt() {
        let text = '';
        try {
          text = formatCallInfoPromptText(await readCallInfoPromptPayload(runtime));
          shell.appendLog('info', 'getCallInfo/getCallConfig', text);
        } catch (error) {
          text = `读取失败：${describeError(error)}`;
          shell.appendLog('error', 'getCallInfo/getCallConfig', describeError(error));
        }

        if (callInfoPromptTimer) {
          clearTimeout(callInfoPromptTimer);
        }
        callInfoPrompt.value = { text };
        callInfoPromptTimer = setTimeout(() => {
          callInfoPrompt.value = null;
          callInfoPromptTimer = null;
        }, INFO_PROMPT_DURATION_MS);
      }

      function hideCallInfoPrompt() {
        if (callInfoPromptTimer) {
          clearTimeout(callInfoPromptTimer);
          callInfoPromptTimer = null;
        }
        callInfoPrompt.value = null;
      }

      async function teardownRuntime(options = {}) {
        const silent = !!options.silent;
        const destroyNative = options.destroyNative !== false;
        const destroyExternalSession = options.destroyExternalSession !== false;
        const logoutExternalSession = options.logoutExternalSession !== false;
        const clearRuntimeDiagnostics = options.clearRuntimeDiagnostics !== false;
        const previousOwnership = activeOwnership;
        activeOwnership = null;
        shell.hideActionToast();

        try {
          stopCallRecordAdapter();
        } catch (error) {
          if (!silent) {
            shell.appendLog('error', 'callRecord.adapter.stop', describeError(error));
          }
        }

        try {
          if (
            previousOwnership === LOGIN_MODE.MANAGED &&
            shell.initialized.value &&
            typeof runtime.logout === 'function'
          ) {
            const diagnostics = await runtime.logout();
            shell.setRuntimeDiagnostics(diagnostics);

            if (!silent) {
              shell.appendLog('info', 'logout.managed', diagnostics);
            }
          }
        } catch (error) {
          if (!silent) {
            shell.appendLog('error', 'logout.managed', describeError(error));
          }
        }

        if (destroyNative) {
          try {
            if (typeof runtime.destroy === 'function') {
              await runtime.destroy();
            }
            activeRuntimeSetupConfig = null;
            activeRuntimeSetupMode = null;
          } catch (error) {
            activeRuntimeSetupConfig = null;
            activeRuntimeSetupMode = null;
            if (!silent) {
              shell.appendLog('error', 'destroy', describeError(error));
            }
          }
        }

        if (externalSession && logoutExternalSession) {
          try {
            if (
              destroyExternalSession &&
              typeof externalSession.destroy === 'function'
            ) {
              await externalSession.destroy();
            } else {
              await externalSession.logout();
            }

            if (!silent) {
              shell.appendLog('info', 'logout.external', {});
            }
          } catch (error) {
            if (!silent) {
              shell.appendLog('error', 'logout.external', describeError(error));
            }
          } finally {
            if (destroyExternalSession) {
              externalSession = null;
            }
          }
        }

        shell.setInitialized(false);
        if (clearRuntimeDiagnostics) {
          shell.setSdkVersion('');
          shell.setBridgeDiagnostics(null);
          shell.setRuntimeDiagnostics(undefined);
        } else {
          refreshDiagnostics();
        }
        shell.clearCallRecordsView();
        shell.setCallRecordAdapterState({
          started: false,
          ready: false,
          error: '',
          historyError: '',
          lastMessageId: '',
          recordCount: 0,
          sourceCounts: {},
        });
        hideCallInfoPrompt();
        syncRuntimeState();
      }

      async function ensureRuntimeSetup(setupConfig, loginMode) {
        if (
          activeRuntimeSetupMode === loginMode &&
          isSameRuntimeSetupConfig(activeRuntimeSetupConfig, setupConfig)
        ) {
          const diagnostics = readRuntimeDiagnostics(runtime);
          if (diagnostics) {
            return diagnostics;
          }
        }

        if (activeRuntimeSetupConfig) {
          await teardownRuntime({
            silent: true,
            destroyNative: true,
            destroyExternalSession: false,
            logoutExternalSession: false,
          });
        }

        const diagnostics = await runtime.setup(setupConfig);
        activeRuntimeSetupConfig = setupConfig;
        activeRuntimeSetupMode = loginMode;
        return diagnostics;
      }

      async function teardownStaleRuntimeSetup(setupConfig, loginMode) {
        if (
          !activeRuntimeSetupConfig ||
          (activeRuntimeSetupMode === loginMode &&
            isSameRuntimeSetupConfig(activeRuntimeSetupConfig, setupConfig))
        ) {
          return;
        }

        // Account switching must clear the old CallKit runtime before the next
        // external NIM login; destroying after login can tear down the new shared runtime.
        await teardownRuntime({
          silent: true,
          destroyNative: true,
          destroyExternalSession: false,
          logoutExternalSession: false,
        });
      }

      async function setupRuntime() {
        return runLifecycleOperation(async () => {
          if (!shell.form.appKey.trim()) {
            shell.showActionToast('AppKey不能为空!');
            return;
          }
          if (!shell.form.accountId.trim()) {
            shell.showActionToast('账号不能为空!');
            return;
          }
          if (!shell.form.accountToken.trim()) {
            shell.showActionToast('Token不能为空!');
            return;
          }

          shell.hideActionToast();
          shell.setBusy(true);
          shell.persistForm();
          shell.persistRememberedLogin();

          try {
            const nextLoginMode = normalizeLoginMode(shell.form.loginMode);
            if (shell.initialized.value || activeOwnership) {
              await teardownRuntime({
                silent: true,
                destroyNative: nextLoginMode !== LOGIN_MODE.EXTERNAL,
                destroyExternalSession: nextLoginMode !== LOGIN_MODE.EXTERNAL,
                clearRuntimeDiagnostics: nextLoginMode !== LOGIN_MODE.EXTERNAL,
              });
            }

            const setupConfig = createSetupConfig(shell.form);
            console.log(
              '[necall-example][setup-config]',
              JSON.stringify({
                initRtcMode: setupConfig.initRtcMode || 'global',
                preferredVideoRenderMode:
                  setupConfig.preferredVideoRenderMode || 'auto',
              })
            );

            if (nextLoginMode === LOGIN_MODE.EXTERNAL) {
              await teardownStaleRuntimeSetup(setupConfig, LOGIN_MODE.EXTERNAL);

              if (!useMainSideRuntime && !externalSession) {
                externalSession = externalNimSessionFactory({
                  scope: 'example-vue3',
                });
              }

              shell.appendLog('info', 'externalNim.owner', {
                preferredOwner: useMainSideRuntime
                  ? 'main-side-ipc'
                  : resolveExampleExternalOwnerMode(options),
              });
              if (!useMainSideRuntime) {
                const sessionResult = await externalSession.login(setupConfig);
                shell.appendLog('info', 'externalNim.login', sessionResult);
              }

              const setupDiagnostics = await ensureRuntimeSetup(
                setupConfig,
                LOGIN_MODE.EXTERNAL
              );
              shell.setRuntimeDiagnostics(setupDiagnostics);
              refreshDiagnostics();
              const { diagnostics } =
                await waitForExternalReady(
                  runtime,
                  setupConfig.accountId,
                  options,
                  shell.runtimeDiagnostics.value || setupDiagnostics
                );
              shell.setRuntimeDiagnostics(diagnostics);
              activeOwnership = LOGIN_MODE.EXTERNAL;
              shell.appendLog('info', 'setup.external', {
                accountId: setupConfig.accountId,
                diagnostics: shell.runtimeDiagnostics.value,
                degraded: false,
              });
            } else {
              if (externalSession) {
                try {
                  await externalSession.destroy();
                } finally {
                  externalSession = null;
                }
              }
              const diagnostics = await ensureRuntimeSetup(
                setupConfig,
                LOGIN_MODE.MANAGED
              );
              shell.setRuntimeDiagnostics(diagnostics);
              shell.appendLog('info', 'setup', {
                accountId: setupConfig.accountId,
                framework: host && host.framework,
              });
              const loginDiagnostics = await runtime.login({
                accountId: setupConfig.accountId,
                accountToken: setupConfig.accountToken,
              });
              shell.setRuntimeDiagnostics(loginDiagnostics);
              refreshDiagnostics();
              const managedDiagnostics =
                shell.runtimeDiagnostics.value &&
                shell.runtimeDiagnostics.value.mode === LOGIN_MODE.MANAGED
                  ? shell.runtimeDiagnostics.value
                  : loginDiagnostics;
              shell.setRuntimeDiagnostics(managedDiagnostics);
              ensureManagedReady(managedDiagnostics, setupConfig.accountId);
              activeOwnership = LOGIN_MODE.MANAGED;
              shell.appendLog('info', 'login.managed', managedDiagnostics);
            }

            shell.loadCachedCallRecords(setupConfig.accountId);
            if (!useMainSideRuntime) {
              syncDefaultCallRecordProvider();
            }
            await startCallRecordAdapter(setupConfig);
            shell.setInitialized(true);
            syncRuntimeState();
            refreshDiagnostics();
            syncCallTimeout();
            syncCallConfig();
          } catch (error) {
            shell.clearRememberedLogin();
            await teardownRuntime({
              silent: true,
              destroyNative: true,
              destroyExternalSession: true,
            });
            shell.appendLog('error', 'setup', describeError(error));
            shell.showActionToast(`初始化失败：${describeError(error)}`);
          } finally {
            shell.setBusy(false);
          }
        });
      }

      async function startCall() {
        if (!shell.initialized.value) {
          shell.showActionToast('请先完成初始化');
          return;
        }
        if (!shell.form.invitee.trim()) {
          shell.showActionToast('请输入账号ID');
          return;
        }
        if (shell.form.invitee.trim() === shell.form.accountId.trim()) {
          shell.showActionToast('不能呼叫自己');
          return;
        }

        shell.setBusy(true);
        shell.persistForm();
        shell.hideActionToast();

        try {
          await runtime.call({
            accId: shell.form.invitee.trim(),
            callType: shell.form.callType,
          });
          shell.appendLog('info', 'call', {
            invitee: shell.form.invitee.trim(),
            callType: shell.form.callType,
          });
          syncRuntimeState();
        } catch (error) {
          shell.appendLog('error', 'call', describeError(error));
          if (isMediaGuardError(error)) {
            syncRuntimeState();
            return;
          }
          shell.showActionToast(`呼叫失败：${describeError(error)}`);
        } finally {
          shell.setBusy(false);
        }
      }

      async function acceptCall() {
        shell.setBusy(true);

        try {
          await runtime.accept();
          shell.appendLog('info', 'accept', runtime.state && runtime.state.inviteInfo);
          syncRuntimeState();
        } catch (error) {
          shell.appendLog('error', 'accept', describeError(error));
          if (isMediaGuardError(error)) {
            syncRuntimeState();
            return;
          }
          shell.showActionToast(`接听失败：${describeError(error)}`);
        } finally {
          shell.setBusy(false);
        }
      }

      function hangupCall() {
        shell.setBusy(true);

        try {
          runtime.hangup({});
          shell.appendLog('info', 'hangup', runtime.state && runtime.state.callInfo);
          syncRuntimeState();
        } catch (error) {
          shell.appendLog('error', 'hangup', describeError(error));
          shell.showActionToast(`挂断失败：${describeError(error)}`);
        } finally {
          shell.setBusy(false);
        }
      }

      async function destroyRuntime() {
        return runLifecycleOperation(async () => {
          shell.setBusy(true);

          try {
            shell.clearRememberedLogin();
            await teardownRuntime();
            shell.appendLog('info', 'destroy', {});
          } catch (error) {
            shell.appendLog('error', 'destroy', describeError(error));
            shell.showActionToast(`销毁失败：${describeError(error)}`);
          } finally {
            shell.setBusy(false);
          }
        });
      }

      function logoutRuntime() {
        return runLifecycleOperation(() => {
          shell.clearRememberedLogin();
          shell.clearCachedForm();
          shell.setBusy(true);

          return teardownRuntime({
            destroyNative: false,
            destroyExternalSession: false,
            clearRuntimeDiagnostics: false,
          })
            .then(() => {
              shell.appendLog('info', 'logout', {});
            })
            .catch((error) => {
              shell.appendLog('error', 'logout', describeError(error));
              shell.showActionToast(`退出登录失败：${describeError(error)}`);
            })
            .finally(() => {
              shell.setBusy(false);
            });
        });
      }

      function handleKickedOfflineState(nextState) {
        if (
          kickedOfflineLogoutInFlight ||
          !shell.initialized.value ||
          !nextState ||
          !nextState.kickedOfflineInfo
        ) {
          return;
        }

        kickedOfflineLogoutInFlight = true;
        shell.appendLog('info', 'onKickedOffline', nextState.kickedOfflineInfo);
        destroyRuntime().finally(() => {
          kickedOfflineLogoutInFlight = false;
        });
      }

      syncRuntimeState();

      if (shell.initialized.value) {
        refreshDiagnostics();
      }

      const stopCallConfigWatch = watch(
        () => [
          shell.initialized.value,
          shell.form.enableOffline,
          shell.form.enableSwitchVideoConfirm,
          shell.form.enableSwitchAudioConfirm,
        ],
        syncInitializedCallConfig
      );
      const stopCallTimeoutWatch = watch(
        () => [shell.initialized.value, shell.form.callTimeoutSeconds],
        syncInitializedCallTimeout
      );
      const unsubscribe =
        runtime && typeof runtime.subscribe === 'function'
          ? runtime.subscribe((nextState) => {
              shell.setRuntimeState(nextState);
              handleKickedOfflineState(nextState);
              if (!isInCallSnapshot(nextState)) {
                hideCallInfoPrompt();
              }
              const homeNoticeToast = resolveHomeActionToastNotice(nextState);
              if (homeNoticeToast) {
                if (homeNoticeToastKey !== homeNoticeToast.key) {
                  homeNoticeToastKey = homeNoticeToast.key;
                  shell.showActionToast(homeNoticeToast.text, homeNoticeToast.kind);
                }
              } else if (!nextState.noticeText) {
                homeNoticeToastKey = '';
              }
            })
          : () => {};

      const handleReceiveInvited = (payload) => {
        shell.appendLog('info', 'onReceiveInvited', payload);
      };
      const handleCallConnected = (payload) => {
        shell.appendLog('info', 'onCallConnected', payload);
      };
      const handleCallEnd = (payload) => {
        shell.appendLog('info', 'onCallEnd', payload);
      };
      const handleCallTypeChange = (payload) => {
        shell.appendLog('info', 'onCallTypeChange', payload);
      };
      const handleRecordSend = (payload) => {
        shell.appendLog('info', 'onRecordSend', payload);
      };
      const handleNativeEvent = (payload) => {
        shell.appendLog('info', 'nativeEvent', payload);
      };

      if (runtime.sdk && typeof runtime.sdk.on === 'function') {
        runtime.sdk.on('onReceiveInvited', handleReceiveInvited);
        runtime.sdk.on('onCallConnected', handleCallConnected);
        runtime.sdk.on('onCallEnd', handleCallEnd);
        runtime.sdk.on('onCallTypeChange', handleCallTypeChange);
        runtime.sdk.on('onRecordSend', handleRecordSend);
        runtime.sdk.on('nativeEvent', handleNativeEvent);
      }

      shell.appendLog('info', 'app-mounted', {
        framework: host && host.framework,
        debugEnabled: shell.debugEnabled.value,
      });

      if (shell.autoLoginOnStart) {
        Promise.resolve().then(() => setupRuntime());
      }

      if (typeof window !== 'undefined') {
        const windowCloseHandler = createRendererWindowCloseHandler({
          runtime,
          teardown: (teardownOptions) => teardownRuntime(teardownOptions),
        });
        window.__NECALL_HANDLE_WINDOW_CLOSE__ = windowCloseHandler;

        onBeforeUnmount(() => {
          if (window.__NECALL_HANDLE_WINDOW_CLOSE__ === windowCloseHandler) {
            delete window.__NECALL_HANDLE_WINDOW_CLOSE__;
          }
        });
      }

      onBeforeUnmount(() => {
        stopCallConfigWatch();
        stopCallTimeoutWatch();
        if (callInfoPromptTimer) {
          clearTimeout(callInfoPromptTimer);
          callInfoPromptTimer = null;
        }
        shell.hideActionToast();

        unsubscribe();
        if (unsubscribeMainSideCallRecords) {
          unsubscribeMainSideCallRecords();
        }
        if (
          useMainSideRuntime &&
          runtime &&
          typeof runtime.destroyLocal === 'function'
        ) {
          runtime.destroyLocal();
        }

        if (runtime.sdk && typeof runtime.sdk.off === 'function') {
          runtime.sdk.off('onReceiveInvited', handleReceiveInvited);
          runtime.sdk.off('onCallConnected', handleCallConnected);
          runtime.sdk.off('onCallEnd', handleCallEnd);
          runtime.sdk.off('onCallTypeChange', handleCallTypeChange);
          runtime.sdk.off('onRecordSend', handleRecordSend);
          runtime.sdk.off('nativeEvent', handleNativeEvent);
        }
      });

      return () =>
        h(
          CallViewProvider,
          {
            runtime,
            switchCallTypeConfig: {
              switchToVideo: true,
              switchToAudio: true,
            },
            suppressIdleNotice: true,
          },
          () => [
            h(DemoShellView, {
              initialized: shell.initialized.value,
              form: shell.form,
              busy: shell.busy.value,
              debugEnabled: shell.debugEnabled.value,
              sdkVersion: shell.sdkVersion.value,
              runtimeDiagnostics: shell.runtimeDiagnostics.value,
              bridgeDiagnostics: shell.bridgeDiagnostics.value,
              callInfo: shell.callInfo.value,
              inviteInfo: shell.inviteInfo.value,
              lastEndInfo: shell.lastEndInfo.value,
              callRecords: shell.callRecords.value,
              callActionToast: shell.actionToast.value,
              logs: shell.logs.value,
              showManagedToggle: true,
              'onUpdate:loginMode': (value) => {
                shell.patchForm({
                  loginMode: value,
                });
              },
              'onUpdate:accountId': (value) => {
                shell.patchForm({
                  accountId: value,
                });
              },
              'onUpdate:accountToken': (value) => {
                shell.patchForm({
                  accountToken: value,
                });
              },
              'onUpdate:invitee': (value) => {
                shell.patchForm({
                  invitee: value,
                });
              },
              'onUpdate:callType': (value) => {
                shell.patchForm({
                  callType: value,
                });
              },
              'onUpdate:callTimeoutSeconds': (value) => {
                shell.patchForm({
                  callTimeoutSeconds: value,
                });
                if (shell.initialized.value) {
                  syncCallTimeout();
                }
              },
              'onUpdate:enableOffline': (value) => {
                shell.patchForm({
                  enableOffline: value,
                });
                if (shell.initialized.value) {
                  syncCallConfig();
                }
              },
              'onUpdate:enableSwitchVideoConfirm': (value) => {
                shell.patchForm({
                  enableSwitchVideoConfirm: value,
                });
                if (shell.initialized.value) {
                  syncCallConfig();
                }
              },
              'onUpdate:enableSwitchAudioConfirm': (value) => {
                shell.patchForm({
                  enableSwitchAudioConfirm: value,
                });
                if (shell.initialized.value) {
                  syncCallConfig();
                }
              },
              onSubmitLogin: () => setupRuntime(),
              onSubmitCall: () => startCall(),
              onAccept: () => acceptCall(),
              onHangup: () => hangupCall(),
              onDestroy: () => destroyRuntime(),
              onLogout: () => logoutRuntime(),
            }),
            isInCallSnapshot(shell.runtimeState.value)
              ? renderCallInfoPromptControl(callInfoPrompt.value, () => showCallInfoPrompt())
              : null,
          ]
        );
    },
  });
}

module.exports = {
  DEFAULT_FORM,
  INFO_PROMPT_DURATION_MS,
  createExampleExternalNimSession,
  createExampleApp,
  formatCallInfoPromptText,
  isMediaGuardError,
  normalizeElectronFormField,
  readCallInfoPromptPayload,
  resolveDebugEnabled,
  resolveDefaultRuntime,
};
