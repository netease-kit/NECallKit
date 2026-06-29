'use strict';

const { defineComponent, h } = require('vue');

const DEFAULT_LOGIN_HELP_HREF =
  'https://doc.yunxin.163.com/messaging2/guide/jU0Mzg0MTU?platform=client#%E7%AC%AC%E4%BA%8C%E6%AD%A5%E6%B3%A8%E5%86%8C-im-%E8%B4%A6%E5%8F%B7';

const LoginView = defineComponent({
  name: 'ElectronExampleVue3LoginView',
  props: {
    loginMode: {
      type: String,
      default: 'external',
    },
    accountId: {
      type: String,
      default: '',
    },
    accountToken: {
      type: String,
      default: '',
    },
    loading: {
      type: Boolean,
      default: false,
    },
    showManagedToggle: {
      type: Boolean,
      default: true,
    },
    helpHref: {
      type: String,
      default: DEFAULT_LOGIN_HELP_HREF,
    },
  },
  emits: ['update:loginMode', 'update:accountId', 'update:accountToken', 'submit'],
  setup(props, { emit }) {
    function isManagedMode() {
      return props.loginMode === 'managed';
    }

    function updateManagedMode(event) {
      const checked = Boolean(event && event.target && event.target.checked);
      emit('update:loginMode', checked ? 'managed' : 'external');
    }

    function updateAccountId(event) {
      emit('update:accountId', event && event.target ? event.target.value : '');
    }

    function updateAccountToken(event) {
      emit('update:accountToken', event && event.target ? event.target.value : '');
    }

    function submit() {
      emit('submit');
    }

    return () =>
      h('div', { class: 'login-screen' }, [
        h('div', { class: 'login-hero' }),
        h('div', { class: 'login-content' }, [
          h('div', { class: 'brand-mark' }, '网易云信 | 实时音视频'),
          h('section', { class: 'login-panel' }, [
            h('label', { class: 'login-row' }, [
              h('span', { class: 'login-label' }, '账号ID'),
              h('input', {
                class: 'login-input',
                type: 'text',
                value: props.accountId,
                maxlength: 50,
                placeholder: '请输入账号ID',
                onInput: updateAccountId,
              }),
            ]),
            h('label', { class: 'login-row login-row-spaced' }, [
              h('span', { class: 'login-label' }, 'Token'),
              h('input', {
                class: 'login-input',
                type: 'text',
                value: props.accountToken,
                maxlength: 50,
                placeholder: '请输入Token',
                onInput: updateAccountToken,
              }),
            ]),
            h(
              'button',
              {
                class: 'login-submit',
                type: 'button',
                disabled: props.loading,
                onClick: submit,
              },
              props.loading ? '登录中...' : '登录'
            ),
            props.helpHref
              ? h(
                  'a',
                  {
                    class: 'login-help',
                    href: props.helpHref,
                    target: '_blank',
                    rel: 'noopener noreferrer',
                  },
                  '如何获取云信账号与Token'
                )
              : null,
          ]),
        ]),
      ]);
  },
});

module.exports = {
  DEFAULT_LOGIN_HELP_HREF,
  LoginView,
};
