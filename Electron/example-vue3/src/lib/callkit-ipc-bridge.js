'use strict';

const {
  EVENT_CHANNEL,
  INVOKE_CHANNEL,
} = require('./callkit-main-service');

function createCallkitIpcBridge(ipcRenderer, options = {}) {
  const invokeChannel = options.invokeChannel || INVOKE_CHANNEL;
  const eventChannel = options.eventChannel || EVENT_CHANNEL;

  return {
    invoke(method, payload) {
      if (!ipcRenderer || typeof ipcRenderer.invoke !== 'function') {
        return Promise.reject(new Error('CallKit ipcRenderer.invoke is unavailable'));
      }
      return ipcRenderer.invoke(invokeChannel, {
        method,
        payload,
      });
    },
    on(listener) {
      if (
        !ipcRenderer ||
        typeof listener !== 'function' ||
        typeof ipcRenderer.on !== 'function'
      ) {
        return () => {};
      }
      const handler = (_event, payload) => {
        listener(payload);
      };
      ipcRenderer.on(eventChannel, handler);
      return () => {
        if (typeof ipcRenderer.off === 'function') {
          ipcRenderer.off(eventChannel, handler);
        } else if (typeof ipcRenderer.removeListener === 'function') {
          ipcRenderer.removeListener(eventChannel, handler);
        }
      };
    },
  };
}

module.exports = {
  createCallkitIpcBridge,
};
