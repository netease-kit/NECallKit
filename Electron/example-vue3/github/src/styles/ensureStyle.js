'use strict';

const { CALL_VIEW_STYLE_TEXT } = require('./call-view-style-text');

const STYLE_ID = 'necallkit-electron-vue3-uikit-call-view-style';

function ensureCallViewStyles() {
  if (typeof document === 'undefined') {
    return;
  }

  const existingStyle = document.getElementById(STYLE_ID);

  if (existingStyle) {
    if (existingStyle.textContent !== CALL_VIEW_STYLE_TEXT) {
      existingStyle.textContent = CALL_VIEW_STYLE_TEXT;
    }
    return;
  }

  const style = document.createElement('style');
  style.id = STYLE_ID;
  style.textContent = CALL_VIEW_STYLE_TEXT;

  const target = document.head || document.documentElement;
  if (target) {
    target.appendChild(style);
  }
}

module.exports = {
  ensureCallViewStyles,
};
