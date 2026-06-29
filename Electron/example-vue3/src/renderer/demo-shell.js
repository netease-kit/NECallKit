'use strict';

const { computed, defineComponent, h, reactive, ref } = require('vue');
const { LoginView } = require('./components/LoginView');
const { HomeView } = require('./components/HomeView');
const { DebugPanel } = require('./components/DebugPanel');
const {
  formatLoginErrorMessage,
} = require('../lib/example-error-message');
const {
  DEFAULT_VISIBLE_CALL_RECORD_LIMIT,
  createCallRecordCacheKey,
  normalizeDefaultCallRecords,
  readStoredCallRecords,
  writeStoredCallRecords,
} = require('../lib/call-record-cache');

const DEFAULT_LOG_LIMIT = 60;
const CALL_RECORD_LIMIT = DEFAULT_VISIBLE_CALL_RECORD_LIMIT;
const DEFAULT_ACTION_TOAST_DURATION_MS = 5000;
const OMITTED_STORED_FORM_FIELDS = new Set(['accountId', 'accountToken', 'invitee', 'callType']);
const STORED_LOGIN_FORM_FIELDS = new Set([
  'appKey',
  'accountId',
  'accountToken',
  'currentUserRtcUid',
  'loginMode',
]);
const CALL_END_REASON_FALLBACK_TEXT = {
  1: 'Token 无效',
  4: 'RTC 初始化失败',
  5: 'RTC 加入频道失败',
  6: '取消参数错误',
  7: '呼叫发起失败',
  8: '当前账号已在其他端登录',
  9: 'RTC UID 为空',
  10: 'RTC 连接断开',
  19: '用户 RTC 连接断开',
  21: '接听失败',
};
const LOCAL_REJECT_NOTICE_TEXT = '你已经拒接';
const LOCAL_REJECT_MESSAGES = new Set(['local reject', 'local_reject']);

function sanitizeStoredForm(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }

  return Object.keys(value).reduce((result, key) => {
    if (!OMITTED_STORED_FORM_FIELDS.has(key)) {
      result[key] = value[key];
    }
    return result;
  }, {});
}

function readStoredString(value, fallback = '') {
  return typeof value === 'string' && value.trim() ? value : fallback;
}

function readStoredForm(storage, storageKey) {
  try {
    if (!storage || typeof storage.getItem !== 'function') {
      return {};
    }

    const raw = storage.getItem(storageKey);
    if (!raw) {
      return {};
    }

    const parsed = JSON.parse(raw);
    return sanitizeStoredForm(parsed);
  } catch (_error) {
    return {};
  }
}

function writeStoredForm(storage, storageKey, value) {
  if (!storage || typeof storage.setItem !== 'function') {
    return;
  }

  storage.setItem(storageKey, JSON.stringify(sanitizeStoredForm(value)));
}

function clearStoredForm(storage, storageKey) {
  if (!storage) {
    return;
  }

  try {
    if (typeof storage.removeItem === 'function') {
      storage.removeItem(storageKey);
      return;
    }
    if (typeof storage.setItem === 'function') {
      storage.setItem(storageKey, '');
    }
  } catch (_error) {}
}

function sanitizeStoredLoginForm(value) {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return {};
  }

  return Object.keys(value).reduce((result, key) => {
    if (!STORED_LOGIN_FORM_FIELDS.has(key)) {
      return result;
    }

    const nextValue = value[key];
    if (nextValue === undefined || nextValue === null) {
      return result;
    }

    const normalizedValue = typeof nextValue === 'string' ? nextValue.trim() : String(nextValue);
    if (normalizedValue) {
      result[key] = normalizedValue;
    }
    return result;
  }, {});
}

function hasStoredLoginCredentials(value) {
  const form = sanitizeStoredLoginForm(value);
  return !!(form.accountId && form.accountToken);
}

function readStoredLoginForm(storage, storageKey) {
  try {
    if (!storage || typeof storage.getItem !== 'function') {
      return {};
    }

    const raw = storage.getItem(storageKey);
    if (!raw) {
      return {};
    }

    return sanitizeStoredLoginForm(JSON.parse(raw));
  } catch (_error) {
    return {};
  }
}

function clearStoredLoginForm(storage, storageKey) {
  if (!storage) {
    return;
  }

  try {
    if (typeof storage.removeItem === 'function') {
      storage.removeItem(storageKey);
      return;
    }
    if (typeof storage.setItem === 'function') {
      storage.setItem(storageKey, '');
    }
  } catch (_error) {}
}

function writeStoredLoginForm(storage, storageKey, value) {
  if (!storage || typeof storage.setItem !== 'function') {
    return;
  }

  const sanitized = sanitizeStoredLoginForm(value);
  if (!hasStoredLoginCredentials(sanitized)) {
    clearStoredLoginForm(storage, storageKey);
    return;
  }

  try {
    storage.setItem(storageKey, JSON.stringify(sanitized));
  } catch (_error) {}
}

function resolveDebugEnabled(locationSearch, storage, storageKey) {
  try {
    const params = new URLSearchParams(locationSearch || '');

    if (params.get('debug') === '1') {
      return true;
    }

    if (params.get('debug') === '0') {
      return false;
    }
  } catch (_error) {}

  try {
    if (storage && typeof storage.getItem === 'function') {
      return storage.getItem(storageKey) === '1';
    }
  } catch (_error) {}

  return false;
}

function describeError(error) {
  return formatLoginErrorMessage(error, {
    includeErrorName: true,
  });
}

function stringifyPayload(value) {
  if (value == null) {
    return '';
  }

  if (typeof value === 'string') {
    return value;
  }

  try {
    return JSON.stringify(value, null, 2);
  } catch (_error) {
    return String(value);
  }
}

function createLogEntry(level, label, payload) {
  return {
    id: `${Date.now()}-${Math.random().toString(16).slice(2, 8)}`,
    level,
    label,
    payload: stringifyPayload(payload),
    timestamp: new Date().toLocaleTimeString(),
  };
}

function appendLogEntries(entries, level, label, payload, limit = DEFAULT_LOG_LIMIT) {
  const currentEntries = Array.isArray(entries) ? entries : [];
  return [createLogEntry(level, label, payload), ...currentEntries].slice(0, limit);
}

function toSerializableValue(value) {
  if (typeof value === 'bigint') {
    return String(value);
  }

  if (Array.isArray(value)) {
    return value.map((item) => toSerializableValue(item));
  }

  if (value && typeof value === 'object') {
    return Object.keys(value).reduce((result, key) => {
      result[key] = toSerializableValue(value[key]);
      return result;
    }, {});
  }

  return value;
}

function defaultNormalizeField(key, value, fallbackValue) {
  if (typeof fallbackValue === 'number') {
    return Number(value) === 1 ? 1 : Number(value) === 2 ? 2 : fallbackValue;
  }

  if (typeof fallbackValue === 'boolean') {
    return Boolean(value);
  }

  return readStoredString(value, fallbackValue);
}

function createSerializableForm(form, initialForm) {
  return Object.keys(initialForm).reduce((result, key) => {
    result[key] = form[key];
    return result;
  }, {});
}

function normalizeCallType(value) {
  return Number(value) === 1 ? 1 : 2;
}

function isInCallSnapshot(snapshot) {
  const value = snapshot && typeof snapshot === 'object' ? snapshot : {};
  const callInfo = value.callInfo && typeof value.callInfo === 'object' ? value.callInfo : {};
  return Number(value.callStatus) === 3 || Number(callInfo.callStatus) === 3;
}

function readNonEmptyString(value) {
  return typeof value === 'string' && value.trim() ? value.trim() : '';
}

function normalizeReasonCode(value) {
  if (value === undefined || value === null || value === '') {
    return '';
  }
  const numeric = Number(value);
  return Number.isFinite(numeric) ? String(numeric) : String(value);
}

function shouldSuppressCallEndToast(snapshot, reasonCode, reasonText = '') {
  if (reasonCode === '0') {
    return !readNonEmptyString(reasonText);
  }
  if (reasonCode === '15' || reasonCode === '16') {
    return true;
  }
  return reasonCode === '11' && snapshot.callRole === 'caller';
}

function isLocalRejectCallEnd(snapshot, lastEndInfo, reasonCode) {
  if (reasonCode !== '13' || snapshot.callRole !== 'callee') {
    return false;
  }

  return [
    lastEndInfo.message,
    lastEndInfo.reasonMessage,
    lastEndInfo.reasonDesc,
    lastEndInfo.extraString,
  ].some((item) => LOCAL_REJECT_MESSAGES.has(readNonEmptyString(item).toLowerCase()));
}

function resolveCallEndReasonText(snapshot, lastEndInfo) {
  const noticeText = readNonEmptyString(snapshot.noticeText);
  if (noticeText) {
    return noticeText;
  }

  const message =
    readNonEmptyString(lastEndInfo.message) ||
    readNonEmptyString(lastEndInfo.reasonMessage) ||
    readNonEmptyString(lastEndInfo.reasonDesc) ||
    readNonEmptyString(lastEndInfo.extraString);
  if (message) {
    return message;
  }

  const reasonCode = normalizeReasonCode(lastEndInfo.reasonCode);
  return CALL_END_REASON_FALLBACK_TEXT[reasonCode] || (reasonCode ? `错误码 ${reasonCode}` : '');
}

function resolveHomeActionToastNotice(snapshot) {
  const value = snapshot && typeof snapshot === 'object' ? snapshot : {};
  const text = typeof value.noticeText === 'string' ? value.noticeText.trim() : '';
  const lastEndInfo =
    value.lastEndInfo && typeof value.lastEndInfo === 'object' ? value.lastEndInfo : null;
  if (isInCallSnapshot(value) || (!text && !lastEndInfo)) {
    return null;
  }

  const kickedOfflineInfo =
    value.kickedOfflineInfo && typeof value.kickedOfflineInfo === 'object'
      ? value.kickedOfflineInfo
      : {};
  const reasonCode = normalizeReasonCode(lastEndInfo && lastEndInfo.reasonCode);
  const isLocalReject = !!(lastEndInfo && isLocalRejectCallEnd(value, lastEndInfo, reasonCode));
  const reasonText = isLocalReject
    ? LOCAL_REJECT_NOTICE_TEXT
    : lastEndInfo
      ? resolveCallEndReasonText(value, lastEndInfo)
      : '';
  if (
    !isLocalReject &&
    !text &&
    lastEndInfo &&
    shouldSuppressCallEndToast(value, reasonCode, reasonText)
  ) {
    return null;
  }

  const toastText = isLocalReject
    ? LOCAL_REJECT_NOTICE_TEXT
    : lastEndInfo
      ? reasonText
        ? `呼叫失败：${reasonText}`
        : ''
      : text;
  if (!toastText.trim()) {
    return null;
  }

  return {
    kind: lastEndInfo && !isLocalReject ? 'error' : 'notice',
    text: toastText,
    key: JSON.stringify({
      type: lastEndInfo ? 'callEnd' : 'notice',
      text: lastEndInfo ? '' : toastText,
      callStatus: Number(value.callStatus) || 0,
      reasonCode,
      message: (lastEndInfo && lastEndInfo.message) || '',
      extraString: (lastEndInfo && lastEndInfo.extraString) || '',
      kickedReason:
        kickedOfflineInfo.reason !== undefined && kickedOfflineInfo.reason !== null
          ? Number(kickedOfflineInfo.reason)
          : '',
      kickedDesc: kickedOfflineInfo.reasonDesc || '',
    }),
  };
}

function renderActionToastBubble(toast) {
  return toast && toast.text
    ? h(
        'div',
        {
          class: `call-action-toast call-action-toast-${toast.kind || 'error'}`,
          role: 'alert',
          'aria-live': 'assertive',
        },
        toast.text
      )
    : null;
}

const DemoShellView = defineComponent({
  name: 'ElectronExampleVue3RootView',
  props: {
    initialized: {
      type: Boolean,
      default: false,
    },
    form: {
      type: Object,
      default: () => ({}),
    },
    busy: {
      type: Boolean,
      default: false,
    },
    debugEnabled: {
      type: Boolean,
      default: false,
    },
    sdkVersion: {
      type: String,
      default: '',
    },
    runtimeDiagnostics: {
      type: Object,
      default: null,
    },
    bridgeDiagnostics: {
      type: Object,
      default: null,
    },
    callInfo: {
      type: Object,
      default: null,
    },
    inviteInfo: {
      type: Object,
      default: null,
    },
    lastEndInfo: {
      type: Object,
      default: null,
    },
    logs: {
      type: Array,
      default: () => [],
    },
    callRecords: {
      type: Array,
      default: () => [],
    },
    callActionToast: {
      type: Object,
      default: null,
    },
    showManagedToggle: {
      type: Boolean,
      default: true,
    },
  },
  emits: [
    'update:loginMode',
    'update:accountId',
    'update:accountToken',
    'update:invitee',
    'update:callType',
    'update:callTimeoutSeconds',
    'update:enableOffline',
    'update:enableSwitchVideoConfirm',
    'update:enableSwitchAudioConfirm',
    'submit-login',
    'submit-call',
    'accept',
    'hangup',
    'destroy',
    'logout',
  ],
  setup(props, { emit }) {
    return () =>
      h('div', { class: 'example-root' }, [
        props.initialized
          ? h(HomeView, {
              accountId: props.form.accountId || '',
              invitee: props.form.invitee || '',
              callType: normalizeCallType(props.form.callType),
              callTimeoutSeconds: props.form.callTimeoutSeconds ?? '30',
              enableOffline: props.form.enableOffline !== false,
              enableSwitchVideoConfirm: !!props.form.enableSwitchVideoConfirm,
              enableSwitchAudioConfirm: !!props.form.enableSwitchAudioConfirm,
              callRecords: props.callRecords,
              busy: props.busy,
              'onUpdate:invitee': (value) => emit('update:invitee', value),
              'onUpdate:callType': (value) => emit('update:callType', value),
              'onUpdate:callTimeoutSeconds': (value) =>
                emit('update:callTimeoutSeconds', value),
              'onUpdate:enableOffline': (value) => emit('update:enableOffline', value),
              'onUpdate:enableSwitchVideoConfirm': (value) =>
                emit('update:enableSwitchVideoConfirm', value),
              'onUpdate:enableSwitchAudioConfirm': (value) =>
                emit('update:enableSwitchAudioConfirm', value),
              onSubmitCall: () => emit('submit-call'),
              onLogout: () => emit('logout'),
            })
          : h(LoginView, {
              loginMode: props.form.loginMode || 'external',
              accountId: props.form.accountId || '',
              accountToken: props.form.accountToken || '',
              loading: props.busy,
              showManagedToggle: props.showManagedToggle,
              'onUpdate:loginMode': (value) => emit('update:loginMode', value),
              'onUpdate:accountId': (value) => emit('update:accountId', value),
              'onUpdate:accountToken': (value) => emit('update:accountToken', value),
              onSubmit: () => emit('submit-login'),
            }),
        renderActionToastBubble(props.callActionToast),
        props.debugEnabled
          ? h(DebugPanel, {
              sdkVersion: props.sdkVersion,
              runtimeDiagnostics: props.runtimeDiagnostics,
              bridgeDiagnostics: props.bridgeDiagnostics,
              callInfo: props.callInfo,
              inviteInfo: props.inviteInfo,
              lastEndInfo: props.lastEndInfo,
              logs: props.logs,
              busy: props.busy,
              initialized: props.initialized,
              onAccept: () => emit('accept'),
              onHangup: () => emit('hangup'),
              onDestroy: () => emit('destroy'),
            })
          : null,
      ]);
  },
});

function createDemoShellApp(options = {}) {
  return defineComponent(
    Object.assign(
      {
        name: options.name || 'ElectronExampleVue3DemoShell',
      },
      options
    )
  );
}

function useDemoShellState(options = {}) {
  const storage = options.storage || null;
  const storageKey = options.storageKey || 'necallkit.example-vue3.form';
  const debugStorageKey = options.debugStorageKey || 'necallkit.example-vue3.debug';
  const rememberedLoginStorageKey =
    options.rememberedLoginStorageKey || `${storageKey}.remembered-login`;
  const callRecordStorageKey =
    options.callRecordStorageKey || `${storageKey}.default-call-records`;
  const locationSearch = options.locationSearch || '';
  const actionToastDurationMs =
    Number(options.actionToastDurationMs) > 0
      ? Number(options.actionToastDurationMs)
      : DEFAULT_ACTION_TOAST_DURATION_MS;
  const initialForm =
    options.initialForm && typeof options.initialForm === 'object'
      ? Object.assign({}, options.initialForm)
      : {};
  const normalizeField =
    typeof options.normalizeField === 'function'
      ? options.normalizeField
      : defaultNormalizeField;
  const rememberedLoginForm = readStoredLoginForm(storage, rememberedLoginStorageKey);
  const stored = Object.assign(
    {},
    initialForm,
    readStoredForm(storage, storageKey),
    rememberedLoginForm
  );
  const autoLoginOnStart =
    options.autoLogin !== false &&
    !options.initialInitialized &&
    hasStoredLoginCredentials(rememberedLoginForm);
  const persistFormKeys = new Set(
    Array.isArray(options.persistFormKeys) ? options.persistFormKeys : []
  );
  const form = reactive(
    Object.keys(initialForm).reduce((result, key) => {
      const fallbackValue = initialForm[key];
      const nextValue = Object.prototype.hasOwnProperty.call(stored, key)
        ? stored[key]
        : fallbackValue;
      result[key] = normalizeField(key, nextValue, fallbackValue, stored);
      return result;
    }, {})
  );
  const initialized = ref(Boolean(options.initialInitialized));
  const busy = ref(false);
  const logs = ref([]);
  const callRecords = ref(
    readStoredCallRecords(
      storage,
      createCallRecordCacheKey(callRecordStorageKey, form.accountId),
      {
        limit: CALL_RECORD_LIMIT,
      }
    )
  );
  const callRecordAdapterState = ref({
    started: false,
    ready: false,
    error: '',
    historyError: '',
    lastMessageId: '',
    recordCount: 0,
    sourceCounts: {},
  });
  const sdkVersion = ref(options.initialSdkVersion || '');
  const runtimeState = ref(
    options.initialRuntimeState && typeof options.initialRuntimeState === 'object'
      ? Object.assign({}, options.initialRuntimeState)
      : {}
  );
  const runtimeDiagnostics = ref(
    options.initialRuntimeDiagnostics || runtimeState.value.diagnostics
  );
  const bridgeDiagnostics = ref(options.initialBridgeDiagnostics || null);
  const debugEnabled = ref(
    options.debugEnabled !== undefined
      ? !!options.debugEnabled
      : resolveDebugEnabled(locationSearch, storage, debugStorageKey)
  );
  const actionToast = ref(null);
  let actionToastTimer = null;
  const callInfo = computed(() => runtimeState.value.callInfo || {});
  const inviteInfo = computed(() => runtimeState.value.inviteInfo || {});
  const lastEndInfo = computed(() => runtimeState.value.lastEndInfo || {});

  function serializeForm() {
    return createSerializableForm(form, initialForm);
  }

  function persistForm() {
    writeStoredForm(storage, storageKey, serializeForm());
  }

  function persistRememberedLogin() {
    writeStoredLoginForm(storage, rememberedLoginStorageKey, serializeForm());
  }

  function clearRememberedLogin() {
    clearStoredLoginForm(storage, rememberedLoginStorageKey);
  }

  function clearCachedForm() {
    clearStoredForm(storage, storageKey);
    Object.keys(initialForm).forEach((key) => {
      form[key] = normalizeField(key, initialForm[key], initialForm[key], initialForm);
    });
  }

  function shouldPersistPatch(keys) {
    return keys.some((key) => persistFormKeys.has(key));
  }

  function patchForm(patch) {
    const nextPatch = patch && typeof patch === 'object' ? patch : {};
    const patchKeys = Object.keys(nextPatch);

    patchKeys.forEach((key) => {
      if (!Object.prototype.hasOwnProperty.call(form, key)) {
        return;
      }

      form[key] = normalizeField(key, nextPatch[key], initialForm[key], form);
    });

    if (shouldPersistPatch(patchKeys)) {
      persistForm();
    }
  }

  function appendLog(level, label, payload) {
    logs.value = appendLogEntries(logs.value, level, label, payload, options.logLimit);
  }

  function setCallRecords(nextRecords) {
    callRecords.value = normalizeDefaultCallRecords(nextRecords, {
      limit: CALL_RECORD_LIMIT,
    });
    writeStoredCallRecords(
      storage,
      createCallRecordCacheKey(callRecordStorageKey, form.accountId),
      callRecords.value,
      {
        limit: CALL_RECORD_LIMIT,
      }
    );
  }

  function setCallRecordAdapterState(nextState) {
    callRecordAdapterState.value =
      nextState && typeof nextState === 'object' ? Object.assign({}, nextState) : {};
  }

  function loadCachedCallRecords(accountId) {
    setCallRecords(
      readStoredCallRecords(
        storage,
        createCallRecordCacheKey(callRecordStorageKey, accountId),
        {
          limit: CALL_RECORD_LIMIT,
        }
      )
    );
  }

  function clearCallRecordsView() {
    callRecords.value = [];
  }

  function setRuntimeState(nextState) {
    runtimeState.value =
      nextState && typeof nextState === 'object' ? Object.assign({}, nextState) : {};

    if (Object.prototype.hasOwnProperty.call(runtimeState.value, 'diagnostics')) {
      runtimeDiagnostics.value = runtimeState.value.diagnostics;
    }
  }

  function setRuntimeDiagnostics(value) {
    runtimeDiagnostics.value = value;
  }

  function setBridgeDiagnostics(value) {
    bridgeDiagnostics.value = value || null;
  }

  function setSdkVersion(value) {
    sdkVersion.value = value || '';
  }

  function setBusy(value) {
    busy.value = !!value;
  }

  function setInitialized(value) {
    initialized.value = !!value;
  }

  function hideActionToast() {
    if (actionToastTimer) {
      clearTimeout(actionToastTimer);
      actionToastTimer = null;
    }
    actionToast.value = null;
  }

  function showActionToast(text, kind = 'error') {
    const nextText = typeof text === 'string' ? text.trim() : '';
    if (!nextText) {
      return;
    }

    if (actionToastTimer) {
      clearTimeout(actionToastTimer);
    }

    actionToast.value = {
      kind,
      text: nextText,
    };
    actionToastTimer = setTimeout(() => {
      actionToast.value = null;
      actionToastTimer = null;
    }, actionToastDurationMs);
  }

  return {
    bridgeDiagnostics,
    busy,
    callInfo,
    callRecords,
    callRecordAdapterState,
    actionToast,
    debugEnabled,
    form,
    initialized,
    inviteInfo,
    lastEndInfo,
    logs,
    patchForm,
    persistForm,
    persistRememberedLogin,
    clearRememberedLogin,
    clearCachedForm,
    autoLoginOnStart,
    runtimeDiagnostics,
    runtimeState,
    sdkVersion,
    appendLog,
    loadCachedCallRecords,
    setCallRecordAdapterState,
    setCallRecords,
    clearCallRecordsView,
    setBridgeDiagnostics,
    setBusy,
    setInitialized,
    setRuntimeDiagnostics,
    setRuntimeState,
    setSdkVersion,
    hideActionToast,
    showActionToast,
  };
}

module.exports = {
  DEFAULT_LOG_LIMIT,
  DebugPanel,
  DemoShellView,
  HomeView,
  LoginView,
  appendLogEntries,
  createDemoShellApp,
  createLogEntry,
  describeError,
  clearStoredForm,
  clearStoredLoginForm,
  hasStoredLoginCredentials,
  readStoredForm,
  readStoredLoginForm,
  readStoredString,
  resolveDebugEnabled,
  sanitizeStoredForm,
  sanitizeStoredLoginForm,
  stringifyPayload,
  toSerializableValue,
  useDemoShellState,
  writeStoredForm,
  writeStoredLoginForm,
  isInCallSnapshot,
  renderActionToastBubble,
  resolveHomeActionToastNotice,
};
