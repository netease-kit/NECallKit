'use strict';

const { inject } = require('vue');

const CallkitRuntimeKey = Symbol('ElectronCallkitRuntime');

function useCallkitRuntime() {
  return inject(CallkitRuntimeKey);
}

function useCall() {
  return useCallkitRuntime();
}

function useCallState() {
  const runtime = useCallkitRuntime();
  if (!runtime) {
    throw new Error('CallViewProvider is required before calling useCallState()');
  }
  return runtime.state;
}

module.exports = {
  CallkitRuntimeKey,
  useCall,
  useCallkitRuntime,
  useCallState,
};
