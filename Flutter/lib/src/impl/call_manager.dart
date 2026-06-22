// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/desktop/desktop_ui_reuse_adapter.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/extensions/calling_bell_feature.dart';
import 'package:netease_callkit_ui/src/group_call/group_call_manager.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_runtime_adapter.dart';
import 'package:netease_callkit_ui/src/platform/platform_compat.dart';
import 'package:netease_callkit_ui/src/utils/nim_utils.dart';
import 'package:netease_callkit_ui/src/utils/permission.dart';
import 'package:netease_callkit_ui/src/utils/preference.dart';
import 'package:netease_callkit_ui/src/utils/string_stream.dart';
import 'package:netease_callkit_ui/src/utils/toast_utils.dart';
import 'package:nim_core_v2/nim_core.dart';
import 'package:path_provider/path_provider.dart';

class CallManager {
  static const String _tag = 'CallManager';
  static const String _launchContextCallIdKey = 'callId';
  static const String _launchContextCallRoleKey = 'callRole';
  static final CallManager _instance = CallManager();

  static CallManager get instance => _instance;
  final _im = NimCore.instance;
  static const DesktopUiReuseAdapter _desktopUiReuseAdapter =
      DesktopUiReuseAdapter();
  static const CallKitRuntimeAdapter _runtimeAdapter = CallKitRuntimeAdapter();
  bool get _isDesktopRuntime => Platform.isMacOS || Platform.isWindows;
  String? _pendingDesktopVideoCaptureDeviceId;
  String? _pendingDesktopAudioRecordingDeviceId;
  String? _pendingDesktopAudioPlaybackDeviceId;

  // 保存 appKey
  String? _appKey;

  // 保存额外配置
  NEExtraConfig? _extraConfig;

  // 保存群呼配置参数
  NEGroupConfigParam? _groupConfigParam;

  // 来电横幅模式开关
  bool _enableIncomingBanner = false;

  // 横幅是否正在显示（用于并发来电检查）
  bool _bannerIsActive = false;

  // 获取 appKey
  String? get appKey => _appKey;

  // 获取额外配置
  NEExtraConfig? get extraConfig => _extraConfig;

  // 获取群呼配置参数
  NEGroupConfigParam? get groupConfigParam => _groupConfigParam;

  Future<String> _resolveDesktopNimSdkRootDir() async {
    late final String sdkRootDir;
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        sdkRootDir = '$home/Library/Application Support/NIM';
      } else {
        final appSupportDirectory = await getApplicationSupportDirectory();
        sdkRootDir = '${appSupportDirectory.path}/NIM';
      }
    } else {
      final localAppData = Platform.environment['LOCALAPPDATA'];
      if (localAppData != null && localAppData.isNotEmpty) {
        sdkRootDir = '$localAppData\\NIM';
      } else {
        final userProfile = Platform.environment['USERPROFILE'];
        if (userProfile != null && userProfile.isNotEmpty) {
          sdkRootDir = '$userProfile\\AppData\\Local\\NIM';
        } else {
          final appSupportDirectory = await getApplicationSupportDirectory();
          sdkRootDir = '${appSupportDirectory.path}\\NIM';
        }
      }
    }
    try {
      await Directory(sdkRootDir).create(recursive: true);
    } catch (error) {
      CallKitUILog.e(
        _tag,
        'CallManager _resolveDesktopNimSdkRootDir create failed: $error, path=$sdkRootDir',
      );
    }
    return sdkRootDir;
  }

  void _syncCallStateToNative() {
    if (_desktopUiReuseAdapter.shouldSyncCallStateToNative()) {
      NECallKitPlatform.instance.updateCallStateToNative();
    }
  }

  Map<String, dynamic> _buildCallingPageLaunchContext() {
    return <String, dynamic>{
      _launchContextCallIdKey: CallState.instance.currentCallId,
      _launchContextCallRoleKey: CallState.instance.selfUser.callRole.index,
    };
  }

  static NECallRole? _callRoleFromIndex(Object? rawValue) {
    if (rawValue is! int ||
        rawValue < 0 ||
        rawValue >= NECallRole.values.length) {
      return null;
    }
    return NECallRole.values[rawValue];
  }

  static bool shouldPreflightIncomingPermissions({
    required bool isAndroid,
    required bool isIOS,
    bool isOhos = false,
    required bool isDesktopRuntime,
    required bool isAppInForeground,
  }) {
    return isDesktopRuntime ||
        isIOS ||
        (isAndroid && isAppInForeground) ||
        (isOhos && isAppInForeground);
  }

  @visibleForTesting
  static bool shouldContinueDesktopSingleCallFlow({
    required bool isDesktopUiReuseEnabled,
    required NECallScene scene,
    required NECallRole callRole,
    required NECallStatus callStatus,
    String currentCallId = '',
    String? expectedCallId,
    NECallRole? expectedCallRole,
  }) {
    if (!isDesktopUiReuseEnabled) {
      return true;
    }
    if (scene != NECallScene.singleCall ||
        callRole == NECallRole.none ||
        callStatus == NECallStatus.none) {
      return false;
    }
    if (expectedCallId != null &&
        expectedCallId.isNotEmpty &&
        currentCallId.isNotEmpty &&
        currentCallId != expectedCallId) {
      return false;
    }
    if ((expectedCallId == null || expectedCallId.isEmpty) &&
        expectedCallRole != null &&
        callRole != expectedCallRole) {
      return false;
    }
    return true;
  }

  @visibleForTesting
  static bool shouldApplyDesktopVideoCaptureDeviceImmediately({
    required bool isDesktopRuntime,
    required bool isCameraOpen,
  }) {
    return !isDesktopRuntime || isCameraOpen;
  }

  @visibleForTesting
  static bool shouldApplyDesktopAudioRecordingDeviceImmediately({
    required bool isDesktopRuntime,
    required bool isMicrophoneMute,
  }) {
    return !isDesktopRuntime || !isMicrophoneMute;
  }

  @visibleForTesting
  static bool shouldApplyDesktopAudioPlaybackDeviceImmediately({
    required bool isDesktopRuntime,
    required bool isEnableSpeaker,
  }) {
    return !isDesktopRuntime || isEnableSpeaker;
  }

  @visibleForTesting
  static String? resolveDesktopSelectedDeviceId({
    String? pendingDeviceId,
    String? engineDeviceId,
  }) {
    if (pendingDeviceId != null && pendingDeviceId.isNotEmpty) {
      return pendingDeviceId;
    }
    return engineDeviceId;
  }

  @visibleForTesting
  static bool resolveSpeakerphoneEnabledState({
    required bool isDesktopRuntime,
    required bool requestedEnabled,
    bool? actualEnabled,
  }) {
    if (isDesktopRuntime && actualEnabled != null) {
      return actualEnabled;
    }
    return requestedEnabled;
  }

  @visibleForTesting
  static Future<void> applySingleCallAcceptSuccess({
    required CallKitRuntimeAdapter runtimeAdapter,
    required CallState callState,
    required VoidCallback syncCallStateToNative,
    NECallInfo? callInfo,
  }) async {
    final callId = callInfo?.callId;
    if (callId != null && callId.isNotEmpty) {
      callState.currentCallId = callId;
    }
    // 被叫本端接听成功后即应停铃，不能依赖远端连通事件兜底。
    await runtimeAdapter.stopRing();
    callState.selfUser.callStatus = NECallStatus.accept;
    syncCallStateToNative();
  }

  Future<void> _applyPendingDesktopVideoCaptureDeviceIfNeeded() async {
    if (!shouldApplyDesktopVideoCaptureDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isCameraOpen: CallState.instance.isCameraOpen,
    )) {
      return;
    }
    final pendingDeviceId = _pendingDesktopVideoCaptureDeviceId;
    if (pendingDeviceId == null || pendingDeviceId.isEmpty) {
      return;
    }
    final result = await NECallEngine.instance.setVideoCaptureDevice(
      pendingDeviceId,
    );
    if (result.code == 0) {
      _pendingDesktopVideoCaptureDeviceId = null;
      return;
    }
    CallKitUILog.i(
      _tag,
      'applyPendingDesktopVideoCaptureDevice failed '
      'deviceId = $pendingDeviceId, code = ${result.code}, msg = ${result.msg}',
    );
  }

  Future<void> _applyPendingDesktopAudioRecordingDeviceIfNeeded() async {
    if (!shouldApplyDesktopAudioRecordingDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isMicrophoneMute: CallState.instance.isMicrophoneMute,
    )) {
      return;
    }
    final pendingDeviceId = _pendingDesktopAudioRecordingDeviceId;
    if (pendingDeviceId == null || pendingDeviceId.isEmpty) {
      return;
    }
    final result = await NECallEngine.instance.setAudioRecordingDevice(
      pendingDeviceId,
    );
    if (result.code == 0) {
      _pendingDesktopAudioRecordingDeviceId = null;
      return;
    }
    CallKitUILog.i(
      _tag,
      'applyPendingDesktopAudioRecordingDevice failed '
      'deviceId = $pendingDeviceId, code = ${result.code}, msg = ${result.msg}',
    );
  }

  Future<void> _applyPendingDesktopAudioPlaybackDeviceIfNeeded() async {
    if (!shouldApplyDesktopAudioPlaybackDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isEnableSpeaker: CallState.instance.isEnableSpeaker,
    )) {
      return;
    }
    final pendingDeviceId = _pendingDesktopAudioPlaybackDeviceId;
    if (pendingDeviceId == null || pendingDeviceId.isEmpty) {
      return;
    }
    final result = await NECallEngine.instance.setAudioPlaybackDevice(
      pendingDeviceId,
    );
    if (result.code == 0) {
      _pendingDesktopAudioPlaybackDeviceId = null;
      return;
    }
    CallKitUILog.i(
      _tag,
      'applyPendingDesktopAudioPlaybackDevice failed '
      'deviceId = $pendingDeviceId, code = ${result.code}, msg = ${result.msg}',
    );
  }

  bool _shouldContinueDesktopSingleCallUiFlow({
    required String reason,
    Map<String, dynamic>? launchContext,
  }) {
    final state = CallState.instance;
    final expectedCallId = launchContext?[_launchContextCallIdKey] as String?;
    final expectedCallRole =
        _callRoleFromIndex(launchContext?[_launchContextCallRoleKey]);
    final shouldContinue = shouldContinueDesktopSingleCallFlow(
      isDesktopUiReuseEnabled:
          _desktopUiReuseAdapter.shouldReuseFlutterCallPages(),
      scene: state.scene,
      callRole: state.selfUser.callRole,
      callStatus: state.selfUser.callStatus,
      currentCallId: state.currentCallId,
      expectedCallId: expectedCallId,
      expectedCallRole: expectedCallRole,
    );
    if (!shouldContinue) {
      CallKitUILog.i(
        _tag,
        'skip desktopSingleCallUiFlow reason=$reason '
        'scene=${state.scene} callRole=${state.selfUser.callRole} '
        'callStatus=${state.selfUser.callStatus} '
        'currentCallId=${state.currentCallId} '
        'expectedCallId=${expectedCallId ?? ''} '
        'expectedCallRole=${expectedCallRole ?? 'null'}',
      );
    }
    return shouldContinue;
  }

  void _enterCallingPage(
    String reason, {
    Map<String, dynamic>? launchContext,
  }) {
    if (!_shouldContinueDesktopSingleCallUiFlow(
      reason: reason,
      launchContext: launchContext,
    )) {
      return;
    }
    final navigatorObserver = NECallKitNavigatorObserver.getInstance();
    final routeDecision = _desktopUiReuseAdapter.resolveCallingRouteDecision(
      hasNavigatorBinding: navigatorObserver.navigator != null,
      isCallingPageOpen:
          NECallKitNavigatorObserver.currentPage == CallPage.callingPage,
    );
    switch (routeDecision) {
      case DesktopCallingRouteDecision.pushFlutterPage:
        navigatorObserver.enterCallingPage();
        return;
      case DesktopCallingRouteDecision.waitForNavigatorBinding:
        CallKitUILog.i(
          _tag,
          'skip enterCallingPage reason=$reason navigatorObserverNotAttached',
        );
        return;
      case DesktopCallingRouteDecision.skipDuplicatePage:
        CallKitUILog.i(
          _tag,
          'skip enterCallingPage reason=$reason callingPageAlreadyOpen',
        );
        return;
    }
  }

  CallManager() {
    NEEventNotify().register(setStateEventOnCallReceived, (arg) async {
      final launchContext = arg is Map<String, dynamic> ? arg : null;
      final isAppInForeground = (Platform.isAndroid || PlatformCompat.isOhos)
          ? await NECallKitPlatform.instance.isAppInForeground()
          : false;
      if (shouldPreflightIncomingPermissions(
        isAndroid: Platform.isAndroid,
        isIOS: Platform.isIOS,
        isOhos: PlatformCompat.isOhos,
        isDesktopRuntime: _isDesktopRuntime,
        isAppInForeground: isAppInForeground,
      )) {
        if (_enableIncomingBanner &&
            CallState.instance.selfUser.callRole == NECallRole.called) {
          // 并发来电检查：若横幅已显示，说明已有一路来电，新来电回复忙线并丢弃
          if (_bannerIsActive) {
            CallKitUILog.i(_tag, 'secondCallIgnored replyBusy');
            await NECallEngine.instance.hangup();
            return;
          }
          CallKitUILog.i(_tag, 'showIncomingBanner enableIncomingBanner=true');
          _bannerIsActive = true;
          // 先同步来电方信息到 native，确保原生层有最新数据再展示横幅
          _syncCallStateToNative();
          await NECallKitPlatform.instance.setIncomingBannerEnabled(true);
          // Android/Ohos: 直接调用 showIncomingBanner() 触发横幅展示
          // iOS 层由 NEFlutterIncomingBannerHandler 响应并展示 NEIncomingCallBannerWindow
          if (Platform.isAndroid || PlatformCompat.isOhos) {
            await NECallKitPlatform.instance.showIncomingBanner();
          }

          // 注册 onCallEnd 监听：通话结束时自动取消横幅并重置活跃状态
          void onCallEndHandler(dynamic arg) {
            CallKitUILog.i(_tag, 'dismissIncomingBanner reason=callEnded');
            NECallKitPlatform.instance.cancelIncomingBanner();
            _bannerIsActive = false;
            NEEventNotify().unregister(
              setStateEventOnCallEnd,
              onCallEndHandler,
            );
          }

          NEEventNotify().register(setStateEventOnCallEnd, onCallEndHandler);

          return;
        }
        _enterCallingPage(
          'incoming_call_foreground',
          launchContext: launchContext,
        );
        // iOS 在来电进入页面后立即申请权限，权限不足则直接拒接。
        // Desktop 复用这条策略，避免权限关闭后仍停留在等待手动接听的状态。
        var permissionResult = await _runtimeAdapter.requestPermissions(
          CallState.instance.callType,
        );
        if (PermissionResult.granted == permissionResult) {
        } else {
          CallManager.instance.reject();
          _runtimeAdapter.stopRing();
        }
      } else {
        _enterCallingPage(
          'incoming_call_background',
          launchContext: launchContext,
        );
      }
    });
  }

  Future<void> setupEngine(
    String appKey,
    String accountId, {
    NEExtraConfig? extraConfig,
    NEGroupConfigParam? groupConfigParam,
  }) async {
    CallKitUILog.i(
      _tag,
      'CallManager setupEngine(appKey:$appKey, accountId: $accountId, extraConfig: $extraConfig, groupConfigParam: $groupConfigParam)',
    );

    // 保存群呼配置参数
    _groupConfigParam = groupConfigParam;

    CallState.instance.unRegisterEngineObserver();
    CallState.instance.registerEngineObserver();
    CallState.instance.selfUser.id = accountId;
    // 获取 lckConfig，如果没有则使用默认配置（默认关闭）
    NELCKConfig? lckConfig = extraConfig?.lckConfig ??
        NELCKConfig(enableLiveCommunicationKit: false);

    var config = NESetupConfig(
      appKey: appKey,
      currentAccountId: accountId,
      enableJoinRtcWhenCall: false,
      initRtcMode: NECallInitRtcMode.global,
      desktopVideoRenderMode:
          Platform.isMacOS ? NEDesktopVideoRenderMode.platformWindow : null,
      lckConfig: lckConfig, // 传递 lckConfig 到 NESetupConfig
    );
    final result = await NECallEngine.instance.setup(config);

    if (result.code == 0) {
      CallKitUILog.i(
        _tag,
        'CallManager initEngine success with lckConfig: enable=${lckConfig.enableLiveCommunicationKit}, ringtone=${lckConfig.ringtoneName}',
      );
      // 预加载铃声文件，避免首次播放时铃声被截断
      CallingBellFeature.preloadRingFiles();
    } else {
      CallManager.instance.showToast(NECallKitUI.localizations.initEngineFail);
    }
  }

  void destroyEngine() {
    CallKitUILog.i(_tag, 'CallManager destroyEngine');
    CallState.instance.unRegisterEngineObserver();
    NECallEngine.instance.destroy();
  }

  Future<NEResult> call(
    String accountId,
    NECallType callMediaType, [
    NECallParams? params,
  ]) async {
    CallKitUILog.i(
      _tag,
      'call accountId:$accountId, callMediaType: $callMediaType, params:${params.toString()}), version:${Constants.pluginVersion}',
    );
    if (accountId.isEmpty) {
      debugPrint('Call failed, userId is empty');
      return NEResult(
        code: NECallError.unKnow,
        message: NECallKitUI.localizations.callFailedUserIdEmpty,
      );
    }

    // 使用 NECallParams 中的 pushConfig
    var pushConfig = params?.pushConfig;
    final permissionResult = await _runtimeAdapter.requestPermissions(
      callMediaType,
    );
    if (PermissionResult.granted == permissionResult) {
      final callResult = await NECallEngine.instance.call(
        accountId,
        callMediaType,
        pushConfig: pushConfig,
      );
      CallKitUILog.i(
        _tag,
        'call result code: ${callResult.code} data: ${callResult.data?.toJson().toString()}',
      );
      if (callResult.code == 0) {
        if (callResult.data?.callId != null &&
            callResult.data!.callId.isNotEmpty) {
          CallState.instance.currentCallId = callResult.data!.callId;
        }
        var user = User();
        user.id = accountId;
        user.callRole = NECallRole.called;
        user.callStatus = NECallStatus.waiting;

        CallState.instance.remoteUserList.add(user);
        _getUserInfo();
        CallState.instance.callType = callMediaType;
        CallState.instance.scene = NECallScene.singleCall;
        CallState.instance.selfUser.callRole = NECallRole.caller;
        CallState.instance.selfUser.callStatus = NECallStatus.waiting;
        _runtimeAdapter.startOutgoingRing();
        launchCallingPage();
        CallManager.instance.enableWakeLock(true);
      } else if (callResult.code == NECallError.stateCallCalling ||
          callResult.code == NECallError.stateCallOnTheCall) {
        CallManager.instance.showToast(NECallKitUI.localizations.userInCall);
      } else {
        CallKitUILog.i(
          _tag,
          'callResult.code: ${callResult.code}, callResult.msg: ${callResult.msg}',
        );
      }
      CallKitUILog.i(
        _tag,
        'callResult.code: ${callResult.code}, callResult.msg: ${callResult.msg}',
      );
      return NEResult(code: callResult.code, message: callResult.msg);
    } else {
      CallKitUILog.i(_tag, 'Permission result fail');
      return NEResult(
        code: -1,
        message: NECallKitUI.localizations.permissionResultFail,
      );
    }
  }

  Future<NEResult> accept() async {
    CallKitUILog.i(_tag, 'accept');
    final result = await NECallEngine.instance.accept();
    CallKitUILog.i(
      _tag,
      'accept result code: ${result.code} data: ${result.data?.toJson().toString()}',
    );
    if (result.code == 0) {
      await applySingleCallAcceptSuccess(
        runtimeAdapter: _runtimeAdapter,
        callState: CallState.instance,
        syncCallStateToNative: _syncCallStateToNative,
        callInfo: result.data,
      );
    } else {
      CallState.instance.selfUser.callStatus = NECallStatus.none;
      _syncCallStateToNative();
    }
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> reject() async {
    await _runtimeAdapter.stopRing();
    final result = await NECallEngine.instance.hangup();
    CallKitUILog.i(_tag, 'reject result = $result');
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    _syncCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> switchCallMediaType(
    NECallType mediaType,
    NECallSwitchState state,
  ) async {
    CallKitUILog.i(_tag, 'switchCallMediaType mediaType = $mediaType');
    NECallEngine.instance.switchCallType(mediaType, state);
    _syncCallStateToNative();
  }

  Future<NEResult> hangup() async {
    await _runtimeAdapter.stopRing();
    final result = await NECallEngine.instance.hangup();
    CallKitUILog.i(_tag, 'hangup result = $result');
    if (CallState.instance.callType == NECallType.video &&
        CallState.instance.isCameraOpen) {
      await closeCamera();
    }
    CallState.instance.selfUser.callStatus = NECallStatus.none;
    _syncCallStateToNative();
    CallState.instance.cleanState();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> openCamera(NECamera camera, int viewId) async {
    CallKitUILog.i(_tag, 'openCamera camera = $camera');
    var result = NEResult(code: 0, message: 'success');
    if (_isDesktopRuntime) {
      await _applyPendingDesktopVideoCaptureDeviceIfNeeded();
    }
    if (Platform.isAndroid) {
      CallKitUILog.i(_tag, 'CallManager openCamera');
      var permissionResult = PermissionResult.granted;
      if (await Permission.has(permissions: [PermissionType.camera])) {
        permissionResult = await Permission.request(NECallType.video);
      }
      if (PermissionResult.granted == permissionResult) {
        var ret = await NECallEngine.instance.enableLocalVideo(true);
        result = NEResult(code: ret.code, message: ret.msg);
      } else {
        result = NEResult(
          code: -1,
          message: NECallKitUI.localizations.startCameraPermissionDenied,
        );
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
    _syncCallStateToNative();
    return result;
  }

  Future<void> closeCamera() async {
    CallKitUILog.i(_tag, 'CallManager closeCamera');
    NECallEngine.instance.enableLocalVideo(false);
    CallState.instance.isCameraOpen = false;
    CallState.instance.selfUser.videoAvailable = false;
    _syncCallStateToNative();
  }

  Future<void> switchCamera(NECamera camera) async {
    CallKitUILog.i(_tag, 'switchCamera camera = $camera');
    NECallEngine.instance.switchCamera();
    CallState.instance.camera = camera;
    _syncCallStateToNative();
  }

  Future<List<NEDesktopVideoDevice>> getDesktopVideoCaptureDevices() async {
    if (!_isDesktopRuntime) {
      return const <NEDesktopVideoDevice>[];
    }
    return await NECallEngine.instance.getVideoCaptureDevices();
  }

  Future<String?> getCurrentDesktopVideoCaptureDeviceId() async {
    if (!_isDesktopRuntime) {
      return null;
    }
    return resolveDesktopSelectedDeviceId(
      pendingDeviceId: _pendingDesktopVideoCaptureDeviceId,
      engineDeviceId:
          await NECallEngine.instance.getCurrentVideoCaptureDeviceId(),
    );
  }

  Future<NEResult> setDesktopVideoCaptureDevice(String deviceId) async {
    if (!_isDesktopRuntime) {
      return NEResult(code: -1, message: 'desktop runtime required');
    }
    if (deviceId.isEmpty) {
      return NEResult(code: -1, message: 'device id required');
    }
    CallKitUILog.i(_tag, 'setDesktopVideoCaptureDevice deviceId = $deviceId');
    if (!shouldApplyDesktopVideoCaptureDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isCameraOpen: CallState.instance.isCameraOpen,
    )) {
      _pendingDesktopVideoCaptureDeviceId = deviceId;
      return NEResult(code: 0, message: 'success');
    }
    final result = await NECallEngine.instance.setVideoCaptureDevice(deviceId);
    if (result.code == 0) {
      _pendingDesktopVideoCaptureDeviceId = null;
    }
    return NEResult(code: result.code, message: result.msg);
  }

  Future<List<NEDesktopAudioDevice>> getDesktopAudioRecordingDevices() async {
    if (!_isDesktopRuntime) {
      return const <NEDesktopAudioDevice>[];
    }
    return await NECallEngine.instance.getAudioRecordingDevices();
  }

  Future<String?> getCurrentDesktopAudioRecordingDeviceId() async {
    if (!_isDesktopRuntime) {
      return null;
    }
    return resolveDesktopSelectedDeviceId(
      pendingDeviceId: _pendingDesktopAudioRecordingDeviceId,
      engineDeviceId:
          await NECallEngine.instance.getCurrentAudioRecordingDeviceId(),
    );
  }

  Future<NEResult> setDesktopAudioRecordingDevice(String deviceId) async {
    if (!_isDesktopRuntime) {
      return NEResult(code: -1, message: 'desktop runtime required');
    }
    if (deviceId.isEmpty) {
      return NEResult(code: -1, message: 'device id required');
    }
    CallKitUILog.i(_tag, 'setDesktopAudioRecordingDevice deviceId = $deviceId');
    if (!shouldApplyDesktopAudioRecordingDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isMicrophoneMute: CallState.instance.isMicrophoneMute,
    )) {
      _pendingDesktopAudioRecordingDeviceId = deviceId;
      return NEResult(code: 0, message: 'success');
    }
    final result =
        await NECallEngine.instance.setAudioRecordingDevice(deviceId);
    if (result.code == 0) {
      _pendingDesktopAudioRecordingDeviceId = null;
    }
    return NEResult(code: result.code, message: result.msg);
  }

  Future<List<NEDesktopAudioDevice>> getDesktopAudioPlaybackDevices() async {
    if (!_isDesktopRuntime) {
      return const <NEDesktopAudioDevice>[];
    }
    return await NECallEngine.instance.getAudioPlaybackDevices();
  }

  Future<String?> getCurrentDesktopAudioPlaybackDeviceId() async {
    if (!_isDesktopRuntime) {
      return null;
    }
    return resolveDesktopSelectedDeviceId(
      pendingDeviceId: _pendingDesktopAudioPlaybackDeviceId,
      engineDeviceId:
          await NECallEngine.instance.getCurrentAudioPlaybackDeviceId(),
    );
  }

  Future<NEResult> setDesktopAudioPlaybackDevice(String deviceId) async {
    if (!_isDesktopRuntime) {
      return NEResult(code: -1, message: 'desktop runtime required');
    }
    if (deviceId.isEmpty) {
      return NEResult(code: -1, message: 'device id required');
    }
    CallKitUILog.i(_tag, 'setDesktopAudioPlaybackDevice deviceId = $deviceId');
    if (!shouldApplyDesktopAudioPlaybackDeviceImmediately(
      isDesktopRuntime: _isDesktopRuntime,
      isEnableSpeaker: CallState.instance.isEnableSpeaker,
    )) {
      _pendingDesktopAudioPlaybackDeviceId = deviceId;
      return NEResult(code: 0, message: 'success');
    }
    final result = await NECallEngine.instance.setAudioPlaybackDevice(deviceId);
    if (result.code == 0) {
      _pendingDesktopAudioPlaybackDeviceId = null;
    }
    return NEResult(code: result.code, message: result.msg);
  }

  Future<NEResult> openMicrophone([bool notify = true]) async {
    CallKitUILog.i(_tag, 'openMicrophone notify = $notify');
    if (_isDesktopRuntime) {
      await _applyPendingDesktopAudioRecordingDeviceIfNeeded();
    }
    final result = await NECallEngine.instance.muteLocalAudio(false);
    CallState.instance.isMicrophoneMute = false;
    _syncCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> closeMicrophone([bool notify = true]) async {
    CallKitUILog.i(_tag, 'closeMicrophone notify = $notify');
    NECallEngine.instance.muteLocalAudio(true);
    CallState.instance.isMicrophoneMute = true;
    _syncCallStateToNative();
  }

  Future<NEResult> setSpeakerphoneOn(bool enable) async {
    CallKitUILog.i(_tag, 'setSpeakerphoneOn enable = $enable');
    if (_isDesktopRuntime && enable) {
      await _applyPendingDesktopAudioPlaybackDeviceIfNeeded();
    }
    final result = await NECallEngine.instance.setSpeakerphoneOn(enable);
    if (result.code == 0) {
      final actualEnabled = _isDesktopRuntime
          ? await NECallEngine.instance.isSpeakerphoneOn()
          : null;
      CallState.instance.isEnableSpeaker = resolveSpeakerphoneEnabledState(
        isDesktopRuntime: _isDesktopRuntime,
        requestedEnabled: enable,
        actualEnabled: actualEnabled,
      );
    } else {
      CallKitUILog.i(
        _tag,
        'setSpeakerphoneOn failed code = ${result.code}, msg = ${result.msg}',
      );
    }
    _syncCallStateToNative();
    return NEResult(code: result.code, message: result.msg);
  }

  Future<void> setupLocalView(int viewId) async {
    CallKitUILog.i(_tag, 'CallManager setupLocalView(viewId:$viewId)');
    await NECallEngine.instance.setupLocalView(viewId);
    _syncCallStateToNative();
  }

  Future<void> setupRemoteView(String userId, int viewId) async {
    CallKitUILog.i(
      _tag,
      'CallManager setupRemoteView(userId:$userId, viewId:$viewId)',
    );
    if (CallState.instance.isIOSOpenFloatWindowOutOfApp) {
      CallKitUILog.i(
        _tag,
        'CallManager setupRemoteView skipped in iOS out-of-app PIP mode',
      );
      return;
    }
    await NECallEngine.instance.setupRemoteView(viewId);
    _syncCallStateToNative();
  }

  Future<void> stopRemoteView(String userId) async {
    // await NECallEngine.instance.setupRemoteView(userId);
  }

  Future<NEResult> setSelfInfo(String nickname, String avatar) async {
    // final result = await NECallEngine.instance.setSelfInfo(nickname, avatar);
    return NEResult(code: 0, message: '');
  }

  Future<NEResult> login(
    String appKey,
    String accountId,
    String token, {
    NECertificateConfig? certificateConfig,
    NEExtraConfig? extraConfig,
    NEGroupConfigParam? groupConfigParam,
  }) async {
    CallKitUILog.i(
      _tag,
      'CallManager login(appKey:$appKey, accountId:$accountId, certificateConfig:$certificateConfig, extraConfig:$extraConfig, groupConfigParam:$groupConfigParam) version:${Constants.pluginVersion}',
    );

    // 保存 appKey、extraConfig 和 groupConfigParam
    _appKey = appKey;
    _extraConfig = extraConfig ?? NEExtraConfig(); // 默认生成一个配置
    if (groupConfigParam != null) {
      _groupConfigParam = groupConfigParam;
    }
    CallKitUILog.i(
      _tag,
      'CallManager login: appKey saved = $_appKey, extraConfig = $_extraConfig, groupConfigParam = $_groupConfigParam',
    );

    late NIMSDKOptions options;
    if (Platform.isAndroid) {
      options = NIMAndroidSDKOptions(appKey: appKey);
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
    } else if (Platform.isMacOS || Platform.isWindows) {
      final sdkRootDir = await _resolveDesktopNimSdkRootDir();
      CallKitUILog.i(
        _tag,
        'CallManager login: desktop nim sdkRootDir=$sdkRootDir',
      );
      options = NIMPCSDKOptions(
        sdkRootDir: sdkRootDir,
        basicOption: NIMBasicOption(),
        appKey: appKey,
      );
    } else if (PlatformCompat.isOhos) {
      options = NIMAndroidSDKOptions(appKey: appKey);
    }
    var initRet = await NimCore.instance.initialize(options);
    if (initRet.code == 0) {
      NEEventNotify().notify(imSDKInitSuccessEvent, {});
    }
    var result = NEResult(code: 0, message: 'success');
    var imRet = await NimCore.instance.loginService.login(
      accountId,
      token,
      NIMLoginOption(),
    );
    if (imRet.code == 0) {
      NEEventNotify().notify(loginSuccessEvent, {
        'accountId': accountId,
        'token': token,
      });
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
    var filePath = await CallingBellFeature.getAssetsFilePath(assetName);
    PreferenceUtils.getInstance().saveString(
      CallingBellFeature.keyRingPath,
      filePath,
    );
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
    if (_isDesktopRuntime) {
      CallState.instance.isEnableSpeaker = true;
    } else if (NECallType.audio == CallState.instance.callType) {
      CallState.instance.isEnableSpeaker = false;
      CallState.instance.isCameraOpen = false;
    } else {
      CallState.instance.isEnableSpeaker = true;
      CallState.instance.isCameraOpen = true;
    }

    if (_isDesktopRuntime && NECallType.audio == CallState.instance.callType) {
      CallState.instance.isCameraOpen = false;
    } else if (_isDesktopRuntime) {
      CallState.instance.isCameraOpen = true;
    }

    CallManager.instance.setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
  }

  void handleLoginSuccess(String accountId, String token) {
    CallKitUILog.i(_tag, 'CallManager handleLoginSuccess()');
    CallKitUILog.i(
      _tag,
      'CallManager handleLoginSuccess: appKey = $_appKey, accountId = $accountId, groupConfigParam = $_groupConfigParam',
    );
    CallManager.instance.setupEngine(
      _appKey!,
      accountId,
      extraConfig: _extraConfig,
      groupConfigParam: _groupConfigParam,
    );

    // 如果提供了群呼配置参数，则初始化群呼管理器
    if (_groupConfigParam != null && !_isDesktopRuntime) {
      GroupCallManager.instance.setup(
        localUserId: accountId,
        config: _groupConfigParam,
      );
    } else if (_groupConfigParam != null) {
      CallKitUILog.i(
        _tag,
        'CallManager handleLoginSuccess: skip group-call setup on desktop runtime',
      );
    }
  }

  void handleLogoutSuccess() {
    CallKitUILog.i(_tag, 'CallManager handleLogoutSuccess()');
    NECallKitNavigatorObserver.getInstance().exitCallingPage(
      reason: 'logout_success',
    );
    NECallEngine.instance.destroy();
    _runtimeAdapter.stopRing();
    CallState.instance.cleanState();
    CallState.instance.unRegisterEngineObserver();
    _syncCallStateToNative();
    CallManager.instance.destroyEngine();
  }

  void handleAppEnterForeground() async {
    CallKitUILog.i(
      _tag,
      'CallManager handleAppEnterForeground() '
      'callStatus = ${CallState.instance.selfUser.callStatus},'
      'currentPage = ${NECallKitNavigatorObserver.currentPage},'
      'isOpenFloatWindow = ${CallState.instance.isOpenFloatWindow},'
      'isInNativeIncomingBanner = ${CallState.instance.isInNativeIncomingBanner},'
      'isScreenLocked = ${await CallManager.instance.isScreenLocked()}',
    );

    // iOS: 如果启用了应用外悬浮窗，且在通话中，则停止画中画
    if (Platform.isIOS &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.isIOSOpenFloatWindowOutOfApp &&
        CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus != NECallStatus.none) {
      await NECallKitPlatform.instance.disposePIP();
      CallState.instance.isIOSOpenFloatWindowOutOfApp = false;
      if (!CallState.instance.isOpenFloatWindow) {
        backCallingPageFormFloatWindow();
      } else {
        NECallKitPlatform.instance.startFloatWindow();
      }
      // 重新设置画中画
      NECallKitPlatform.instance.setupPIP();
    }

    // OHOS: 如果启用了应用外悬浮窗，且在通话中（视频画中画或语音悬浮窗）
    if (PlatformCompat.isOhos &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      // 检查画中画是否正在运行
      final isPipRunning = await NECallKitPlatform.instance.isPipRunning();
      CallKitUILog.i(_tag,
          'handleAppEnterForeground: OHOS isPipRunning=$isPipRunning, isOpenFloatWindow=${CallState.instance.isOpenFloatWindow}');
    }

    if (CallState.instance.selfUser.callStatus != NECallStatus.none &&
        NECallKitNavigatorObserver.currentPage == CallPage.none &&
        CallState.instance.isOpenFloatWindow == false &&
        CallState.instance.isInNativeIncomingBanner == false &&
        !(await CallManager.instance.isScreenLocked())) {
      // T042：前台重显——若横幅模式开启且来电仍存活但横幅未显示，则重新展示横幅
      if (_enableIncomingBanner && !_bannerIsActive) {
        CallKitUILog.i(_tag, 'appResumed checkBannerState reShowBanner');
        _bannerIsActive = true;
        await NECallKitPlatform.instance.setIncomingBannerEnabled(true);
      } else {
        launchCallingPage();
      }
    }
  }

  void handleAppEnterBackground() async {
    CallKitUILog.i(
      _tag,
      'CallManager handleAppEnterBackground() '
      'callStatus = ${CallState.instance.selfUser.callStatus},'
      'currentPage = ${NECallKitNavigatorObserver.currentPage},'
      'isOpenFloatWindow = ${CallState.instance.isOpenFloatWindow},'
      'isIOSOpenFloatWindowOutOfApp = ${CallState.instance.isIOSOpenFloatWindowOutOfApp}',
    );

    // Android: 如果启用了应用外悬浮窗，且在通话中，则启动普通悬浮窗
    if (Platform.isAndroid &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      openFloatWindowWithPageState();
    }

    // iOS: 进入后台启动画中画（仅视频通话）
    if (Platform.isIOS &&
        CallState.instance.enableFloatWindowOutOfApp &&
        CallState.instance.enableFloatWindow &&
        CallState.instance.callType == NECallType.video &&
        CallState.instance.selfUser.callStatus == NECallStatus.accept) {
      final success = await NECallKitPlatform.instance.startPIP();
      CallState.instance.isIOSOpenFloatWindowOutOfApp = success;
      CallKitUILog.i(
        _tag,
        'CallManager handleAppEnterBackground: startPIP result = $success',
      );
    }
  }

  Future<void> openFloatWindowWithPageState() async {
    CallKitUILog.i(_tag, 'CallManager openFloatWindowWithState()');
    if ((Platform.isAndroid &&
            await NECallKitPlatform.instance.hasFloatPermission()) ||
        Platform.isIOS ||
        PlatformCompat.isOhos) {
      openFloatWindow();
      if (NECallKitNavigatorObserver.currentPage == CallPage.callingPage) {
        NECallKitNavigatorObserver.getInstance().exitCallingPage();
      }
    }
  }

  void launchCallingPage() {
    CallKitUILog.i(_tag, 'CallManager launchCallWidget()');
    final launchContext = _buildCallingPageLaunchContext();
    if (!_shouldContinueDesktopSingleCallUiFlow(
      reason: 'launch_calling_page',
      launchContext: launchContext,
    )) {
      return;
    }
    _checkLocalSelfUserInfo();
    CallManager.instance.initAudioPlayDeviceAndCamera();
    NEEventNotify().notify(setStateEventOnCallReceived, launchContext);
    _syncCallStateToNative();
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
    CallKitUILog.i(
      _tag,
      'backCallingPageFormFloatWindow: currentPage = ${NECallKitNavigatorObserver.currentPage}, isClose = ${NECallKitNavigatorObserver.isClose}',
    );

    // 如果当前已经有通话页面，不需要再次 push，只需要刷新状态即可
    if (NECallKitNavigatorObserver.currentPage == CallPage.callingPage &&
        (Platform.isIOS || PlatformCompat.isOhos)) {
      CallKitUILog.i(
        _tag,
        'backCallingPageFormFloatWindow: Already in calling page, just update state',
      );
      CallState.instance.isOpenFloatWindow = false;

      // 通知刷新视频 view
      NEEventNotify().notify('refreshVideoViews');
    } else {
      // 如果不在通话页面，则进入通话页面
      CallKitUILog.i(
        _tag,
        'backCallingPageFormFloatWindow: Entering calling page',
      );
      _enterCallingPage('back_from_float_window');
      CallState.instance.isOpenFloatWindow = false;
    }
  }

  void showToast(String string) {
    if (_isDesktopRuntime) {
      final overlayState =
          NECallKitNavigatorObserver.getInstance().navigator?.overlay;
      if (overlayState != null && overlayState.mounted) {
        ToastUtils.showToastOnOverlay(overlayState, string);
        return;
      }
      CallKitUILog.i(_tag, 'showToast skipped: no overlay state, msg:$string');
      return;
    }
    Fluttertoast.showToast(msg: string);
  }

  void enableIncomingBanner(bool enable) {
    CallState.instance.enableIncomingBanner = enable;
    _enableIncomingBanner = enable;
    // 同步通知 Java 侧，确保 WindowManager.showIncomingBanner() 不会提前返回
    NECallKitPlatform.instance.setIncomingBannerEnabled(enable);
    // Android/OHOS 横幅需要悬浮窗权限，开启时自动跳转设置页申请
    if (enable && (Platform.isAndroid || PlatformCompat.isOhos)) {
      NECallKitPlatform.instance.hasFloatPermission().then((hasPermission) {
        if (!hasPermission) {
          CallKitUILog.i(
            _tag,
            'enableIncomingBanner: no float permission, requesting...',
          );
          NECallKitPlatform.instance.requestFloatPermission();
        }
      });
    }
  }

  /// 横幅接听按钮被点击（由 iOS 原生通过方法通道回调）
  Future<void> handleBannerAccept() async {
    CallKitUILog.i(_tag, 'CallManager handleBannerAccept');
    _bannerIsActive = false;
    // 先申请权限，再接听，权限拒绝则拒绝来电
    final permissionResult = await _runtimeAdapter.requestPermissions(
      CallState.instance.callType,
    );
    if (permissionResult != PermissionResult.granted) {
      _runtimeAdapter.stopRing();
      await reject();
      return;
    }
    final result = await accept();
    if (result.code == 0) {
      // 初始化摄像头和音频设备状态，确保 isCameraOpen 在页面打开前已设置正确
      // 否则 onPlatformViewCreated 里的 openCamera 条件判断会失败，导致本地画面不显示
      initAudioPlayDeviceAndCamera();
      _enterCallingPage('banner_accept');
    } else {
      // 接听失败（如断网），立即停止铃声并挂断，避免铃声一直响
      await _runtimeAdapter.stopRing();
      await reject();
    }
  }

  /// 横幅拒绝按钮被点击（由 iOS 原生通过方法通道回调）
  Future<void> handleBannerReject() async {
    CallKitUILog.i(_tag, 'CallManager handleBannerReject');
    _bannerIsActive = false;
    await _runtimeAdapter.stopRing();
    await reject();
  }

  Future<void> enableWakeLock(bool enable) async {
    CallKitUILog.i(_tag, 'CallManager enableWakeLock($enable)');
    await NECallKitPlatform.instance.enableWakeLock(enable);
  }

  void showIncomingBanner() {
    CallKitUILog.i(_tag, 'CallManager showIncomingBanner');
    _bannerIsActive = true;
    NECallKitPlatform.instance.showIncomingBanner();
  }

  /// 清除横幅活跃状态（供 native 横幅交互后调用，防止 secondCallIgnored 误判）
  void clearBannerActiveState() {
    CallKitUILog.i(_tag, 'CallManager clearBannerActiveState');
    _bannerIsActive = false;
  }

  /// 从横幅直接进入通话页（不走 setStateEventOnCallReceived，避免 banner 逻辑重入死循环）
  void enterCallingPageFromBanner() {
    CallKitUILog.i(_tag, 'CallManager enterCallingPageFromBanner');
    _checkLocalSelfUserInfo();
    CallManager.instance.initAudioPlayDeviceAndCamera();
    _enterCallingPage('banner_direct_entry');
    _syncCallStateToNative();
    CallState.instance.isOpenFloatWindow = false;
  }

  void pullBackgroundApp() {
    CallKitUILog.i(_tag, 'CallManager pullBackgroundApp');
    NECallKitPlatform.instance.pullBackgroundApp();
  }

  void openLockScreenApp() {
    CallKitUILog.i(_tag, 'CallManager openLockScreenApp');
    NECallKitPlatform.instance.openLockScreenApp();
  }

  /// 启动前台 Service
  ///
  /// [callType] 通话类型。传入时按该类型校验权限并启动对应 Service；
  /// 为空时（群呼场景），根据当前已授予的权限决定启动什么类型的 Service。
  Future<void> startForegroundService({NECallType? callType}) async {
    if (!CallState.instance.isStartForegroundService) {
      CallKitUILog.i(
        _tag,
        'CallManager startForegroundService: callType=$callType',
      );

      NECallType serviceType;

      if (callType != null) {
        // 单呼场景：按通话类型校验权限
        var hasRequiredPermissions = false;

        if (callType == NECallType.audio) {
          hasRequiredPermissions = await Permission.has(
            permissions: [PermissionType.microphone],
          );
          CallKitUILog.i(
            _tag,
            'startForegroundService: audio call, hasMicrophonePermission = $hasRequiredPermissions',
          );
        } else if (callType == NECallType.video) {
          hasRequiredPermissions = await Permission.has(
            permissions: [PermissionType.microphone, PermissionType.camera],
          );
          CallKitUILog.i(
            _tag,
            'startForegroundService: video call, hasMicrophoneAndCameraPermissions = $hasRequiredPermissions',
          );
        } else {
          hasRequiredPermissions = true;
        }

        if (!hasRequiredPermissions) {
          CallKitUILog.i(
            _tag,
            'startForegroundService: permission denied, cannot start foreground service',
          );
          return;
        }
        serviceType = callType;
      } else {
        // 群呼场景：根据已授予的权限决定 Service 类型
        final hasMicrophone = await Permission.has(
          permissions: [PermissionType.microphone],
        );
        final hasCamera = await Permission.has(
          permissions: [PermissionType.camera],
        );
        CallKitUILog.i(
          _tag,
          'startForegroundService: detecting permissions, hasMic=$hasMicrophone, hasCam=$hasCamera',
        );

        if (hasMicrophone && hasCamera) {
          serviceType = NECallType.video;
        } else if (hasMicrophone) {
          serviceType = NECallType.audio;
        } else {
          CallKitUILog.i(
            _tag,
            'startForegroundService: no microphone permission, skip',
          );
          return;
        }
      }

      NECallKitPlatform.instance.startForegroundService(serviceType);
      CallState.instance.isStartForegroundService = true;
      CallKitUILog.i(
        _tag,
        'startForegroundService: started with serviceType=$serviceType',
      );
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

  void _checkLocalSelfUserInfo() async {
    if (CallState.instance.selfUser.nickname == '' &&
        (CallState.instance.selfUser.avatar == Constants.defaultAvatar ||
            CallState.instance.selfUser.avatar.isEmpty)) {
      final userInfo = await NimUtils.getUserInfo(
        CallState.instance.selfUser.id,
      );
      CallState.instance.selfUser.nickname = StringStream.makeNull(
        userInfo.nickname,
        '',
      );
      CallState.instance.selfUser.avatar = StringStream.makeNull(
        userInfo.avatar,
        Constants.defaultAvatar,
      );
    }
  }

  void _getUserInfo() async {
    final copyList = List<User>.from(CallState.instance.remoteUserList);
    for (var user in copyList) {
      final userInfo = await NimUtils.getUserInfo(user.id);
      user.nickname = StringStream.makeNull(userInfo.nickname, '');
      user.avatar = StringStream.makeNull(
        userInfo.avatar,
        Constants.defaultAvatar,
      );
    }
    NEEventNotify().notify(setStateEvent);
  }
}
