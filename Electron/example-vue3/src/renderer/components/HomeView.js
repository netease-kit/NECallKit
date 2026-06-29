'use strict';

const { defineComponent, h, ref } = require('vue');
const { SettingsPanelView } = require('./SettingsPanelView');

function createRadioOption(currentValue, nextValue, label, emit) {
  return h('label', { class: 'call-radio-label' }, [
    h('input', {
      type: 'radio',
      checked: currentValue === nextValue,
      onChange: () => emit('update:callType', nextValue),
    }),
    h('span', label),
  ]);
}

function renderSingleCallSection(props, emit, updateInvitee, submitCall) {
  return [
    h('div', { class: 'call-section-title' }, '一对一通话'),
    h('div', { class: 'search' }, [
      h('div', { class: 'call-input-box' }, [
        h('input', {
          class: 'input-search-user',
          type: 'text',
          maxlength: 50,
          placeholder: '请输入账号ID',
          value: props.invitee,
          onInput: updateInvitee,
        }),
      ]),
      h(
        'button',
        {
          class: 'btn-search',
          type: 'button',
          disabled: props.busy,
          onClick: submitCall,
        },
        '呼叫'
      ),
    ]),
    h('div', { class: 'call-radio-row' }, [
      h('div', null, '呼叫类型'),
      h('div', { class: 'call-radio-group' }, [
        createRadioOption(props.callType, 2, '视频呼叫', emit),
        createRadioOption(props.callType, 1, '音频呼叫', emit),
      ]),
    ]),
  ];
}

function formatRecordType(callType) {
  return Number(callType) === 1 ? '音频' : Number(callType) === 2 ? '视频' : '-';
}

function formatRecordState(callState) {
  const stateMap = {
    1: '完成',
    2: '取消',
    3: '拒绝',
    4: '超时',
    5: '忙线',
  };
  return stateMap[Number(callState)] || '-';
}

function formatRecordDirection(direction) {
  return direction === 'outgoing' ? '呼出' : direction === 'incoming' ? '呼入' : '-';
}

function getRecordPeer(record) {
  return (record && (record.peerAccountId || record.accId)) || '-';
}

function formatRecordSource(source) {
  const sourceMap = {
    'im-call-message': 'IM 同步',
    'im-history': 'IM 历史',
    'im-send': '本端发送',
  };
  return sourceMap[source] || 'IM 同步';
}

function resolveRecordSource(record) {
  if (record && record.source) {
    return record.source;
  }
  return 'im-call-message';
}

function isDefaultImRecord(record) {
  const source = resolveRecordSource(record);
  return source === 'im-call-message' || source === 'im-history' || source === 'im-send';
}

function formatRecordTime(value) {
  if (!value || value === '0') {
    return '-';
  }
  const timestamp = Number(value);
  if (!Number.isFinite(timestamp) || timestamp <= 0) {
    return String(value);
  }
  return new Date(timestamp).toLocaleTimeString();
}

function formatRecordStatus(record) {
  if (record && record.note) {
    return record.note;
  }
  const statusMap = {
    synced: '已同步',
    history: '历史同步',
    sent: '本端已发送',
    modified: '已更新',
  };
  return statusMap[record && record.dispatchStatus] || (record && record.dispatchStatus) || '已同步';
}

function formatRecordTitle(record) {
  return [
    `来源: ${formatRecordSource(resolveRecordSource(record))}`,
    `对象: ${getRecordPeer(record)}`,
    `方向: ${formatRecordDirection(record && record.direction)}`,
    `类型: ${formatRecordType(record.callType)}`,
    `状态: ${formatRecordState(record.callState)}`,
    `Call ID: ${record.callId || '-'}`,
    `Client ID: ${record.messageClientId || '-'}`,
    `Server ID: ${record.messageServerId || '-'}`,
    `时间: ${formatRecordTime(record.timestampMs)}`,
    formatRecordStatus(record),
  ].join(' | ');
}

function renderCallRecordSection(props) {
  const records = (Array.isArray(props.callRecords) ? props.callRecords : []).filter(
    isDefaultImRecord
  );
  return h('section', { class: 'call-record-section' }, [
    h('div', { class: 'call-record-header' }, [
      h(
        'div',
        { class: 'call-section-title' },
        '默认 IM 话单'
      ),
    ]),
    h(
      'div',
      { class: 'call-record-list' },
      records.length === 0
        ? [
            h(
              'div',
              { class: 'call-record-empty' },
              '暂无默认 IM 话单。结束通话后等待 IM call message，同账号多端同步记录也会出现在这里。'
            ),
          ]
        : records.map((record) =>
            h('div', {
              key: record.id,
              class: 'call-record-row',
              title: formatRecordTitle(record),
            }, [
              h('span', { class: 'call-record-time' }, formatRecordTime(record.timestampMs)),
              h('strong', { class: 'call-record-peer' }, getRecordPeer(record)),
              h('span', { class: 'call-record-direction' }, formatRecordDirection(record.direction)),
              h(
                'span',
                { class: 'call-record-meta' },
                `${formatRecordType(record.callType)}/${formatRecordState(record.callState)}`
              ),
              h(
                'span',
                {
                  class: `call-record-source call-record-source-${resolveRecordSource(record)}`,
                },
                formatRecordSource(resolveRecordSource(record))
              ),
              h('span', { class: 'call-record-status' }, formatRecordStatus(record)),
            ])
          )
    ),
  ]);
}

const HomeView = defineComponent({
  name: 'ElectronExampleVue3HomeView',
  props: {
    accountId: {
      type: String,
      default: '',
    },
    invitee: {
      type: String,
      default: '',
    },
    callType: {
      type: Number,
      default: 1,
    },
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
    callRecords: {
      type: Array,
      default: () => [],
    },
    busy: {
      type: Boolean,
      default: false,
    },
  },
  emits: [
    'update:invitee',
    'update:callType',
    'update:callTimeoutSeconds',
    'update:enableOffline',
    'update:enableSwitchVideoConfirm',
    'update:enableSwitchAudioConfirm',
    'submit-call',
    'logout',
  ],
  setup(props, { emit }) {
    const settingsVisible = ref(false);

    function updateInvitee(event) {
      emit('update:invitee', event && event.target ? event.target.value : '');
    }

    function submitCall() {
      emit('submit-call');
    }

    function openSettings() {
      settingsVisible.value = true;
    }

    function closeSettings() {
      settingsVisible.value = false;
    }

    function logout() {
      emit('logout');
    }

    return () =>
      h('div', { class: 'home-screen' }, [
        h('section', { class: 'home-card' }, [
          h('div', { class: 'home-id-row' }, [
            h('div', { class: 'home-id-copy' }, [
              h('label', null, '您的ID'),
              h('div', { class: 'home-id-value' }, props.accountId),
            ]),
            h('div', { class: 'home-actions' }, [
              h(
                'button',
                {
                  class: 'home-settings-button',
                  type: 'button',
                  onClick: openSettings,
                },
                '设置'
              ),
              h(
                'button',
                {
                  class: 'home-logout-button',
                  type: 'button',
                  disabled: props.busy,
                  onClick: logout,
                },
                '退出登录'
              ),
            ]),
          ]),
          ...renderSingleCallSection(props, emit, updateInvitee, submitCall),
          renderCallRecordSection(props),
          h('div', { class: 'call-divider' }),
          h('div', { class: 'call-section-title' }, '群组通话'),
          h('div', { class: 'search' }, [
            h('div', { class: 'call-input-box disabled' }, [
              h(
                'div',
                { class: 'input-search-user input-placeholder-disabled' },
                '多个账号用英文逗号分隔'
              ),
            ]),
            h(
              'button',
              {
                class: 'btn-search disabled',
                type: 'button',
                disabled: true,
              },
              '发起群呼'
            ),
          ]),
          h('div', { class: 'group-disabled-note' }, '本期不支持群呼'),
        ]),
        settingsVisible.value
          ? h(SettingsPanelView, {
              callTimeoutSeconds: props.callTimeoutSeconds,
              enableOffline: props.enableOffline,
              enableSwitchVideoConfirm: props.enableSwitchVideoConfirm,
              enableSwitchAudioConfirm: props.enableSwitchAudioConfirm,
              onClose: closeSettings,
              'onUpdate:callTimeoutSeconds': (value) =>
                emit('update:callTimeoutSeconds', value),
              'onUpdate:enableOffline': (value) => emit('update:enableOffline', value),
              'onUpdate:enableSwitchVideoConfirm': (value) =>
                emit('update:enableSwitchVideoConfirm', value),
              'onUpdate:enableSwitchAudioConfirm': (value) =>
                emit('update:enableSwitchAudioConfirm', value),
            })
          : null,
      ]);
  },
});

module.exports = {
  HomeView,
};
