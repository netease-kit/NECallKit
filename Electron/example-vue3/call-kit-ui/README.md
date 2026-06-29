# Electron Vue 3 UIKit

`@xkit-yx/electron-callkit-vue3-uikit` provides the Vue 3 UI layer for 1v1 audio/video calls in Electron.

This directory contains the UIKit source used by `../` Vue 3 demo. It does not contain the CallKit logic layer or native addon source; those are resolved through npm dependencies declared in `package.json`.

## Install

In a consumer project:

```bash
npm install @xkit-yx/electron-callkit-vue3-uikit vue
```

In this sample repo, `Electron/example-vue3/package.json` follows the published package version from the source example. For local source debugging, temporarily install this directory through a local path or local tarball.

## Minimal Usage

```js
const { h } = require('vue');
const {
  CallViewProvider,
  createCallkitRuntime,
} = require('@xkit-yx/electron-callkit-vue3-uikit');

const runtime = createCallkitRuntime();

module.exports = {
  setup() {
    return () => h(CallViewProvider, { runtime }, () => h('div', 'your app'));
  },
};
```

Before creating the runtime, the Electron main/preload side still needs to apply the runtime environment and expose the host bridge. See `../src/main.js`, `../src/preload.js`, and `../src/runtime-env.js`.

## Public Surface

- `CallViewProvider`
- `createCallkitRuntime()` / `createIpcCallkitRuntime()`
- `useCall()` / `useCallState()` / `useCallkitRuntime()`
- `CallOverlay`, `IncomingOverlay`, `OutgoingOverlay`, `InCallOverlay`, `VideoCanvasView`
- `ensureCallViewStyles()` / `CALL_VIEW_STYLE_TEXT`

Group call UI is not included in the Electron sample.
