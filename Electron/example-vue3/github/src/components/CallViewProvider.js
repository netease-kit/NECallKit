'use strict';

const { defineComponent, h } = require('vue');
const vueCore = require('@xkit-yx/callkit-vue3-core');
const { resolveControlAsset } = require('./control-assets');
const {
  assertRuntimeInjectedForMainSideOwner,
} = require('../main-side-native-owner-gate');

function createDefaultRuntime(options) {
  return require('../runtime').createCallkitRuntime(options);
}

const CallViewProvider = defineComponent({
  name: 'ElectronCallViewProvider',
  props: {
    runtime: {
      type: Object,
      default: null,
    },
    sdk: {
      type: Object,
      default: null,
    },
    switchCallTypeConfig: {
      type: Object,
      default: null,
    },
    suppressIdleNotice: {
      type: Boolean,
      default: false,
    },
    uiConfig: {
      type: Object,
      default: null,
    },
    position: {
      type: Object,
      default: null,
    },
  },
  setup(props, { attrs, expose, slots }) {
    assertRuntimeInjectedForMainSideOwner(props.runtime);
    const runtime =
      props.runtime || createDefaultRuntime({ sdk: props.sdk || undefined });
    const switchCallTypeConfig =
      props.switchCallTypeConfig ||
      (props.uiConfig && props.uiConfig.switchCallTypeBtn) ||
      undefined;

    expose(runtime);

    return () =>
      h(
        vueCore.CallViewProvider,
        Object.assign({}, attrs, {
          runtime,
          resolveControlAsset,
          switchCallTypeConfig,
          suppressIdleNotice: props.suppressIdleNotice,
        }),
        slots
      );
  },
});

module.exports = {
  CallViewProvider,
};
