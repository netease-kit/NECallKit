'use strict';

const { defineComponent, h } = require('vue');

function stringifyPayload(value) {
  if (value == null) {
    return '—';
  }
  if (typeof value === 'string') {
    return value || '—';
  }
  try {
    return JSON.stringify(value, null, 2);
  } catch (_error) {
    return String(value);
  }
}

function createInfoBlock(title, value) {
  return h('div', { class: 'debug-info-block' }, [
    h('div', { class: 'debug-info-title' }, title),
    h('pre', { class: 'debug-code' }, stringifyPayload(value)),
  ]);
}

function createActionButton(label, onClick, options = {}) {
  return h(
    'button',
    {
      class: [
        'debug-action-button',
        options.tone === 'secondary' ? 'secondary' : '',
        options.tone === 'danger' ? 'danger' : '',
      ]
        .filter(Boolean)
        .join(' '),
      type: 'button',
      disabled: !!options.disabled,
      onClick,
    },
    label
  );
}

const DebugPanel = defineComponent({
  name: 'ElectronExampleVue3DebugPanel',
  props: {
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
    busy: {
      type: Boolean,
      default: false,
    },
    initialized: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['accept', 'hangup', 'destroy'],
  setup(props, { emit }) {
    return () =>
      h('section', { class: 'debug-panel' }, [
        h('div', { class: 'debug-panel-title' }, '运行态诊断'),
        h('div', { class: 'debug-panel-subtitle' }, '默认对外体验不展示该区域；通过 ?debug=1 打开。'),
        h('div', { class: 'debug-actions' }, [
          createActionButton('接听', () => emit('accept'), {
            disabled: props.busy || !props.initialized,
          }),
          createActionButton('挂断 / 拒接', () => emit('hangup'), {
            disabled: props.busy || !props.initialized,
            tone: 'danger',
          }),
          createActionButton('销毁实例', () => emit('destroy'), {
            disabled: props.busy || !props.initialized,
            tone: 'secondary',
          }),
        ]),
        h('div', { class: 'debug-diag-list' }, [
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Ownership'),
            h(
              'code',
              stringifyPayload(props.runtimeDiagnostics && props.runtimeDiagnostics.mode)
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Ready State'),
            h(
              'code',
              stringifyPayload(props.runtimeDiagnostics && props.runtimeDiagnostics.readyState)
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Reason'),
            h(
              'code',
              stringifyPayload(props.runtimeDiagnostics && props.runtimeDiagnostics.reason)
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'SDK Version'),
            h('code', stringifyPayload(props.sdkVersion)),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Bridge Path'),
            h(
              'code',
              stringifyPayload(
                props.bridgeDiagnostics && props.bridgeDiagnostics.resolvedLibraryPath
              )
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Configured NIM'),
            h(
              'code',
              stringifyPayload(
                props.runtimeDiagnostics && props.runtimeDiagnostics.configuredNimRuntimePath
              )
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Resolved NIM'),
            h(
              'code',
              stringifyPayload(
                props.runtimeDiagnostics && props.runtimeDiagnostics.resolvedNimRuntimePath
              )
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Loaded NIM'),
            h(
              'code',
              stringifyPayload(
                props.runtimeDiagnostics && props.runtimeDiagnostics.loadedNimRuntimePath
              )
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'ABI Version'),
            h(
              'code',
              stringifyPayload(props.bridgeDiagnostics && props.bridgeDiagnostics.abiVersion)
            ),
          ]),
          h('div', { class: 'debug-diag-item' }, [
            h('span', { class: 'debug-diag-label' }, 'Capabilities'),
            h(
              'code',
              stringifyPayload(props.bridgeDiagnostics && props.bridgeDiagnostics.capabilities)
            ),
          ]),
        ]),
        createInfoBlock('Call Info', props.callInfo),
        createInfoBlock('Invite Info', props.inviteInfo),
        createInfoBlock('Last End Info', props.lastEndInfo),
        h(
          'div',
          { class: 'debug-log-list' },
          props.logs.length > 0
            ? props.logs.map((entry) =>
                h('div', { key: entry.id, class: 'debug-log-entry' }, [
                  h('div', { class: 'debug-log-head' }, [
                    h('span', { class: `debug-log-level ${entry.level}` }, entry.level),
                    h('span', { class: 'debug-log-label' }, entry.label),
                    h('span', { class: 'debug-log-time' }, entry.timestamp),
                  ]),
                  h('pre', { class: 'debug-code debug-log-body' }, entry.payload || '—'),
                ])
              )
            : [h('div', { class: 'debug-empty' }, '暂无日志')]
        ),
      ]);
  },
});

module.exports = {
  DebugPanel,
};
