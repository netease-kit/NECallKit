const fs = require('fs');
const assert = require('assert');

const serviceSource = fs.readFileSync(
  'uni-app/NECallKit-app-uts/uni_modules/Netease-Call/callkit/callServices/services/index.ts',
  'utf8'
);
const pageSource = fs.readFileSync(
  'uni-app/NECallKit-app-uts/uni_modules/Netease-Call/callkit/callPage.nvue',
  'utf8'
);
const iosBridgeSource = fs.readFileSync(
  'uni-app/NECallKit-app-uts/uni_modules/Netease-Call/utssdk/app-ios/index.uts',
  'utf8'
);
const uiConfigHeader = fs.readFileSync(
  'iOS/NERtcCallUIKit/NERtcCallUIKit/Classes/NECallUIKitConfig.h',
  'utf8'
);
const bannerSource = fs.readFileSync(
  'iOS/NERtcCallUIKit/NERtcCallUIKit/Classes/View/NEIncomingCallBannerWindow.m',
  'utf8'
);
const callViewSource = fs.readFileSync(
  'iOS/NERtcCallUIKit/NERtcCallUIKit/Classes/Controller/NECallViewController.m',
  'utf8'
);
const groupCallViewSource = fs.readFileSync(
  'iOS/NERtcCallUIKit/NERtcCallUIKit/Classes/GroupCall/NEGroupCallViewController.m',
  'utf8'
);

assert(
  serviceSource.includes('private _ringController: CallRingController = new CallRingController();'),
  'UTS CallService should own a single CallRingController'
);
assert(
  !serviceSource.includes('private _incomingRingAudioContext'),
  'UTS CallService should not keep a second incoming-ring audio context'
);
assert(
  serviceSource.includes('this._ringController.startIncomingRing();'),
  'UTS should start incoming ring from CallService for every platform, including iOS incoming banner'
);
assert(
  serviceSource.includes('this._ringController.startOutgoingRing();'),
  'UTS should start outgoing ring from CallService after outgoing call success'
);
assert(
  serviceSource.includes('this._ringController.stopLoopRing();'),
  'UTS should stop loop ring on accept/connect/end/not-connected paths'
);
assert(
  serviceSource.includes('this._ringController.reset();'),
  'UTS should reset ring state during call cleanup'
);

const cancelBannerStart = serviceSource.indexOf('public cancelIncomingBanner(): void');
assert.notStrictEqual(cancelBannerStart, -1, 'UTS cancelIncomingBanner should exist');
const cancelBannerEnd = serviceSource.indexOf('  public startService', cancelBannerStart);
assert.notStrictEqual(cancelBannerEnd, -1, 'UTS cancelIncomingBanner body should be bounded');
const cancelBannerBody = serviceSource.slice(cancelBannerStart, cancelBannerEnd);
assert(
  !cancelBannerBody.includes('stopLoopRing') && !cancelBannerBody.includes('reset()'),
  'UTS cancelIncomingBanner should only hide the banner; ring lifecycle is controlled by call state transitions'
);

[
  ['public accept(options?: AcceptParams)', 'accept should stop incoming loop ring before native accept'],
  ['public hangup(options?: HangupParams)', 'hangup should stop loop ring before native hangup'],
  ['private _hangupPermissionDeniedCall(): void', 'permission denied should stop loop ring before cleanup'],
].forEach(([marker, message]) => {
  const start = serviceSource.indexOf(marker);
  assert.notStrictEqual(start, -1, `${marker} should exist`);
  const body = serviceSource.slice(start, start + 420);
  assert(body.includes('this._ringController.stopLoopRing();'), message);
});

assert(
  !pageSource.includes('uni.createInnerAudioContext()') &&
    !pageSource.includes('shouldUseNativeIncomingBannerRing') &&
    !pageSource.includes('initAudio()'),
  'UTS call page should not create or own ringtone playback'
);

assert(
  uiConfigHeader.includes('@property(nonatomic, assign) BOOL enableNativeIncomingRing;'),
  'Native CallUIKit config should expose an incoming-ring ownership switch'
);
assert(
  iosBridgeSource.includes('uiKitConfig.uiConfig.enableNativeIncomingRing = false;'),
  'UTS iOS bridge should disable native incoming ringtone playback'
);

assert(
  bannerSource.includes('if ([[NERtcCallUIKit sharedInstance] isNativeIncomingRingEnabled])') &&
    bannerSource.includes('bannerRingStart'),
  'Native incoming banner should only play callee ring when native ring ownership is enabled'
);
assert(
  callViewSource.includes('self.config.enableNativeIncomingRing') &&
    callViewSource.includes('[self playRingWithType:CRTCalleeRing]'),
  'Native full-screen callee page should only play callee ring when native ring ownership is enabled'
);
assert(
  groupCallViewSource.includes('if ([[NERtcCallUIKit sharedInstance] isNativeIncomingRingEnabled])') &&
    groupCallViewSource.includes('[self playRingWithType:CRTCalleeRing]'),
  'Native group callee page should only play callee ring when native ring ownership is enabled'
);

const applyAfterPermissionStart = serviceSource.indexOf('private _applySwitchCallTypeAfterPermission');
assert.notStrictEqual(
  applyAfterPermissionStart,
  -1,
  'UTS CallService should keep passive switch call type permission handling'
);
const applyAfterPermissionEnd = serviceSource.indexOf('  private _setPendingSwitchCallType', applyAfterPermissionStart);
assert.notStrictEqual(
  applyAfterPermissionEnd,
  -1,
  'UTS passive switch call type permission handling should be bounded'
);
const applyAfterPermissionBody = serviceSource.slice(applyAfterPermissionStart, applyAfterPermissionEnd);
assert(
  applyAfterPermissionBody.includes('this._respondSwitchCallType(callType, SWITCH_CALL_STATE_REJECT);') &&
    applyAfterPermissionBody.includes('this._hangupPermissionDeniedCall();') &&
    applyAfterPermissionBody.includes('true') &&
    !applyAfterPermissionBody.includes('this._applySwitchCallType(callType, false);'),
  'UTS passive switch permission denial should reject, hang up, then show permission toast'
);

const hasPermissionStart = serviceSource.indexOf('private _hasPermission');
assert.notStrictEqual(hasPermissionStart, -1, 'UTS CallService should keep permission checking');
const hasPermissionEnd = serviceSource.indexOf('  private _hangupPermissionDeniedCall', hasPermissionStart);
assert.notStrictEqual(hasPermissionEnd, -1, 'UTS permission checking should be bounded');
const hasPermissionBody = serviceSource.slice(hasPermissionStart, hasPermissionEnd);
assert(
  hasPermissionBody.includes('showFailToastAfterCallback: boolean = false') &&
    hasPermissionBody.includes('if (showFailToastAfterCallback)') &&
    hasPermissionBody.includes('fail();') &&
    hasPermissionBody.includes('setTimeout(() =>') &&
    hasPermissionBody.includes('showPermissionTip();'),
  'UTS permission denial should support showing toast after callback cleanup'
);

assert(
  serviceSource.includes('const SWITCH_CALL_TYPE_INVITE_TIMEOUT = 5000;') &&
    serviceSource.includes('private _switchCallTypeInviteTimeoutTimerId: number = -1;'),
  'UTS active switch call type should define a local invite timeout'
);

[
  ['public switchVideoToAudio(): void', 'switch video to audio should reject repeated requests'],
  ['public switchAudioToVideo(): void', 'switch audio to video should reject repeated requests'],
].forEach(([marker, message]) => {
  const start = serviceSource.indexOf(marker);
  assert.notStrictEqual(start, -1, `${marker} should exist`);
  const body = serviceSource.slice(start, start + 760);
  assert(
    body.includes('if (this._pendingSwitchCallType !== null)') &&
      body.includes('title: "正在切换，请勿重复操作"'),
    message
  );
});

const setPendingSwitchStart = serviceSource.indexOf('private _setPendingSwitchCallType');
assert.notStrictEqual(setPendingSwitchStart, -1, 'UTS pending switch setter should exist');
const setPendingSwitchEnd = serviceSource.indexOf('  private _clearPendingSwitchCallType', setPendingSwitchStart);
assert.notStrictEqual(setPendingSwitchEnd, -1, 'UTS pending switch setter should be bounded');
const setPendingSwitchBody = serviceSource.slice(setPendingSwitchStart, setPendingSwitchEnd);
assert(
  setPendingSwitchBody.includes('this._startSwitchCallTypeInviteTimeout(callType, this._switchCallTypeInviteRevision);'),
  'UTS active switch call type should start timeout after entering pending state'
);

const clearPendingSwitchStart = serviceSource.indexOf('private _clearPendingSwitchCallType');
assert.notStrictEqual(clearPendingSwitchStart, -1, 'UTS pending switch clearer should exist');
const clearPendingSwitchEnd = serviceSource.indexOf('  private _startSwitchCallTypeInviteTimeout', clearPendingSwitchStart);
assert.notStrictEqual(clearPendingSwitchEnd, -1, 'UTS pending switch clearer should be bounded');
const clearPendingSwitchBody = serviceSource.slice(clearPendingSwitchStart, clearPendingSwitchEnd);
assert(
  clearPendingSwitchBody.includes('this._clearSwitchCallTypeInviteTimeout();'),
  'UTS clearing pending switch call type should also clear the timeout'
);

const switchTimeoutStart = serviceSource.indexOf('private _startSwitchCallTypeInviteTimeout');
assert.notStrictEqual(switchTimeoutStart, -1, 'UTS switch invite timeout starter should exist');
const switchTimeoutEnd = serviceSource.indexOf('  private _clearSwitchCallTypeInviteTimeout', switchTimeoutStart);
assert.notStrictEqual(switchTimeoutEnd, -1, 'UTS switch invite timeout starter should be bounded');
const switchTimeoutBody = serviceSource.slice(switchTimeoutStart, switchTimeoutEnd);
assert(
  switchTimeoutBody.includes('Timer.run(') &&
    switchTimeoutBody.includes('count: 1') &&
    switchTimeoutBody.includes('this._restoreSwitchCallTypeConfirmConfig();') &&
    switchTimeoutBody.includes('this._clearPendingSwitchCallType(callType);') &&
    switchTimeoutBody.includes('title: "切换超时"'),
  'UTS switch invite timeout should be one-shot and recover pending state'
);

console.log('UTS iOS ring ownership static checks passed');
