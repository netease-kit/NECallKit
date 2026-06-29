'use strict';

const fs = require('node:fs');
const path = require('node:path');
const { createRequire } = require('node:module');
const {
  formatLoginErrorMessage,
} = require('./example-error-message');

const V2_NIM_LOGIN_STATUS_LOGINED = 1;
const DEFAULT_V2_LOGIN_READY_TIMEOUT_MS = 5000;
const DEFAULT_V2_LOGIN_READY_POLL_MS = 50;

function normalizeScope(value) {
  const normalized = String(value || 'example')
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return normalized || 'example';
}

function normalizeLoadOptions(loadOptions) {
  if (typeof loadOptions === 'function') {
    return {
      requireFn: loadOptions,
    };
  }
  if (loadOptions && typeof loadOptions === 'object') {
    return loadOptions;
  }
  return {};
}

function normalizeExternalOwnerMode(value) {
  const normalized = String(value || '')
    .trim()
    .toLowerCase();
  return normalized === 'node-nim' ? 'node-nim' : 'host-first';
}

function resolveModulePath(resolveFn, request) {
  if (typeof resolveFn !== 'function') {
    return '';
  }

  try {
    return resolveFn(request);
  } catch (_error) {
    return '';
  }
}

function resolvePackageRoot(resolveFn, packageName) {
  const packageJsonPath = resolveModulePath(resolveFn, `${packageName}/package.json`);
  return packageJsonPath ? path.dirname(packageJsonPath) : '';
}

function pushExistingPackageRoot(candidates, packageRoot) {
  if (!packageRoot) {
    return;
  }
  if (!fs.existsSync(path.join(packageRoot, 'package.json'))) {
    return;
  }
  candidates.push(packageRoot);
}

function collectCallkitAddonCandidates(options = {}) {
  const requireFn = options.requireFn || require;
  const resolveFn = options.resolveFn || requireFn.resolve || require.resolve;
  const candidates = [
    options.callkitAddonPath,
    process.env.NECALL_NODE_ADDON_PATH || '',
    options.callkitAddonRequest,
    '@xkit-yx/electron-callkit-node-addon',
  ].filter(Boolean);

  const sdkRoot = resolvePackageRoot(resolveFn, '@xkit-yx/electron-callkit-sdk');
  if (sdkRoot) {
    pushExistingPackageRoot(
      candidates,
      path.join(
        sdkRoot,
        'node_modules',
        '@xkit-yx',
        'electron-callkit-node-addon'
      )
    );
  }

  for (const uikitPackageName of [
    '@xkit-yx/electron-callkit-vue3-uikit',
  ]) {
    const uikitRoot = resolvePackageRoot(resolveFn, uikitPackageName);
    if (uikitRoot) {
      pushExistingPackageRoot(
        candidates,
        path.join(
          uikitRoot,
          'node_modules',
          '@xkit-yx',
          'electron-callkit-sdk',
          'node_modules',
          '@xkit-yx',
          'electron-callkit-node-addon'
        )
      );
    }
  }

  return candidates;
}

function isMissingNodeNimNativeAddonError(error) {
  const message = error instanceof Error ? error.message : String(error || '');
  return /build[\\/]+Release[\\/]+node-nim\.node/i.test(message);
}

function resolveStagedNodeNimAddonPath(options = {}) {
  const candidates = [];
  if (options.stagedNativeAddonPath) {
    candidates.push(options.stagedNativeAddonPath);
  }

  const callkitAddonPath =
    options.callkitAddonPath || process.env.NECALL_NODE_ADDON_PATH || '';
  if (callkitAddonPath) {
    candidates.push(path.join(path.dirname(callkitAddonPath), 'node-nim.node'));
  }

  const resourcesPath = options.resourcesPath || process.resourcesPath || '';
  if (resourcesPath) {
    candidates.push(path.join(resourcesPath, 'native', 'node-nim.node'));
  }

  return candidates.find((candidate) => candidate && fs.existsSync(candidate)) || '';
}

function loadNodeNimModuleFromPackageRoot(packageRoot, stagedNativeAddonPath, options = {}) {
  if (!packageRoot || !stagedNativeAddonPath) {
    return null;
  }

  const packageJsonPath = path.join(packageRoot, 'package.json');
  if (!fs.existsSync(packageJsonPath) || !fs.existsSync(stagedNativeAddonPath)) {
    return null;
  }

  const packageRequire = createRequire(packageJsonPath);
  const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf8'));
  const mainEntry =
    typeof packageJson.main === 'string' && packageJson.main
      ? packageJson.main
      : 'dist/node-nim.js';
  const entryRequest = mainEntry.startsWith('.') ? mainEntry : `./${mainEntry}`;
  const loaderPath = resolveModulePath(packageRequire.resolve, './dist/loader.js');
  const nativeRequireFn = options.nativeRequireFn || require;

  if (!loaderPath) {
    return null;
  }

  require.cache[loaderPath] = {
    id: loaderPath,
    filename: loaderPath,
    loaded: true,
    exports: nativeRequireFn(stagedNativeAddonPath),
    children: [],
    paths: [],
  };

  return packageRequire(entryRequest);
}

function loadNodeNimModuleFromStagedNative(resolveFn, options = {}) {
  const packageJsonPath = resolveModulePath(resolveFn, 'node-nim/package.json');
  const stagedNativeAddonPath = resolveStagedNodeNimAddonPath(options);
  if (!packageJsonPath || !stagedNativeAddonPath) {
    return null;
  }

  return loadNodeNimModuleFromPackageRoot(
    path.dirname(packageJsonPath),
    stagedNativeAddonPath,
    options
  );
}

function shouldPreferStagedNodeNimModule(options = {}) {
  const stagedNativeAddonPath = resolveStagedNodeNimAddonPath(options);
  if (!stagedNativeAddonPath) {
    return false;
  }
  if (options.stagedNativeAddonPath) {
    return true;
  }

  const stagedNativeDirectory = path.dirname(stagedNativeAddonPath);
  if (process.platform === 'darwin') {
    return fs.existsSync(path.join(stagedNativeDirectory, 'libh_available.dylib'));
  }
  if (process.platform === 'win32') {
    return fs.existsSync(path.join(stagedNativeDirectory, 'h_available.dll'));
  }
  return false;
}

function loadNodeNimModule(loadOptions = {}) {
  const options = normalizeLoadOptions(loadOptions);
  const requireFn = options.requireFn || require;
  const resolveFn = options.resolveFn || requireFn.resolve || require.resolve;
  let lastError = null;

  if (shouldPreferStagedNodeNimModule(options)) {
    const stagedModule = loadNodeNimModuleFromStagedNative(resolveFn, options);
    if (stagedModule) {
      return stagedModule;
    }
  }

  try {
    return requireFn('node-nim');
  } catch (error) {
    lastError = error;
    if (isMissingNodeNimNativeAddonError(error)) {
      const stagedModule = loadNodeNimModuleFromStagedNative(resolveFn, options);
      if (stagedModule) {
        return stagedModule;
      }
    }

    const resourcesPath = options.resourcesPath || process.resourcesPath || '';
    if (resourcesPath) {
      const packagedRequire = createRequire(path.join(resourcesPath, 'app', 'package.json'));
      try {
        return packagedRequire('node-nim');
      } catch (fallbackError) {
        lastError = fallbackError;
        if (isMissingNodeNimNativeAddonError(fallbackError)) {
          const stagedModule = loadNodeNimModuleFromStagedNative(
            packagedRequire.resolve,
            Object.assign({}, options, {
              resourcesPath,
            })
          );
          if (stagedModule) {
            return stagedModule;
          }
        }
      }
    }

    const message =
      lastError instanceof Error ? lastError.message : String(lastError || error);
    throw new Error(`node-nim is required for external mode: ${message}`);
  }
}

function formatNodeNimV2ErrorSuffix(error) {
  if (!error) {
    return '';
  }
  if (error instanceof Error) {
    return `: ${error.message}`;
  }
  if (typeof error === 'object') {
    const code = error.code !== undefined ? String(error.code) : '';
    const desc = error.desc !== undefined ? String(error.desc) : '';
    if (code || desc) {
      return ` with code ${code || 'unknown'}${desc ? `: ${desc}` : ''}`;
    }
  }
  return `: ${String(error)}`;
}

function normalizePositiveInteger(value, fallback) {
  const normalized = Number(value);
  if (!Number.isFinite(normalized) || normalized <= 0) {
    return fallback;
  }
  return Math.floor(normalized);
}

function readV2LoginStatus(loginService) {
  if (!loginService || typeof loginService.getLoginStatus !== 'function') {
    return undefined;
  }

  try {
    const value = Number(loginService.getLoginStatus());
    return Number.isFinite(value) ? value : undefined;
  } catch (_error) {
    return undefined;
  }
}

function removeV2LoginListener(loginService, eventName, listener) {
  if (!loginService || typeof listener !== 'function') {
    return;
  }
  if (typeof loginService.off === 'function') {
    loginService.off(eventName, listener);
    return;
  }
  if (typeof loginService.removeListener === 'function') {
    loginService.removeListener(eventName, listener);
  }
}

function isV2LoginReadyFor(loginService, accountId, getCurrentAccountId) {
  const currentAccountId = String(getCurrentAccountId() || '').trim();
  if (currentAccountId !== accountId) {
    return false;
  }

  const loginStatus = readV2LoginStatus(loginService);
  return (
    loginStatus === undefined ||
    loginStatus === V2_NIM_LOGIN_STATUS_LOGINED
  );
}

function waitForNodeNimV2LoginReady(options = {}) {
  const loginService = options.loginService;
  const accountId = String(options.accountId || '').trim();
  const getCurrentAccountId = options.getCurrentAccountId;
  const timeoutMs = normalizePositiveInteger(
    options.timeoutMs,
    DEFAULT_V2_LOGIN_READY_TIMEOUT_MS
  );
  const pollMs = normalizePositiveInteger(
    options.pollMs,
    DEFAULT_V2_LOGIN_READY_POLL_MS
  );

  if (
    isV2LoginReadyFor(loginService, accountId, getCurrentAccountId)
  ) {
    return Promise.resolve({
      currentAccountId: String(getCurrentAccountId() || '').trim(),
      loginStatus: readV2LoginStatus(loginService),
    });
  }

  return new Promise((resolve, reject) => {
    let finished = false;
    let timeoutId = null;
    let pollId = null;

    const cleanup = () => {
      if (timeoutId !== null) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }
      if (pollId !== null) {
        clearInterval(pollId);
        pollId = null;
      }
      removeV2LoginListener(loginService, 'loginStatus', onLoginStatus);
      removeV2LoginListener(loginService, 'loginFailed', onLoginFailed);
    };

    const finish = (error) => {
      if (finished) {
        return;
      }
      finished = true;
      cleanup();
      if (error) {
        reject(error);
        return;
      }
      resolve({
        currentAccountId: String(getCurrentAccountId() || '').trim(),
        loginStatus: readV2LoginStatus(loginService),
      });
    };

    const checkReady = () => {
      const currentAccountId = String(getCurrentAccountId() || '').trim();
      if (currentAccountId && currentAccountId !== accountId) {
        finish(
          new Error(
            `Current account mismatch after node-nim V2 login: expected ${accountId}, got ${currentAccountId}`
          )
        );
        return;
      }

      if (isV2LoginReadyFor(loginService, accountId, getCurrentAccountId)) {
        finish(null);
      }
    };

    function onLoginStatus() {
      checkReady();
    }

    function onLoginFailed(error) {
      finish(
        new Error(
          `node-nim V2 login failed before LOGINED status${formatNodeNimV2ErrorSuffix(
            error
          )}`
        )
      );
    }

    if (loginService && typeof loginService.on === 'function') {
      loginService.on('loginStatus', onLoginStatus);
      loginService.on('loginFailed', onLoginFailed);
    }

    pollId = setInterval(checkReady, pollMs);
    timeoutId = setTimeout(() => {
      const currentAccountId = String(getCurrentAccountId() || '').trim();
      const loginStatus = readV2LoginStatus(loginService);
      finish(
        new Error(
          `node-nim V2 login did not reach LOGINED status before timeout: expected ${accountId}, got ${
            currentAccountId || 'empty'
          }, loginStatus=${
            loginStatus === undefined ? 'unknown' : String(loginStatus)
          }`
        )
      );
    }, timeoutMs);
    checkReady();
  });
}

function isSupportedV2LoginService(loginService) {
  return Boolean(
    loginService &&
      typeof loginService.login === 'function' &&
      typeof loginService.logout === 'function' &&
      typeof loginService.getLoginUser === 'function'
  );
}

function isSupportedV2Client(client) {
  return Boolean(
    client &&
      typeof client.init === 'function' &&
      typeof client.uninit === 'function' &&
      (typeof client.getLoginService === 'function' || client.loginService) &&
      (typeof client.getMessageService === 'function' || client.messageService)
  );
}

function resolveNodeNimV2Client(nimModule, options = {}) {
  if (isSupportedV2Client(options.v2Client)) {
    return options.v2Client;
  }
  if (isSupportedV2Client(nimModule && nimModule.v2Client)) {
    return nimModule.v2Client;
  }
  const exportedClient = nimModule && nimModule.V2NIMClient;
  if (isSupportedV2Client(exportedClient)) {
    return exportedClient;
  }
  if (typeof exportedClient === 'function') {
    const client = new exportedClient();
    if (isSupportedV2Client(client)) {
      return client;
    }
  }
  const namespacedClient = nimModule && nimModule.NIM && nimModule.NIM.V2NIMClient;
  if (isSupportedV2Client(namespacedClient)) {
    return namespacedClient;
  }
  if (typeof namespacedClient === 'function') {
    const client = new namespacedClient();
    if (isSupportedV2Client(client)) {
      return client;
    }
  }
  return null;
}

function getV2LoginService(client) {
  if (!client) {
    return null;
  }
  if (typeof client.getLoginService === 'function') {
    return client.getLoginService();
  }
  return client.loginService || null;
}

function readV2MessageService(client) {
  if (!client) {
    return null;
  }
  if (typeof client.getMessageService === 'function') {
    return client.getMessageService();
  }
  return client.messageService || null;
}

function describeV2Error(error) {
  if (!error) {
    return '';
  }
  if (error instanceof Error) {
    return error.message;
  }
  if (typeof error === 'object') {
    const code = error.code !== undefined ? `code ${error.code}` : '';
    const desc = error.desc || error.message || '';
    return [code, desc].filter(Boolean).join(': ') || JSON.stringify(error);
  }
  return String(error);
}

function createNodeNimV2ExternalSession(options = {}) {
  const nimModule = options.nimModule || loadNodeNimModule(options);
  const client = resolveNodeNimV2Client(nimModule, options);

  if (!client) {
    throw new Error('node-nim V2 client API is unavailable');
  }

  const appDataDir =
    options.appDataDir || `necallkit-electron-${normalizeScope(options.scope)}`;
  const v2InitOption = Object.assign({}, options.v2InitOption);
  const v2LoginOption = Object.assign({}, options.v2LoginOption);
  const v2LoginReadyTimeoutMs = normalizePositiveInteger(
    options.v2LoginReadyTimeoutMs,
    DEFAULT_V2_LOGIN_READY_TIMEOUT_MS
  );
  const v2LoginReadyPollMs = normalizePositiveInteger(
    options.v2LoginReadyPollMs,
    DEFAULT_V2_LOGIN_READY_POLL_MS
  );
  let initialized = false;
  let initializedAppKey = '';
  let lastAccountId = '';

  function cleanupInternal() {
    if (!initialized) {
      return;
    }
    const error = client.uninit();
    initialized = false;
    initializedAppKey = '';
    lastAccountId = '';
    if (error) {
      throw new Error(`node-nim V2 uninit failed: ${describeV2Error(error)}`);
    }
  }

  function throwFormattedLoginError(error) {
    try {
      cleanupInternal();
    } catch (cleanupError) {
      const nextError = new Error(
        `${formatLoginErrorMessage(error)}; cleanup failed: ${describeV2Error(cleanupError)}`
      );
      nextError.cause = error;
      throw nextError;
    }

    const nextError = new Error(formatLoginErrorMessage(error));
    nextError.cause = error;
    throw nextError;
  }

  function throwLoginReadyError(error) {
    try {
      cleanupInternal();
    } catch (cleanupError) {
      const nextError = new Error(
        `${error instanceof Error ? error.message : String(error)}; cleanup failed: ${describeV2Error(cleanupError)}`
      );
      nextError.cause = error;
      throw nextError;
    }

    throw error;
  }

  function ensureInitialized(appKey) {
    if (initialized) {
      if (initializedAppKey === appKey) {
        return;
      }
      cleanupInternal();
    }
    if (initialized) {
      return;
    }
    const error = client.init(
      Object.assign(
        {
          appkey: appKey,
          appDataPath: appDataDir,
        },
        v2InitOption
      )
    );
    if (error) {
      throw new Error(`node-nim V2 init failed: ${describeV2Error(error)}`);
    }
    initialized = true;
    initializedAppKey = appKey;
  }

  function getCurrentAccountId() {
    if (!initialized) {
      return '';
    }
    try {
      const loginService = getV2LoginService(client);
      if (loginService && typeof loginService.getLoginUser === 'function') {
        return String(loginService.getLoginUser() || '').trim();
      }
    } catch (_error) {
      return lastAccountId;
    }
    return lastAccountId;
  }

  async function logout() {
    if (!initialized) {
      return false;
    }

    const currentAccountId = getCurrentAccountId();
    if (currentAccountId) {
      const loginService = getV2LoginService(client);
      if (loginService && typeof loginService.logout === 'function') {
        await loginService.logout();
      }
    }

    lastAccountId = '';
    return true;
  }

  async function destroy() {
    if (!initialized) {
      return false;
    }

    let logoutError = null;
    try {
      await logout();
    } catch (error) {
      logoutError = error;
    }

    try {
      cleanupInternal();
    } catch (cleanupError) {
      if (logoutError) {
        const nextError = new Error(
          `${describeV2Error(logoutError)}; cleanup failed: ${describeV2Error(cleanupError)}`
        );
        nextError.cause = logoutError;
        throw nextError;
      }
      throw cleanupError;
    }

    if (logoutError) {
      throw logoutError;
    }
    return true;
  }

  async function login(config = {}) {
    const appKey = String(config.appKey || '').trim();
    const accountId = String(config.accountId || '').trim();
    const accountToken = String(config.accountToken || '').trim();

    if (!appKey) {
      throw new Error('external node-nim V2 login requires appKey');
    }
    if (!accountId) {
      throw new Error('external node-nim V2 login requires accountId');
    }
    if (!accountToken) {
      throw new Error('external node-nim V2 login requires accountToken');
    }

    ensureInitialized(appKey);

    const currentAccountId = getCurrentAccountId();
    if (currentAccountId) {
      // node-nim may restore a same-account login from its local DB during init.
      // The login page submission must validate the token typed in the window.
      await logout();
    }

    const loginService = getV2LoginService(client);
    if (!loginService || typeof loginService.login !== 'function') {
      cleanupInternal();
      throw new Error('node-nim V2 loginService.login is unavailable');
    }

    try {
      await loginService.login(accountId, accountToken, v2LoginOption);
    } catch (error) {
      throwFormattedLoginError(error);
    }

    let loginReadyState = null;
    try {
      loginReadyState = await waitForNodeNimV2LoginReady({
        loginService,
        accountId,
        getCurrentAccountId,
        timeoutMs: v2LoginReadyTimeoutMs,
        pollMs: v2LoginReadyPollMs,
      });
    } catch (error) {
      throwLoginReadyError(error);
    }
    lastAccountId = accountId;

    const readyAccountId =
      (loginReadyState && loginReadyState.currentAccountId) ||
      getCurrentAccountId();
    if (readyAccountId !== accountId) {
      cleanupInternal();
      throw new Error(
        `Current account mismatch after node-nim V2 login: expected ${accountId}, got ${
          readyAccountId || 'empty'
        }`
      );
    }

    return {
      currentAccountId: readyAccountId,
      reusedExistingLogin: false,
      owner: 'node-nim-v2',
    };
  }

  return {
    login,
    logout,
    destroy,
    getCurrentAccountId,
    getV2MessageService() {
      return initialized ? readV2MessageService(client) : null;
    },
    getMessageService() {
      return initialized ? readV2MessageService(client) : null;
    },
    isReadyFor(accountId) {
      return !!accountId && getCurrentAccountId() === String(accountId).trim();
    },
  };
}

function loadCallkitBinding(loadOptions = {}) {
  const options = normalizeLoadOptions(loadOptions);
  const externalOwnerMode = normalizeExternalOwnerMode(options.externalOwnerMode);
  if (options.callkitBinding && typeof options.callkitBinding === 'object') {
    if (externalOwnerMode === 'node-nim') {
      return null;
    }
    return options.callkitBinding;
  }
  if (externalOwnerMode === 'node-nim') {
    return null;
  }
  if (!options.callkitAddonPath && !options.callkitAddonRequest && options.nimModule) {
    return null;
  }

  const requireFn = options.requireFn || require;
  const candidates = collectCallkitAddonCandidates(options);

  for (const candidate of candidates) {
    try {
      return requireFn(candidate);
    } catch (_error) {
      continue;
    }
  }

  return null;
}

function isSupportedHostBinding(binding) {
  return Boolean(
    binding &&
      typeof binding.hostExternalLogin === 'function' &&
      typeof binding.hostExternalLogout === 'function' &&
      typeof binding.hostExternalGetCurrentAccountId === 'function'
  );
}

function isHostExternalUnsupportedError(error) {
  const candidates = [error];
  if (error && typeof error === 'object') {
    if (error.cause) {
      candidates.push(error.cause);
    }
    if (error.context && typeof error.context === 'object') {
      candidates.push(error.context);
    }
  }

  for (const candidate of candidates) {
    if (!candidate || typeof candidate !== 'object') {
      continue;
    }
    if (candidate.code === 'NECALL_HOST_EXTERNAL_UNSUPPORTED') {
      return true;
    }
    if (candidate.internalCode === 'NECALL_HOST_EXTERNAL_UNSUPPORTED') {
      return true;
    }
  }

  const message = error instanceof Error ? error.message : String(error || '');
  return /host external runtime requires V2 NIM headers during node-addon build/i.test(
    message
  );
}

function createNodeNimExternalSession(options = {}) {
  const nimModule = options.nimModule || loadNodeNimModule(options);
  const v2Client = resolveNodeNimV2Client(nimModule, options);

  if (!v2Client) {
    throw new Error(
      options.requireV2
        ? 'node-nim V2 client API is required for default IM call records'
        : 'node-nim V2NIMClient API is unavailable'
    );
  }

  return createNodeNimV2ExternalSession(
    Object.assign({}, options, {
      nimModule,
      v2Client,
    })
  );
}

function createHostExternalSession(binding) {
  function getCurrentAccountId() {
    try {
      return String(binding.hostExternalGetCurrentAccountId() || '').trim();
    } catch (_error) {
      return '';
    }
  }

  async function logout() {
    const currentAccountId = getCurrentAccountId();
    if (!currentAccountId) {
      return false;
    }

    await Promise.resolve(binding.hostExternalLogout());
    return true;
  }

  async function login(config = {}) {
    const appKey = String(config.appKey || '').trim();
    const accountId = String(config.accountId || '').trim();
    const accountToken = String(config.accountToken || '').trim();

    if (!appKey) {
      throw new Error('external host login requires appKey');
    }
    if (!accountId) {
      throw new Error('external host login requires accountId');
    }
    if (!accountToken) {
      throw new Error('external host login requires accountToken');
    }

    const currentAccountId = getCurrentAccountId();
    if (currentAccountId && currentAccountId !== accountId) {
      await logout();
    }

    const loginResult = await Promise.resolve(binding.hostExternalLogin(config));
    const readyAccountId = getCurrentAccountId();
    if (readyAccountId !== accountId) {
      await Promise.resolve(binding.hostExternalLogout()).catch(() => {});
      throw new Error(
        `Current account mismatch after host external login: expected ${accountId}, got ${
          readyAccountId || 'empty'
        }`
      );
    }

    return {
      currentAccountId: readyAccountId,
      reusedExistingLogin: !!(loginResult && loginResult.reusedExistingLogin),
      loginResult,
    };
  }

  return {
    login,
    logout,
    destroy: logout,
    getCurrentAccountId,
    isReadyFor(accountId) {
      return !!accountId && getCurrentAccountId() === String(accountId).trim();
    },
  };
}

function createExternalNimSession(options = {}) {
  const externalOwnerMode = normalizeExternalOwnerMode(options.externalOwnerMode);
  const callkitBinding = loadCallkitBinding(options);
  const preferredHostSession =
    externalOwnerMode !== 'node-nim' && isSupportedHostBinding(callkitBinding)
    ? createHostExternalSession(callkitBinding)
    : null;
  let nodeNimSession = null;
  let activeSession = preferredHostSession;

  function ensureNodeNimSession() {
    if (!nodeNimSession) {
      nodeNimSession = createNodeNimExternalSession(options);
    }
    return nodeNimSession;
  }

  function readCurrentAccountId() {
    if (activeSession) {
      return activeSession.getCurrentAccountId();
    }
    if (preferredHostSession) {
      return preferredHostSession.getCurrentAccountId();
    }
    if (nodeNimSession) {
      return nodeNimSession.getCurrentAccountId();
    }
    return '';
  }

  function readV2MessageService() {
    const candidates = [activeSession, nodeNimSession, preferredHostSession].filter(Boolean);
    for (const session of candidates) {
      if (typeof session.getV2MessageService === 'function') {
        const service = session.getV2MessageService();
        if (service) {
          return service;
        }
      }
      if (typeof session.getMessageService === 'function') {
        const service = session.getMessageService();
        if (service) {
          return service;
        }
      }
    }
    return null;
  }

  async function login(config = {}) {
    if (preferredHostSession && activeSession !== nodeNimSession) {
      activeSession = preferredHostSession;
      try {
        return await preferredHostSession.login(config);
      } catch (error) {
        if (!isHostExternalUnsupportedError(error)) {
          throw error;
        }

        activeSession = ensureNodeNimSession();
        return activeSession.login(config);
      }
    }

    activeSession = activeSession || ensureNodeNimSession();
    return activeSession.login(config);
  }

  async function logout() {
    if (!activeSession) {
      return false;
    }
    return activeSession.logout();
  }

  async function destroy() {
    const sessions = [activeSession, nodeNimSession, preferredHostSession].filter(
      (session, index, list) => session && list.indexOf(session) === index
    );
    if (sessions.length === 0) {
      return false;
    }

    let destroyed = false;
    for (const session of sessions) {
      if (typeof session.destroy === 'function') {
        destroyed = (await session.destroy()) || destroyed;
      } else if (typeof session.logout === 'function') {
        destroyed = (await session.logout()) || destroyed;
      }
    }
    nodeNimSession = null;
    activeSession = preferredHostSession;
    return destroyed;
  }

  return {
    login,
    logout,
    destroy,
    getCurrentAccountId: readCurrentAccountId,
    getV2MessageService: readV2MessageService,
    getMessageService: readV2MessageService,
    isReadyFor(accountId) {
      return !!accountId && readCurrentAccountId() === String(accountId).trim();
    },
  };
}

module.exports = {
  collectCallkitAddonCandidates,
  createExternalNimSession,
  createNodeNimExternalSession,
  createNodeNimV2ExternalSession,
  loadCallkitBinding,
  loadNodeNimModule,
  normalizeExternalOwnerMode,
  resolveNodeNimV2Client,
};
