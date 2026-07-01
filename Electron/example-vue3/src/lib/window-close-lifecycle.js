'use strict';

const WINDOW_CLOSE_REQUEST_CHANNEL = 'necallkit:window-close:request';
const WINDOW_CLOSE_RESPONSE_CHANNEL = 'necallkit:window-close:response';
let nextRequestId = 1;

function describeError(error) {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
      code: error.code,
    };
  }
  return {
    name: 'Error',
    message: String(error || ''),
  };
}

function safeDestroy(browserWindow) {
  if (!browserWindow || typeof browserWindow.destroy !== 'function') {
    return;
  }
  if (
    typeof browserWindow.isDestroyed === 'function' &&
    browserWindow.isDestroyed()
  ) {
    return;
  }
  browserWindow.destroy();
}

function safeSendCloseRequest(browserWindow, payload) {
  const webContents = browserWindow && browserWindow.webContents;
  if (!webContents || typeof webContents.send !== 'function') {
    return false;
  }
  if (
    typeof webContents.isDestroyed === 'function' &&
    webContents.isDestroyed()
  ) {
    return false;
  }
  webContents.send(WINDOW_CLOSE_REQUEST_CHANNEL, payload);
  return true;
}

function detachIpcListener(ipcMain, listener) {
  if (!ipcMain || !listener) {
    return;
  }
  if (typeof ipcMain.off === 'function') {
    ipcMain.off(WINDOW_CLOSE_RESPONSE_CHANNEL, listener);
  } else if (typeof ipcMain.removeListener === 'function') {
    ipcMain.removeListener(WINDOW_CLOSE_RESPONSE_CHANNEL, listener);
  }
}

function attachRendererWindowCloseLifecycle(browserWindow, options = {}) {
  const ipcMain = options.ipcMain;
  if (
    !browserWindow ||
    typeof browserWindow.on !== 'function' ||
    typeof browserWindow.destroy !== 'function' ||
    !ipcMain ||
    typeof ipcMain.on !== 'function'
  ) {
    return false;
  }

  const timeoutMs =
    options.timeoutMs === undefined
      ? 2000
      : Math.max(0, Number(options.timeoutMs) || 0);
  let pendingClose = false;
  let forceClosing = false;

  browserWindow.on('close', (event) => {
    if (forceClosing) {
      return;
    }
    if (event && typeof event.preventDefault === 'function') {
      event.preventDefault();
    }
    if (pendingClose) {
      return;
    }
    pendingClose = true;

    const requestId = `close-${Date.now()}-${nextRequestId++}`;
    let timer = null;
    let responseListener = null;
    const finish = () => {
      if (timer) {
        clearTimeout(timer);
        timer = null;
      }
      detachIpcListener(ipcMain, responseListener);
      responseListener = null;
      forceClosing = true;
      safeDestroy(browserWindow);
    };

    responseListener = (_event, response = {}) => {
      if (!response || response.requestId !== requestId) {
        return;
      }
      finish();
    };
    ipcMain.on(WINDOW_CLOSE_RESPONSE_CHANNEL, responseListener);

    if (timeoutMs > 0) {
      timer = setTimeout(finish, timeoutMs);
      if (typeof timer.unref === 'function') {
        timer.unref();
      }
    }

    const sent = safeSendCloseRequest(browserWindow, {
      requestId,
      reason: options.reason || 'window-close',
    });
    if (!sent) {
      finish();
    }
  });

  return true;
}

function installRendererWindowCloseBridge(options = {}) {
  const ipcRenderer = options.ipcRenderer;
  const windowTarget =
    options.windowTarget || (typeof window !== 'undefined' ? window : null);
  if (
    !ipcRenderer ||
    typeof ipcRenderer.on !== 'function' ||
    typeof ipcRenderer.send !== 'function'
  ) {
    return false;
  }

  ipcRenderer.on(WINDOW_CLOSE_REQUEST_CHANNEL, async (_event, request = {}) => {
    const requestId = request && request.requestId;
    try {
      const handler =
        windowTarget && windowTarget.__NECALL_HANDLE_WINDOW_CLOSE__;
      const result =
        typeof handler === 'function'
          ? await handler(request)
          : { skipped: 'no-renderer-window-close-handler' };
      ipcRenderer.send(WINDOW_CLOSE_RESPONSE_CHANNEL, {
        requestId,
        ok: true,
        result,
      });
    } catch (error) {
      ipcRenderer.send(WINDOW_CLOSE_RESPONSE_CHANNEL, {
        requestId,
        ok: false,
        error: describeError(error),
      });
    }
  });

  return true;
}

module.exports = {
  WINDOW_CLOSE_REQUEST_CHANNEL,
  WINDOW_CLOSE_RESPONSE_CHANNEL,
  attachRendererWindowCloseLifecycle,
  installRendererWindowCloseBridge,
};
