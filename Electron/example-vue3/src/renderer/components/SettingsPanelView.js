'use strict';

const { defineComponent, h } = require('vue');

function createCheckboxOption(key, checked, label, emit) {
  return h('label', { key, class: 'call-radio-label' }, [
    h('input', {
      type: 'checkbox',
      checked: !!checked,
      onChange: (event) =>
        emit(`update:${key}`, Boolean(event && event.target && event.target.checked)),
    }),
    h('span', label),
  ]);
}

function renderTimeoutSection(props, emit) {
  return [
    h('div', { class: 'call-section-title' }, '超时设置'),
    h('div', { class: 'call-radio-row' }, [
      h('div', null, 'setTimeout'),
      h('div', { class: 'call-radio-group' }, [
        h('input', {
          class: 'input-search-user',
          type: 'text',
          inputmode: 'numeric',
          maxlength: 3,
          placeholder: '30',
          value: props.callTimeoutSeconds,
          onInput: (event) =>
            emit('update:callTimeoutSeconds', event && event.target ? event.target.value : ''),
        }),
        h('span', '秒，超时后自动结束呼叫'),
      ]),
    ]),
  ];
}

function renderCallConfigSection(props, emit) {
  return [
    h('div', { class: 'call-section-title' }, '通话配置'),
    h('div', { class: 'call-radio-row' }, [
      h('div', null, 'setCallConfig'),
      h('div', { class: 'call-radio-group settings-checkbox-group' }, [
        createCheckboxOption(
          'enableOffline',
          props.enableOffline,
          '信令消息支持离线',
          emit
        ),
        createCheckboxOption(
          'enableSwitchVideoConfirm',
          props.enableSwitchVideoConfirm,
          '收到音频转视频请求时需本端确认',
          emit
        ),
        createCheckboxOption(
          'enableSwitchAudioConfirm',
          props.enableSwitchAudioConfirm,
          '收到视频转音频请求时需本端确认',
          emit
        ),
      ]),
    ]),
  ];
}

const SettingsPanelView = defineComponent({
  name: 'ElectronExampleVue3SettingsPanelView',
  props: {
    callTimeoutSeconds: {
      type: String,
      default: '30',
    },
    enableOffline: {
      type: Boolean,
      default: true,
    },
    enableSwitchVideoConfirm: {
      type: Boolean,
      default: false,
    },
    enableSwitchAudioConfirm: {
      type: Boolean,
      default: false,
    },
  },
  emits: [
    'close',
    'update:callTimeoutSeconds',
    'update:enableOffline',
    'update:enableSwitchVideoConfirm',
    'update:enableSwitchAudioConfirm',
  ],
  setup(props, { emit }) {
    function closeSettings() {
      emit('close');
    }

    return () =>
      h(
        'div',
        {
          class: 'settings-overlay',
          onClick: closeSettings,
        },
        [
          h(
            'section',
            {
              class: 'settings-panel',
              onClick: (event) => {
                if (event && typeof event.stopPropagation === 'function') {
                  event.stopPropagation();
                }
              },
            },
            [
              h('div', { class: 'settings-panel-header' }, [
                h('div', { class: 'settings-panel-title' }, '设置'),
                h(
                  'button',
                  {
                    class: 'settings-close-button',
                    type: 'button',
                    onClick: closeSettings,
                  },
                  '完成'
                ),
              ]),
              h('div', { class: 'settings-panel-body' }, [
                ...renderTimeoutSection(props, emit),
                h('div', { class: 'call-divider settings-divider' }),
                ...renderCallConfigSection(props, emit),
              ]),
            ]
          ),
        ]
      );
  },
});

module.exports = {
  SettingsPanelView,
};
