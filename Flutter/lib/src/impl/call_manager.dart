// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_callkit/netease_callkit.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/ui/call_navigator_observer.dart';
import 'package:netease_callkit_ui/src/utils/nim_utils.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';
import 'package:netease_callkit_ui/src/utils/preference.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';
import 'package:nim_core_v2/nim_core.dart';

class CallManager {
  static const String _tag = 'CallManager';
  static final CallManager _instance = CallManager();

  static CallManager get instance => _instance;
  final _im = NimCore.instance;

  // 保存 appKey
  String? _appKey;

  // 保存额外配置
  NEExtraConfig? _extraConfig;

  // 获取 appKey
  String? get appKey => _appKey;

  // 获取额外配置
  NEExtraConfig? get extraConfig => _extraConfig;

  CallManager() {
    NEEventNotify().register(setStateEventOnCallReceived, (arg) async {
      if ((Platform.isAndroid &&
              await NECallKitPlatform.instance.isAppInForeground()) ||
          Platform.isIOS) {
        NECallKitNavigatorObserver.getInstance().enterCallingPage();
        var permissionResult =
            await Permission.request(CallState.instance.callType);
        if (PermissionResult.granted == permissionResult) {
        } else {
          CallManager.instance.reject();
          CallingBellFeature.stopRing();
        }
      } else {
        NECallKitNavigatorObserver.getInstance().enterCallingPage();
      }
    });
  }

  Future<void> setupEngine(String appKey, String accountId,
      {NEExtraConfig? extraConfig}) async {
    CallKitUILog.i(_tag,
        'CallManager setupEngine(appKey:$appKey, accountId: $accountId, extraConfig: $extraConfig)');
    CallState.instance.unRegisterEngineObserver();
    CallState.instance.registerEngineObserver();
    CallState.instance.selfUser.id = accountId;
    // 获取 lckConfig，如果没有则使用默认配置（默认关闭）
    NELCKConfig? lckConfig = extraConfig?.lckConfig ??
        NELCKConfig(enableLiveCommunicationKit: false);

    NESetupConfig config = NESetupConfig(
      appKey: appKey,
      enableJoinRtcWhenCall: false,
      initRtcMode: NECallInitRtcMode.global,
      lckConfig: lckConfig, // 传递 lckConfig 到 NESetupConfig
    );
    final result = await NECallEngine.instance.setup(config);

    if (result.code == 0) {
      CallKitUILog.i(_tag,
          'CallManager initEngine success with lckConfig: enable=${lckConfig.enableLiveCommunicationKit}, ringtone=${lckConfig.ringtoneName}');
    } else {
      CallManager.instance.showToast(NECallKitUI.localizations.initEngineFail);
    }
  }

  void releaseEngine() {
    CallKitUILog.i(_tag, 'CallManager releaseEngine');
    CallState.instance.unRegisterEngineObserver();
  }

  Future<NEResult> call(String accountId, NECallType callMediaType,
      [NECallParams? params]) async {
    CallKitUILog.i(_tag,
        'CallManager call(userId:$accountId, callMediaType: $callMediaType, params:${params.toString()}), version:${Constants.pluginVersion}');
    if (accountId.isEmpty) {
      debugPrint("Call failed, userId is empty");
      return NEResult(
          code: -1, message: NECallKitUI.localizations.callFailedUserIdEmpty);
    }

    // 使用 NECallParams 中的 pushConfig
    NECallPushConfig? pushConfig = params?.pushConfig;
    final permissionResult = await Permission.request(callMediaType);
    if (PermissionResult.granted == permissionResult) {
      final callResult = await NECallEngine.instance
          .call(accountId, callMediaType, pushConfig: pushConfig);
      if (callResult.code == 0) {
        User user = User();
        user.id = accountId;
        user.callRole = NECallRole.called;
        user.callStatus = NECallStatus.waiting;

        CallState.instance.remoteUserList.add(user);
        _getUserInfo();
        CallState.instance.callType = callMediaType;
        CallState.instance.scene = NECallScene.singleCall;
        CallState.instance.selfUser.callRole = NECallRole.caller;
        CallState.instance.selfUser.callStatus = NECallStatus.waiting;
        CallingBellFeature.startRing();
        launchCallingPage();
        CallManager.instance.enableWakeLock(true);
      } else if (callResult.code == NECallError.stateCallCalling ||
          callResult.code == NECallError.stateCallOnTheCall) {
        CallManager.instance.showToast(NECallKitUI.localizations.userInCall);
      } else {
        CallKitUILog.i(_tag,
            "callResult.code: ${callResult.code}, callResult.msg: ${callResult.msg}");
      }
      CallKitUILog.i(_tag,
          "callResult.code: ${callResult.code}, callResult.msg: ${callResult.msg}");
      return NEResult(code: callResult.code, message: callResult.msg);
    } else {
      CallKitUILog.i(_tag, "Permission result fail");
      return NEResult(
          code: -1, message: NECallKitUI.localizations.permissionResultFail);
    }
  }

  Future<NEResult> accept() async {
    final result = await NECallEngine.instance.accept();
    CallKitUILog.i(_tag, "accept result = $result");
    if (result.code == 0) {
      CallState.instance.selfUser.callStatus = NECallStatus.accept;
    } else {
      CallState.instance.selfUser.callStatus = NECallStatus.none;
    }
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> reject() async {
    final result = await NECallEngine.instance.hangup("");
    CallKitUILog.i(_tag, "reject result = $result");
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> switchCallMediaType(
      NECallType mediaType, NECallSwitchState state) async {
    CallKitUILog.i(_tag, "switchCallMediaType mediaType = $mediaType");
    NECallEngine.instance.switchCallType(mediaType, state);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<NEResult> hangup() async {
    final result = await NECallEngine.instance.hangup("");
    CallKitUILog.i(_tag, "hangup result = $result");
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    NECallKitPlatform.instance.updateCallStateToNative();
    CallState.instance.cleanState();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> openCamera(NECamera camera, int viewId) async {
    CallKitUILog.i(_tag, "openCamera camera = $camera");
    NEResult result = NEResult(code: 0, message: 'success');
    if (Platform.isAndroid) {
      CallKitUILog.i(_tag, 'CallManager openCamera');
      PermissionResult permissionResult = PermissionResult.granted;
      if (await Permission.has(permissions: [PermissionType.camera])) {
        permissionResult = await Permission.request(NECallType.video);
      }
      if (PermissionResult.granted == permissionResult) {
        var ret = await NECallEngine.instance.enableLocalVideo(true);
        result = NEResult(code: ret.code, message: ret.msg);
      } else {
        result = NEResult(
            code: -1,
            message: NECallKitUI.localizations.startCameraPermissionDenied);
      }
    } else {
      var ret = await NECallEngine.instance.enableLocalVideo(true);
      result = NEResult(code: ret.code, message: ret.msg);
    }

    if (result.code == 0 &&
        NECallStatus.none != CallState.instance.selfUser.callStatus) {
      CallState.instance.isCameraOpen = true;
      CallState.instance.camera = camera;
      CallState.instance.selfUser.videoAvailable = true;
    }
    NECallKitPlatform.instance.updateCallStateToNative();
    return result;
  }

  Future<void> closeCamera() async {
    CallKitUILog.i(_tag, 'CallManager closeCamera');
    NECallEngine.instance.enableLocalVideo(false);
    CallState.instance.isCameraOpen = false;
    CallState.instance.selfUser.videoAvailable = false;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> switchCamera(NECamera camera) async {
    CallKitUILog.i(_tag, 'switchCamera camera = $camera');
    NECallEngine.instance.switchCamera();
    CallState.instance.camera = camera;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<NEResult> openMicrophone([bool notify = true]) async {
    CallKitUILog.i(_tag, 'openMicrophone notify = $notify');
    final result = await NECallEngine.instance.muteLocalAudio(false);
    CallState.instance.isMicrophoneMute = false;
    NECallKitPlatform.instance.updateCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> closeMicrophone([bool notify = true]) async {
    CallKitUILog.i(_tag, 'closeMicrophone notify = $notify');
    NECallEngine.instance.muteLocalAudio(true);
    CallState.instance.isMicrophoneMute = true;
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setSpeakerphoneOn(bool enable) async {
    CallKitUILog.i(_tag, 'setSpeakerphoneOn enable = $enable');
    NECallEngine.instance.setSpeakerphoneOn(enable);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setupLocalView(int viewId) async {
    CallKitUILog.i(_tag, 'CallManager setupLocalView(viewId:$viewId)');
    await NECallEngine.instance.setupLocalView(viewId);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> setupRemoteView(String userId, int viewId) async {
    CallKitUILog.i(
        _tag, 'CallManager setupRemoteView(userId:$userId, viewId:$viewId)');
    await NECallEngine.instance.setupRemoteView(viewId);
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> stopRemoteView(String userId) async {
    // await NECallEngine.instance.setupRemoteView(userId);
  }

  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    // final result = await NECallEngine.instance.setSelfInfo(nickname, avatar);
    return NEResult(code: 0, message: "");
  }

  Future<NEResult> login(String appKey, String accountId, String token,
      {NECertificateConfig? certificateConfig,
      NEExtraConfig? extraConfig}) async {
    CallKitUILog.i(_tag,
        'CallManager login(appKey:$appKey, accountId:$accountId, certificateConfig:$certificateConfig, extraConfig:$extraConfig) version:${Constants.pluginVersion}');

    // 保存 appKey 和 extraConfig
    _appKey = appKey;
    _extraConfig = extraConfig ?? NEExtraConfig(); // 默认生成一个配置
    CallKitUILog.i(_tag,
        'CallManager login: appKey saved = $_appKey, extraConfig = $_extraConfig');

    late NIMSDKOptions options;
    if (Platform.isAndroid) {
      options = NIMAndroidSDKOptions(
        appKey: appKey,
      );
      //若需要使用云端会话，请提前开启云端会话
      //enableV2CloudConversation: true,
    } else if (Platform.isIOS) {
      options = NIMIOSSDKOptions(
        appKey: appKey,
        //若需要使用云端会话，请提前开启云端会话
        //enableV2CloudConversation: true,
        apnsCername: certificateConfig?.apnsCername,
        pkCername: certificateConfig?.pkCername,
      );
    }
    var initRet = await NimCore.instance.initialize(options);
    if (initRet.code == 0) {
      NEEventNotify().notify(imSDKInitSuccessEvent, {});
    }
    NEResult result = NEResult(code: 0, message: 'success');
    var imRet = await NimCore.instance.loginService.login(
      accountId,
      token,
      NIMLoginOption(),
    );
    if (imRet.code == 0) {
      NEEventNotify()
          .notify(loginSuccessEvent, {'accountId': accountId, 'token': token});
    }
    result = NEResult(code: imRet.code, message: imRet.errorDetails);
    return result;
  }

  Future<void> logout() async {
    CallKitUILog.i(_tag, 'CallManager logout()');
    NEEventNotify().notify(logoutSuccessEvent, {});
    await _im.loginService.logout();
  }

  Future<void> setCallingBell(String assetName) async {
    String filePath = await CallingBellFeature.getAssetsFilePath(assetName);
    PreferenceUtils.getInstance()
        .saveString(CallingBellFeature.keyRingPath, filePath);
  }

  Future<void> enableFloatWindow(bool enable) async {
    CallState.instance.enableFloatWindow = enable;
  }

  /// 启用/禁用应用外悬浮窗（画中画）
  /// 前提：需要先调用 enableFloatWindow(true)
  Future<void> enableFloatWindowOutOfApp(bool enable) async {
    CallKitUILog.i(_tag, 'CallManager enableFloatWindowOutOfApp($enable)');
    CallState.instance.enableFloatWindowOutOfApp = enable;
  }

  Future<void> enableVirtualBackground(bool enable) async {
    CallState.instance.showVirtualBackgroundButton = enable;
  }

  Future<void> setBlurBackground(bool enable) async {
    CallState.instance.enableBlurBackground = enable;
  }

  void initAudioPlayDeviceAndCamera() {
    if (NECallType.audio == CallState.instance.callType) {
      CallState.instance.isEnableSpeaker = false;
      CallState.instance.isCameraOpen = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = true;
    }

    CallManager.instance.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
  }

  void handleLoginSuccess(String accountId, String token) {
    CallKitUILog.i(_tag, 'CallManager handleLoginSuccess()');
    CallKitUILog.i(_tag,
        'CallManager handleLoginSuccess: appKey = $_appKey, accountId = $accountId');
    CallManager.instance
        .setupEngine(_appKey!, accountId, extraConfig: _extraConfig);
  }

  void handleLogoutSuccess() {
    CallKitUILog.i(_tag, 'CallManager handleLogoutSuccess()');
    NECallEngine.instance.destroy();
    CallingBellFeature.stopRing();
    CallState.instance.cleanState();
    CallState.instance.unRegisterEngineObserver();
    NECallKitPlatform.instance.updateCallStateToNative();
  }

  void handleAppEnterForeground() async {
    CallKitUILog.i(
        _tag,
        'CallManager handleAppEnterForeground() '
        'callStatus = ${CallState.instance.selfUser.callStatus},'
        'currentPage = ${NECallKitNavigatorObserver.currentPage},'
        'isOpenFloatWindow = ${CallState.instance.isOpenFloatWindow},'
        'isInNativeIncomingBanner = ${CallState.instance.isInNativeIncomingBanner},'
        'isScreenLocked = ${await CallManager.instance.isScreenLocked()}');

    // 如果启用了应用外悬浮窗，且在通话中，则停止画中画
    if (Platform.isIOS &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.isIOSOpenFloatWindowOutOfApp &&
        CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus != NECallStatus.none) {
      await NECallKitPlatform.instance.disposePIP();
      if (!CallState.instance.isOpenFloatWindow) {
        backCallingPageFormFloatWindow();
      } else {
        NECallKitPlatform.instance.startFloatWindow();
        CallState.instance.isIOSOpenFloatWindowOutOfApp = false;
      }
      // 重新设置画中画
      NECallKitPlatform.instance.setupPIP();
    }

    if (CallState.instance.selfUser.callStatus != NECallStatus.none &&
        NECallKitNavigatorObserver.currentPage == CallPage.none &&
        CallState.instance.isOpenFloatWindow == false &&
        CallState.instance.isInNativeIncomingBanner == false &&
        !(await CallManager.instance.isScreenLocked())) {
      launchCallingPage();
    }
  }

  void handleAppEnterBackground() async {
    CallKitUILog.i(
        _tag,
        'CallManager handleAppEnterBackground() '
        'callStatus = ${CallState.instance.selfUser.callStatus},'
        'currentPage = ${NECallKitNavigatorObserver.currentPage},'
        'isOpenFloatWindow = ${CallState.instance.isOpenFloatWindow},'
        'isIOSOpenFloatWindowOutOfApp = ${CallState.instance.isIOSOpenFloatWindowOutOfApp}');

    // 如果启用了应用外悬浮窗，且在通话中，则启动画中画
    if (Platform.isAndroid &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      openFloatWindowWithPageState();
    }
    // 进入后台启动画中画
    if (Platform.isIOS &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      final success = await NECallKitPlatform.instance.startPIP();
      CallState.instance.isIOSOpenFloatWindowOutOfApp = success;
      CallKitUILog.i(_tag,
          'CallManager handleAppEnterBackground: startPIP result = $success');
    }
  }

  Future<void> openFloatWindowWithPageState() async {
    CallKitUILog.i(_tag, 'CallManager openFloatWindowWithState()');
    if ((Platform.isAndroid &&
            await NECallKitPlatform.instance.hasFloatPermission()) ||
        Platform.isIOS) {
      openFloatWindow();
      if (NECallKitNavigatorObserver.currentPage == CallPage.callingPage) {
        NECallKitNavigatorObserver.getInstance().exitCallingPage();
      }
    }
  }

  void launchCallingPage() {
    CallKitUILog.i(_tag, 'CallManager launchCallWidget()');
    _checkLocalSelfUserInfo();
    CallManager.instance.initAudioPlayDeviceAndCamera();
    NEEventNotify().notify(setStateEventOnCallReceived);
    NECallKitPlatform.instance.updateCallStateToNative();
    CallState.instance.isOpenFloatWindow = false;
  }

  void openFloatWindow() {
    NECallKitPlatform.instance.startFloatWindow();
    CallState.instance.isOpenFloatWindow = true;
    NECallKitNavigatorObserver.isClose = true;
  }

  Future<void> requestFloatPermission() async {
    await NECallKitPlatform.instance.requestFloatPermission();
  }

  void backCallingPageFormFloatWindow() {
    CallKitUILog.i(_tag,
        'backCallingPageFormFloatWindow: currentPage = ${NECallKitNavigatorObserver.currentPage}, isClose = ${NECallKitNavigatorObserver.isClose}');

    // 如果当前已经有通话页面，不需要再次 push，只需要刷新状态即可
    if (NECallKitNavigatorObserver.currentPage == CallPage.callingPage &&
        Platform.isIOS) {
      CallKitUILog.i(_tag,
          'backCallingPageFormFloatWindow: Already in calling page, just update state');
      CallState.instance.isOpenFloatWindow = false;

      // 通知刷新视频 view
      NEEventNotify().notify('refreshVideoViews');
    } else {
      // 如果不在通话页面，则进入通话页面
      CallKitUILog.i(
          _tag, 'backCallingPageFormFloatWindow: Entering calling page');
      NECallKitNavigatorObserver.getInstance().enterCallingPage();
      CallState.instance.isOpenFloatWindow = false;
    }
  }

  void showToast(String string) {
    Fluttertoast.showToast(msg: string);
  }

  void enableIncomingBanner(bool enable) {
    CallState.instance.enableIncomingBanner = enable;
  }

  Future<void> enableWakeLock(bool enable) async {
    CallKitUILog.i(_tag, 'CallManager enableWakeLock($enable)');
    await NECallKitPlatform.instance.enableWakeLock(enable);
  }

  void showIncomingBanner() {
    CallKitUILog.i(_tag, 'CallManager showIncomingBanner');
    NECallKitPlatform.instance.showIncomingBanner();
  }

  void pullBackgroundApp() {
    CallKitUILog.i(_tag, 'CallManager pullBackgroundApp');
    NECallKitPlatform.instance.pullBackgroundApp();
  }

  void openLockScreenApp() {
    CallKitUILog.i(_tag, 'CallManager openLockScreenApp');
    NECallKitPlatform.instance.openLockScreenApp();
  }

  void startForegroundService() {
    if (!CallState.instance.isStartForegroundService) {
      CallKitUILog.i(_tag, 'CallManager startForegroundService');
      NECallKitPlatform.instance
          .startForegroundService(CallState.instance.callType);
      CallState.instance.isStartForegroundService = true;
    }
  }

  void stopForegroundService() {
    if (CallState.instance.isStartForegroundService) {
      CallKitUILog.i(_tag, 'CallManager stopForegroundService');
      NECallKitPlatform.instance.stopForegroundService();
      CallState.instance.isStartForegroundService = false;
    }
  }

  Future<bool> isScreenLocked() async {
    return await NECallKitPlatform.instance.isScreenLocked();
  }

  Future<bool> isSamsungDevice() async {
    return await NECallKitPlatform.instance.isSamsungDevice();
  }

  _checkLocalSelfUserInfo() async {
    if (CallState.instance.selfUser.nickname == '' &&
        (CallState.instance.selfUser.avatar == Constants.defaultAvatar ||
            CallState.instance.selfUser.avatar.isEmpty)) {
      final userInfo =
          await NimUtils.getUserInfo(CallState.instance.selfUser.id);
      CallState.instance.selfUser.nickname =
          StringStream.makeNull(userInfo.nickname, '');
      CallState.instance.selfUser.avatar =
          StringStream.makeNull(userInfo.avatar, Constants.defaultAvatar);
    }
  }

  _getUserInfo() async {
    final copyList = List<User>.from(CallState.instance.remoteUserList);
    for (User user in copyList) {
      final userInfo = await NimUtils.getUserInfo(user.id);
      user.nickname = StringStream.makeNull(userInfo.nickname, '');
      user.avatar =
          StringStream.makeNull(userInfo.avatar, Constants.defaultAvatar);
    }
    NEEventNotify().notify(setStateEvent);
  }
}
