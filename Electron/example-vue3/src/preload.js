'use strict';

const { ipcRenderer } = require('electron');
const { installPreloadBridge } = require('./preload-host');

function formatErrorPayload(error) {
  if (!error || typeof error !== 'object') {
    return error == null ? '' : String(error);
  }
  return {
    name: error.name || 'Error',
    message: error.message || String(error),
    code: error.code,
    stack: error.stack,
  };
}

window.addEventListener('error', (event) => {
  console.error('[example-vue3] window.error', {
    message: event.message,
    filename: event.filename,
    lineno: event.lineno,
    colno: event.colno,
    error: formatErrorPayload(event.error),
  });
});

window.addEventListener('unhandledrejection', (event) => {
  console.error('[example-vue3] window.unhandledrejection', {
    reason: formatErrorPayload(event.reason),
  });
});

installPreloadBridge({
  windowTarget: window,
  env: process.env,
  framework: 'vue3',
  ipcRenderer,
});
