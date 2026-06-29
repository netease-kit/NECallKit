'use strict';

const PROCESS_DIAGNOSTICS_KEY = Symbol.for(
  'necallkit.electron.example.process-diagnostics'
);

function pickLoggerMethod(logger, level) {
  if (logger && typeof logger[level] === 'function') {
    return logger[level].bind(logger);
  }
  if (logger && typeof logger.log === 'function') {
    return logger.log.bind(logger);
  }
  return console.log.bind(console);
}

function log(logger, level, label, message, details) {
  const write = pickLoggerMethod(logger, level);
  if (details === undefined) {
    write(`[${label}] ${message}`);
    return;
  }
  write(`[${label}] ${message}`, details);
}

function normalizeError(error) {
  if (error instanceof Error) {
    return {
      name: error.name,
      message: error.message,
      stack: error.stack,
    };
  }
  return error;
}

function attachWindowDiagnostics(window, options = {}) {
  const label = options.label || 'electron-example';
  const logger = options.logger || console;
  const webContents = window && window.webContents;

  if (!webContents) {
    throw new Error('attachWindowDiagnostics requires a BrowserWindow-like object');
  }

  webContents.once('dom-ready', () => {
    log(logger, 'info', label, 'dom-ready');
    if (typeof webContents.openDevTools === 'function') {
      webContents.openDevTools({
        mode: 'detach',
        activate: false,
      });
    }
  });

  webContents.on('did-finish-load', () => {
    log(logger, 'info', label, 'did-finish-load', {
      url: typeof webContents.getURL === 'function' ? webContents.getURL() : '',
    });
  });

  webContents.on(
    'did-fail-load',
    (_event, errorCode, errorDescription, validatedURL, isMainFrame) => {
      log(logger, 'error', label, 'did-fail-load', {
        errorCode,
        errorDescription,
        validatedURL,
        isMainFrame,
      });
    }
  );

  webContents.on('render-process-gone', (_event, details) => {
    log(logger, 'error', label, 'render-process-gone', details);
  });

  webContents.on(
    'console-message',
    (_event, level, message, line, sourceId) => {
      const logLevel = level >= 2 ? 'error' : 'info';
      log(logger, logLevel, label, 'console-message', {
        level,
        message,
        line,
        sourceId,
      });
    }
  );

  window.on('unresponsive', () => {
    log(logger, 'error', label, 'browser-window-unresponsive');
  });

  window.on('closed', () => {
    log(logger, 'info', label, 'browser-window-closed');
  });
}

function isReloadShortcut(input = {}) {
  const key = typeof input.key === 'string' ? input.key.toLowerCase() : '';

  if (key === 'f5') {
    return true;
  }

  return key === 'r' && Boolean(input.control || input.meta);
}

function installReloadGuard(window, options = {}) {
  const webContents = window && window.webContents;

  if (!webContents) {
    throw new Error('installReloadGuard requires a BrowserWindow-like object');
  }

  const menu = options.menu;
  if (menu && typeof menu.setApplicationMenu === 'function') {
    menu.setApplicationMenu(null);
  }

  ['reload', 'reloadIgnoringCache'].forEach((methodName) => {
    if (typeof webContents[methodName] !== 'function') {
      return;
    }

    try {
      webContents[methodName] = () => {};
    } catch (_error) {}
  });

  webContents.on('before-input-event', (event, input) => {
    if (!isReloadShortcut(input)) {
      return;
    }

    if (event && typeof event.preventDefault === 'function') {
      event.preventDefault();
    }
  });
}

function installProcessDiagnostics(options = {}) {
  const label = options.label || 'electron-example';
  const logger = options.logger || console;
  const processLike = options.processLike || process;

  if (processLike[PROCESS_DIAGNOSTICS_KEY]) {
    return;
  }

  processLike[PROCESS_DIAGNOSTICS_KEY] = true;
  processLike.on('uncaughtException', (error) => {
    log(logger, 'error', label, 'uncaughtException', normalizeError(error));
  });
  processLike.on('unhandledRejection', (reason) => {
    log(logger, 'error', label, 'unhandledRejection', normalizeError(reason));
  });
}

module.exports = {
  attachWindowDiagnostics,
  installReloadGuard,
  installProcessDiagnostics,
};
