'use strict';

const DEFAULT_HANGUP_GRACE_MS = 1500;
const DEFAULT_HANGUP_FLUSH_MS = 300;

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

function delay(ms) {
  if (!ms || ms <= 0) {
    return Promise.resolve();
  }
  return new Promise((resolve) => setTimeout(resolve, ms));
}

function readRuntimeState(runtime) {
  if (runtime && typeof runtime.getState === 'function') {
    try {
      const state = runtime.getState();
      if (state && typeof state === 'object') {
        return state;
      }
    } catch (_) {
      // Fall through to runtime.state.
    }
  }
  return runtime && runtime.state && typeof runtime.state === 'object'
    ? runtime.state
    : {};
}

function readActiveCallSnapshot(runtime) {
  const state = readRuntimeState(runtime);
  const callInfo = (state && state.callInfo) || {};
  const inviteInfo = (state && state.inviteInfo) || {};
  const rawCallStatus =
    state.callStatus !== undefined
      ? state.callStatus
      : callInfo.callStatus !== undefined
        ? callInfo.callStatus
        : inviteInfo.callStatus;
  const callStatus = Number(rawCallStatus);
  const callId =
    (callInfo && callInfo.callId) || (inviteInfo && inviteInfo.callId) || '';
  return {
    active: Number.isFinite(callStatus) && callStatus !== 0,
    callStatus: Number.isFinite(callStatus) ? callStatus : 0,
    callId: callId || '',
  };
}

async function waitWithTimeout(promise, timeoutMs) {
  if (!timeoutMs || timeoutMs <= 0) {
    return {
      ok: true,
      value: await promise,
      timedOut: false,
    };
  }
  let timer = null;
  return new Promise((resolve) => {
    timer = setTimeout(() => {
      timer = null;
      resolve({
        ok: false,
        timedOut: true,
        error: new Error('hangup_grace_timeout'),
      });
    }, timeoutMs);
    Promise.resolve(promise).then(
      (value) => {
        if (timer) {
          clearTimeout(timer);
          timer = null;
        }
        resolve({ ok: true, value, timedOut: false });
      },
      (error) => {
        if (timer) {
          clearTimeout(timer);
          timer = null;
        }
        resolve({ ok: false, error, timedOut: false });
      }
    );
  });
}

function createRendererWindowCloseHandler(options = {}) {
  const runtime = options.runtime;
  const teardown = options.teardown;
  let handled = false;

  return async function handleRendererWindowClose(request = {}) {
    if (handled) {
      return { skipped: 'already-handled' };
    }
    handled = true;

    const reason = request.reason || 'window-close';
    const graceMs =
      request.graceMs === undefined
        ? DEFAULT_HANGUP_GRACE_MS
        : Math.max(0, Number(request.graceMs) || 0);
    const flushMs =
      request.flushMs === undefined
        ? DEFAULT_HANGUP_FLUSH_MS
        : Math.max(0, Number(request.flushMs) || 0);
    const snapshot = readActiveCallSnapshot(runtime);
    let hangupTriggered = false;
    let timedOut = false;
    let hangupError = null;

    if (snapshot.active && runtime && typeof runtime.hangup === 'function') {
      hangupTriggered = true;
      const payload = snapshot.callId ? { callId: snapshot.callId } : {};
      const result = await waitWithTimeout(
        Promise.resolve().then(() => runtime.hangup(payload)),
        graceMs
      );
      timedOut = !!result.timedOut;
      if (!result.ok && result.error) {
        hangupError = describeError(result.error);
      }
      await delay(flushMs);
    }

    let teardownError = null;
    if (typeof teardown === 'function') {
      try {
        await teardown({
          reason,
          silent: true,
          destroyNative: true,
          destroyExternalSession: true,
        });
      } catch (error) {
        teardownError = describeError(error);
      }
    }

    return {
      reason,
      hangupTriggered,
      timedOut,
      snapshot,
      ...(hangupError ? { error: hangupError.message } : {}),
      ...(teardownError ? { teardownError: teardownError.message } : {}),
    };
  };
}

module.exports = {
  createRendererWindowCloseHandler,
  readActiveCallSnapshot,
};
