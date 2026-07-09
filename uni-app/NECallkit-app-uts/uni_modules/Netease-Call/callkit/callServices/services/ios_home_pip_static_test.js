const fs = require('fs');
const assert = require('assert');

const source = fs.readFileSync(
  'uni-app/NECallKit-app-uts/uni_modules/Netease-Call/callkit/callServices/services/index.ts',
  'utf8'
);

const hideHandlerStart = source.indexOf('uni.onAppHide(() => {');
assert.notStrictEqual(hideHandlerStart, -1, 'uni.onAppHide handler should exist');
const hideHandlerEnd = source.indexOf('uni.onAppShow(() => {', hideHandlerStart);
assert.notStrictEqual(hideHandlerEnd, -1, 'uni.onAppHide handler should end before onAppShow');
const hideHandler = source.slice(hideHandlerStart, hideHandlerEnd);

assert(
  hideHandler.includes('#ifndef APP-IOS') &&
    hideHandler.includes('this._startFloatWindowWhenHome();') &&
    hideHandler.includes('#endif'),
  'iOS app hide should not auto-start the in-app floating window; CallUIKit should trigger system PiP from UIApplicationDidEnterBackground'
);

const setupBodyStart = source.indexOf('setup(options)');
assert.notStrictEqual(setupBodyStart, -1, 'CallService setup should exist');
const setupBodyEnd = source.indexOf('public login', setupBodyStart);
const setupBody = source.slice(setupBodyStart, setupBodyEnd);
assert(
  setupBody.includes('this.setAutoFloatingWindowWhenHomeEnabled(options.enableAutoFloatingWindowWhenHome ?? false);'),
  'setup should still propagate enableAutoFloatingWindowWhenHome to the iOS bridge'
);

const connectedHandlerStart = source.indexOf('this.callEngine.on("onCallConnected"');
assert.notStrictEqual(connectedHandlerStart, -1, 'UTS onCallConnected handler should exist');
const connectedHandlerEnd = source.indexOf('this.callEngine.on("onCallTypeChange"', connectedHandlerStart);
assert.notStrictEqual(connectedHandlerEnd, -1, 'UTS onCallConnected handler should be bounded');
const connectedHandler = source.slice(connectedHandlerStart, connectedHandlerEnd);
assert(
  connectedHandler.includes('this._isIOSPlatform()') &&
    connectedHandler.includes('Number(connectedCallInfo?.callStatus ?? 0) === 3') &&
    connectedHandler.includes('!this._isCallPageVisible()') &&
    connectedHandler.includes('this.recoverConnectedCallPageFromNative("onCallConnected", connectedCallInfo)'),
  'iOS LCK/system accept should recover the UTS call page from onCallConnected when appShow was too early'
);

const iosSource = fs.readFileSync(
  'uni-app/NECallKit-app-uts/uni_modules/Netease-Call/utssdk/app-ios/index.uts',
  'utf8'
);
assert(
  iosSource.includes('import { UIApplication } from "UIKit";') &&
    !iosSource.includes('UIApplicationState'),
  'iOS UTS bridge should import UIApplication to guard background floating window calls'
);

const iosSetupStart = iosSource.indexOf('public setup(param: InitParams)');
assert.notStrictEqual(iosSetupStart, -1, 'iOS UTS setup should exist');
const iosSetupEnd = iosSource.indexOf('  public login', iosSetupStart);
assert.notStrictEqual(iosSetupEnd, -1, 'iOS UTS setup body should be bounded');
const iosSetupBody = iosSource.slice(iosSetupStart, iosSetupEnd);
assert(
  iosSetupBody.includes('uiKitConfig.uiConfig.enableFloatingWindowOutOfApp = param.enableAutoFloatingWindowWhenHome ?? false') &&
    !iosSetupBody.includes('uiKitConfig.uiConfig.enableFloatingWindowOutOfApp = true'),
  'iOS UTS setup should preserve enableAutoFloatingWindowWhenHome as the native out-of-app floating-window config'
);

const iosAutoFloatStart = iosSource.indexOf('public setAutoFloatingWindowWhenHomeEnabled');
assert.notStrictEqual(iosAutoFloatStart, -1, 'iOS UTS setAutoFloatingWindowWhenHomeEnabled should exist');
const iosAutoFloatEnd = iosSource.indexOf('  /**\n   * 获取呼叫时的配置参数', iosAutoFloatStart);
assert.notStrictEqual(iosAutoFloatEnd, -1, 'iOS UTS setAutoFloatingWindowWhenHomeEnabled body should be bounded');
const iosAutoFloatBody = iosSource.slice(iosAutoFloatStart, iosAutoFloatEnd);
assert(
  iosAutoFloatBody.includes('setAutoFloatingWindowWhenHomeEnabled, enable: ${enable}') &&
    iosAutoFloatBody.includes('      enable,') &&
    !iosAutoFloatBody.includes('keep iOS system PiP enabled'),
  'iOS UTS setAutoFloatingWindowWhenHomeEnabled should pass the requested config value to native'
);

const iosStartFloatWindowStart = iosSource.indexOf('public startFloatWindow(options: CallbackOptions)');
assert.notStrictEqual(iosStartFloatWindowStart, -1, 'iOS UTS startFloatWindow should exist');
const iosStartFloatWindowEnd = iosSource.indexOf('  /**\n   * 关闭悬浮窗', iosStartFloatWindowStart);
assert.notStrictEqual(iosStartFloatWindowEnd, -1, 'iOS UTS startFloatWindow body should be bounded');
const iosStartFloatWindowBody = iosSource.slice(iosStartFloatWindowStart, iosStartFloatWindowEnd);
assert(
  iosStartFloatWindowBody.includes('UIApplication.shared.applicationState != UIApplication.State.active') &&
    iosStartFloatWindowBody.includes('options.fail?.(-1, "app is not active")') &&
    iosStartFloatWindowBody.indexOf('this.callBridge.startFloatWindow();') >
      iosStartFloatWindowBody.indexOf('UIApplication.shared.applicationState != UIApplication.State.active'),
  'iOS UTS startFloatWindow should reject inactive/background calls before native in-app window creation'
);

const recoverStart = source.indexOf('public recoverConnectedCallPageFromNative');
assert.notStrictEqual(recoverStart, -1, 'UTS recoverConnectedCallPageFromNative should exist');
const recoverEnd = source.indexOf('  private _syncConnectedCallStoreFromNativeInfo', recoverStart);
assert.notStrictEqual(recoverEnd, -1, 'UTS recoverConnectedCallPageFromNative body should be bounded');
const recoverBody = source.slice(recoverStart, recoverEnd);
assert(
  recoverBody.includes('const floatWindowActive = this._isFloatWindowActive();') &&
    recoverBody.includes('if (!floatWindowActive)') &&
    recoverBody.indexOf('this._navigateToCallPage();') > recoverBody.indexOf('if (!floatWindowActive)'),
  'iOS connected-call recovery should keep the current in-app floating window instead of forcing full call page'
);

const floatStateStart = source.indexOf('private _isFloatWindowActive(): boolean');
assert.notStrictEqual(floatStateStart, -1, 'UTS should have a floating-window active-state helper');
const floatStateEnd = source.indexOf('  private _syncConnectedCallStoreFromNativeInfo', floatStateStart);
assert.notStrictEqual(floatStateEnd, -1, 'UTS floating-window active-state helper should be bounded');
const floatStateBody = source.slice(floatStateStart, floatStateEnd);
assert(
  floatStateBody.includes('this.callEngine.isFloatWindowVisible?.()') &&
    floatStateBody.includes('typeof nativeFloatWindowVisible === "boolean"') &&
    floatStateBody.includes('return nativeFloatWindowVisible || storeFloatWindowActive;') &&
    floatStateBody.includes('return storeFloatWindowActive;'),
  'UTS floating-window active-state helper should keep store floating state when native visibility returns false'
);

console.log('UTS iOS home PiP static checks passed');
