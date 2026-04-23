// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:io';

import 'package:netease_callkit_ui/ne_callkit_ui.dart';
import 'package:netease_callkit_ui/src/data/constants.dart';
import 'package:netease_callkit_ui/src/data/user.dart';
import 'package:netease_callkit_ui/src/event/event_notify.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_platform_interface.dart';
import 'package:netease_callkit_ui/src/platform/call_kit_runtime_adapter.dart';
import 'package:netease_callkit_ui/src/platform/platform_compat.dart';
import 'package:netease_callkit_ui/src/utils/nim_utils.dart';

class CallState {
  static const String _tag = 'CallState';
  static final CallState instance = CallState._internal();
  static const CallKitRuntimeAdapter _runtimeAdapter = CallKitRuntimeAdapter();

  factory CallState() {
    return instance;
  }

  CallState._internal() {
    init();
  }

  User selfUser = User();
  User caller = User();
  List<User> calleeList = [];
  List<String> calleeIdList = [];
  List<User> remoteUserList = [];
  NECallScene scene = NECallScene.singleCall;
  NECallType callType = NECallType.audio;
  int timeCount = 0;
  int startTime = 0;
  Timer? _timer;
  String currentCallId = '';
  String groupId = '';
  bool isCameraOpen = false;
  NECamera camera = NECamera.front;
  bool isMicrophoneMute = false;
  bool isEnableSpeaker = false;
  bool enableFloatWindow = false;
  bool enableFloatWindowOutOfApp = false;
  bool showVirtualBackgroundButton = false;
  bool enableBlurBackground = false;
  NetworkQualityHint networkQualityReminder = NetworkQualityHint.none;

  bool isLocalViewBig = true;
  bool preferLocalPreviewBeforeRemoteVideo = false;
  bool isOpenFloatWindow = false;
  bool isIOSOpenFloatWindowOutOfApp = false;
  bool enableIncomingBanner = false;
  bool isInNativeIncomingBanner = false;

  bool isStartForegroundService = false;

  static bool shouldShowRemoteCancelToast({
    required NECallTerminalCode reasonCode,
    required NECallRole callRole,
  }) {
    if (reasonCode == NECallTerminalCode.calleeCancel) {
      return true;
    }
    return reasonCode == NECallTerminalCode.callerCancel &&
        callRole == NECallRole.called;
  }

  static bool shouldEnterCallingPageAfterLckAccept({
    required CallPage currentPage,
    required bool isOpenFloatWindow,
  }) {
    return currentPage == CallPage.none && !isOpenFloatWindow;
  }

  final NECallEngineDelegate observer = NECallEngineDelegate(
    onReceiveInvited: (NEInviteInfo info) async {
      CallKitUILog.i(_tag,
          'NECallObserver onReceiveInvited(callerAccId:${info.callerAccId}, callType:${info.callType}, callId:${info.callId})');
      CallState.instance.currentCallId = info.callId ?? '';
      // 先处理来电逻辑（设置 callRole 为 called），再播放铃声
      // 否则 startRing 读取的 callRole 还是默认值，会播放错误的铃声
      await CallState.instance.handleCallReceivedData(
          info.callerAccId, [], info.channelId ?? '', info.callType);
      await _runtimeAdapter.startIncomingRing();
      await NECallKitPlatform.instance.updateCallStateToNative();
      // await CallManager.instance.enableWakeLock(true);
      if (Platform.isIOS) {
        if (CallState.instance.enableIncomingBanner) {
          CallState.instance.isInNativeIncomingBanner = true;
          CallManager.instance.showIncomingBanner();
        } else {
          CallState.instance.isInNativeIncomingBanner = false;
          CallManager.instance.launchCallingPage();
        }
      } else if (Platform.isAndroid) {
        if (await CallManager.instance.isScreenLocked()) {
          CallManager.instance.openLockScreenApp();
          return;
        }
        if (CallState.instance.enableIncomingBanner &&
            await NECallKitPlatform.instance.hasFloatPermission() &&
            !(await CallManager.instance.isSamsungDevice())) {
          CallState.instance.isInNativeIncomingBanner = true;
          // 确保 Java 侧 sIncomingBannerEnabled = true，否则 WindowManager.showIncomingBanner() 会提前返回
          await NECallKitPlatform.instance.setIncomingBannerEnabled(true);
          CallManager.instance.showIncomingBanner();
        } else {
          if (await NECallKitPlatform.instance.isAppInForeground()) {
            CallState.instance.isInNativeIncomingBanner = false;
            CallManager.instance.launchCallingPage();
          } else {
            CallManager.instance.pullBackgroundApp();
          }
        }
      } else if (Platform.isMacOS || Platform.isWindows) {
        // Desktop reuses the Flutter calling page, so an incoming invite must
        // explicitly drive the same launch flow that mobile foreground calls use.
        CallState.instance.isInNativeIncomingBanner = false;
        CallManager.instance.launchCallingPage();
      } else if (PlatformCompat.isOhos) {
        // OHOS 平台：直接启动通话页面，无需特殊权限检查
        if (CallState.instance.enableIncomingBanner) {
          CallState.instance.isInNativeIncomingBanner = true;
          await NECallKitPlatform.instance.setIncomingBannerEnabled(true);
          CallManager.instance.showIncomingBanner();
        } else {
          if (await NECallKitPlatform.instance.isAppInForeground()) {
            CallState.instance.isInNativeIncomingBanner = false;
            CallManager.instance.launchCallingPage();
          } else {
            CallManager.instance.pullBackgroundApp();
          }
        }
      }
    },
    onCallEnd: (NECallEndInfo info) async {
      CallKitUILog.i(_tag,
          'NECallObserver onCallEnd(reasonCode:${info.reasonCode}, message:${info.message}, callId:${info.callId}, currentCallId:${CallState.instance.currentCallId})');
      if ((Platform.isMacOS || Platform.isWindows) &&
          info.callId != null &&
          info.callId!.isNotEmpty &&
          CallState.instance.currentCallId.isNotEmpty &&
          info.callId != CallState.instance.currentCallId) {
        CallKitUILog.i(_tag,
            'NECallObserver onCallEnd ignored stale desktop event: eventCallId=${info.callId}, currentCallId=${CallState.instance.currentCallId}');
        return;
      }
      if (info.reasonCode == NECallTerminalCode.busy) {
        CallManager.instance.showToast(NECallKitUI.localizations.userBusy);
      } else if (info.reasonCode == NECallTerminalCode.calleeReject ||
          info.reasonCode == NECallTerminalCode.callerRejected) {
        if (CallState.instance.selfUser.callRole == NECallRole.caller) {
          CallManager.instance
              .showToast(NECallKitUI.localizations.remoteUserReject);
        }
      } else if (info.reasonCode == NECallTerminalCode.otherAccepted) {
        CallManager.instance
            .showToast(NECallKitUI.localizations.answerOnOtherDevice);
      } else if (info.reasonCode == NECallTerminalCode.otherRejected) {
        CallManager.instance
            .showToast(NECallKitUI.localizations.rejectOnOtherDevice);
      } else if (info.reasonCode == NECallTerminalCode.timeOut) {
        if (CallState.instance.selfUser.callRole == NECallRole.caller) {
          CallManager.instance
              .showToast(NECallKitUI.localizations.remoteTimeout);
        }
      } else if (shouldShowRemoteCancelToast(
        reasonCode: info.reasonCode,
        callRole: CallState.instance.selfUser.callRole,
      )) {
        CallManager.instance.showToast(NECallKitUI.localizations.remoteCancel);
      } else {
        CallKitUILog.i(_tag, 'NECallObserver onCallEnd: ${info.reasonCode}');
      }
      await _runtimeAdapter.stopRing();
      if (CallState.instance.callType == NECallType.video &&
          CallState.instance.isCameraOpen) {
        CallManager.instance.closeCamera();
      }

      // 如果启用了应用外悬浮窗，清理画中画资源（iOS 和鸿蒙）
      if ((Platform.isIOS || PlatformCompat.isOhos) &&
          CallState.instance.enableFloatWindowOutOfApp &&
          CallState.instance.enableFloatWindow) {
        await NECallKitPlatform.instance.disposePIP();
      }

      // 如果悬浮窗打开中，关闭悬浮窗（处理未启用应用外悬浮窗但普通悬浮窗已显示的情况）
      if (CallState.instance.isOpenFloatWindow) {
        CallKitUILog.i(_tag, 'NECallObserver onCallEnd: stopping float window');
        await NECallKitPlatform.instance.stopFloatWindow();
      }

      CallManager.instance.clearBannerActiveState();

      // iOS 来电横幅自动 dismiss（T023）
      if (Platform.isIOS && CallState.instance.isInNativeIncomingBanner) {
        await NECallKitPlatform.instance.cancelIncomingBanner();
      }

      CallState.instance.cleanState();
      NEEventNotify().notify(setStateEventOnCallEnd);
      CallManager.instance.enableWakeLock(false);
      CallState.instance.stopTimer();
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onCallConnected: (NECallInfo info) async {
      CallKitUILog.i(_tag,
          'NECallObserver onCallConnected(callId:${info.callId}, callType:${info.callType})');
      CallState.instance.currentCallId = info.callId;
      CallState.instance.startTime =
          DateTime.now().millisecondsSinceEpoch ~/ 1000;
      await _runtimeAdapter.stopRing();
      CallState.instance.callType = info.callType;
      CallState.instance.selfUser.callStatus = NECallStatus.accept;
      if (CallState.instance.isMicrophoneMute) {
        CallManager.instance.closeMicrophone();
      } else {
        CallManager.instance.openMicrophone();
      }

      // 视频通话接通后默认开启扬声器（延迟1秒）
      if (info.callType == NECallType.video) {
        CallState.instance.isEnableSpeaker = true;
        // 延迟1秒后开启扬声器
        Future.delayed(const Duration(seconds: 1), () async {
          await CallManager.instance
              .setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
          CallKitUILog.i(
              _tag, 'NECallObserver: Delayed speaker enabled after 1 second');
        });
      } else {
        // 音频通话立即设置（使用听筒）
        await CallManager.instance
            .setSpeakerphoneOn(CallState.instance.isEnableSpeaker);
      }

      CallState.instance.startTimer();
      CallState.instance.isLocalViewBig = false;
      CallState.instance.preferLocalPreviewBeforeRemoteVideo =
          info.callType == NECallType.video;
      CallState.instance.isInNativeIncomingBanner = false;

      CallKitUILog.i(_tag,
          'NECallObserver onCallConnected: enableFloatWindowOutOfApp = ${CallState.instance.enableFloatWindowOutOfApp}, enableFloatWindow = ${CallState.instance.enableFloatWindow}');

      // 如果启用了应用外悬浮窗，设置画中画（iOS 和 OHOS）
      if ((Platform.isIOS || PlatformCompat.isOhos) &&
          CallState.instance.enableFloatWindowOutOfApp &&
          CallState.instance.enableFloatWindow &&
          CallState.instance.callType == NECallType.video) {
        // 被叫接听成功会先走一次原生状态同步，主叫直连场景不会。
        // 这里先把 accept 状态同步给原生，再初始化 PiP，避免首次 setupPIP
        // 仍看到旧的 waiting 状态而直接跳过。
        await NECallKitPlatform.instance.updateCallStateToNative();
        final success = await NECallKitPlatform.instance.setupPIP();
        CallKitUILog.i(
            _tag, 'NECallObserver onCallConnected: setupPIP result = $success');
      }

      NEEventNotify().notify(setStateEvent);
      NEEventNotify().notify(setStateEventOnCallBegin);
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onLCKAccept: (NELCKAcceptResult result) async {
      CallKitUILog.i(_tag,
          'NECallObserver onLCKAccept(code:${result.code}, callId:${result.callInfo?.callId}, currentCallId:${CallState.instance.currentCallId})');
      if (!Platform.isIOS || result.code != 0) {
        return;
      }

      await CallManager.applySingleCallAcceptSuccess(
        runtimeAdapter: _runtimeAdapter,
        callState: CallState.instance,
        syncCallStateToNative: () {
          NECallKitPlatform.instance.updateCallStateToNative();
        },
        callInfo: result.callInfo,
      );

      CallState.instance.isInNativeIncomingBanner = false;
      CallManager.instance.clearBannerActiveState();
      await NECallKitPlatform.instance.cancelIncomingBanner();
      NEEventNotify().notify(setStateEvent);

      if (shouldEnterCallingPageAfterLckAccept(
        currentPage: NECallKitNavigatorObserver.currentPage,
        isOpenFloatWindow: CallState.instance.isOpenFloatWindow,
      )) {
        CallManager.instance.enterCallingPageFromBanner();
      }
    },
    onCallTypeChange: (NECallTypeChangeInfo info) {
      CallKitUILog.i(_tag,
          'NECallObserver onCallTypeChange(callType:${info.callType}, state:${info.state})');
      CallState.instance.callType = info.callType;
      NEEventNotify().notify(setStateEvent);
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onVideoAvailable: (bool available, String userID) {
      CallKitUILog.i(_tag,
          'NECallObserver onVideoAvailable(userId:$userID, isVideoAvailable:$available)');
      for (var remoteUser in CallState.instance.remoteUserList) {
        if (remoteUser.id == userID) {
          remoteUser.videoAvailable = available;
          if (available &&
              CallState.instance.preferLocalPreviewBeforeRemoteVideo) {
            CallState.instance.preferLocalPreviewBeforeRemoteVideo = false;
          }
          NEEventNotify().notify(setStateEvent);
          NECallKitPlatform.instance.updateCallStateToNative();
          return;
        }
      }
    },
    onVideoMuted: (bool muted, String userID) {
      CallKitUILog.i(
          _tag, 'NECallObserver onVideoMuted(userId:$userID, muted:$muted)');
      // 处理视频静音逻辑
      for (var remoteUser in CallState.instance.remoteUserList) {
        if (remoteUser.id == userID) {
          remoteUser.videoAvailable = !muted;
          if (!muted &&
              CallState.instance.preferLocalPreviewBeforeRemoteVideo) {
            CallState.instance.preferLocalPreviewBeforeRemoteVideo = false;
          }
          NEEventNotify().notify(setStateEvent);
          NECallKitPlatform.instance.updateCallStateToNative();
          return;
        }
      }
    },
    onAudioMuted: (bool muted, String userID) {
      CallKitUILog.i(
          _tag, 'NECallObserver onAudioMuted(userId:$userID, muted:$muted)');
      for (var remoteUser in CallState.instance.remoteUserList) {
        if (remoteUser.id == userID) {
          remoteUser.audioAvailable = !muted;
          NEEventNotify().notify(setStateEvent);
          return;
        }
      }
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onLocalAudioMuted: (bool muted) {
      CallKitUILog.i(_tag, 'NECallObserver onLocalAudioMuted(muted:$muted)');
      CallState.instance.isMicrophoneMute = muted;
      NECallKitPlatform.instance.updateCallStateToNative();
    },
    onRtcInitEnd: () {
      CallKitUILog.i(_tag, 'NECallObserver onRtcInitEnd()');
      NECallKitPlatform.instance.updateCallStateToNative();
      // RTC 初始化完成
    },
    onNERtcEngineVirtualBackgroundSourceEnabled: (bool enabled, int reason) {
      CallKitUILog.i(_tag,
          'NECallObserver onNERtcEngineVirtualBackgroundSourceEnabled(enabled:$enabled, reason:$reason)');
      // 处理虚拟背景
      NECallKitPlatform.instance.updateCallStateToNative();
    },
  );

  void init() {}

  void registerEngineObserver() {
    CallKitUILog.i(_tag, 'registerEngineObserver');
    NECallEngine.instance.addCallDelegate(observer);
  }

  void unRegisterEngineObserver() {
    CallKitUILog.i(_tag, 'unRegisterEngineObserver');
    NECallEngine.instance.removeCallDelegate(observer);
  }

  Future<void> handleCallReceivedData(
      String callerId,
      List<String> calleeIdList,
      String groupId,
      NECallType callMediaType) async {
    CallKitUILog.i(_tag,
        'handleCallReceivedData callerId = $callerId callMediaType = $callMediaType');
    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList.clear();
    CallState.instance.calleeIdList.addAll(calleeIdList);
    // CallState.instance.groupId = groupId;
    CallState.instance.callType = callMediaType;
    CallState.instance.selfUser.callStatus = NECallStatus.waiting;

    // if (calleeIdList.isEmpty) {
    //   return;
    // }

    // if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
    //   CallManager.instance.showToast(CallKit_t('exceededMaximumNumber'));
    //   return;
    // }

    // CallState.instance.groupId = groupId;
    // if (CallState.instance.groupId.isNotEmpty || calleeIdList.length > 1) {
    //   CallState.instance.scene = NECallScene.groupCall;
    // } else {
    //   CallState.instance.scene = NECallScene.singleCall;
    // }
    CallState.instance.scene = NECallScene.singleCall;

    CallState.instance.callType = callMediaType;

    CallState.instance.selfUser.callRole = NECallRole.called;

    final allUserId = [callerId] + calleeIdList;

    for (var userId in allUserId) {
      if (CallState.instance.selfUser.id == userId) {
        if (userId == callerId) {
          CallState.instance.caller = CallState.instance.selfUser;
        } else {
          CallState.instance.calleeList.add(CallState.instance.selfUser);
        }
        continue;
      }

      final user = User();
      user.id = userId;

      if (userId == callerId) {
        CallState.instance.caller = user;
      } else {
        CallState.instance.calleeList.add(user);
      }
    }

    var callerInfo = await NimUtils.getUserInfo(callerId);
    CallState.instance.caller.id = callerInfo.id;
    CallState.instance.caller.nickname = callerInfo.nickname;
    CallState.instance.caller.avatar = callerInfo.avatar;
    CallState.instance.caller.callRole = NECallRole.caller;

    CallState.instance.remoteUserList.clear();
    if (CallState.instance.caller.id.isNotEmpty &&
        CallState.instance.selfUser.id != CallState.instance.caller.id) {
      CallState.instance.remoteUserList.add(CallState.instance.caller);
    }
    for (var callee in CallState.instance.calleeList) {
      if (CallState.instance.selfUser.id == callee.id) {
        continue;
      }
      CallState.instance.remoteUserList.add(callee);
    }
  }

  void startTimer() {
    CallState.instance.stopTimer();
    CallState.instance.timeCount = 0;
    CallState.instance._timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (NECallStatus.accept != CallState.instance.selfUser.callStatus) {
        stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      NEEventNotify().notify(setStateEventRefreshTiming);
    });
  }

  void stopTimer() {
    CallState.instance._timer?.cancel();
    CallState.instance._timer = null;
  }

  void cleanState() {
    CallKitUILog.i(_tag, 'cleanState');
    stopTimer();
    CallState.instance.selfUser.callRole = NECallRole.none;
    CallState.instance.selfUser.callStatus = NECallStatus.none;

    CallState.instance.remoteUserList.clear();
    CallState.instance.caller = User();
    CallState.instance.calleeList.clear();
    CallState.instance.calleeIdList.clear();

    CallState.instance.callType = NECallType.audio;
    CallState.instance.timeCount = 0;
    CallState.instance.currentCallId = '';
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = NECamera.front;
    CallState.instance.isCameraOpen = false;
    CallState.instance.isEnableSpeaker = false;

    CallState.instance.isLocalViewBig = true;
    CallState.instance.preferLocalPreviewBeforeRemoteVideo = false;
    CallState.instance.enableBlurBackground = false;

    // 重置悬浮窗状态
    CallState.instance.isOpenFloatWindow = false;
    CallState.instance.isInNativeIncomingBanner = false;
    if (Platform.isIOS) {
      CallState.instance.isIOSOpenFloatWindowOutOfApp = false;
    }
  }

  bool isBadNetwork(NENetworkQuality quality) {
    return quality == NENetworkQuality.bad ||
        quality == NENetworkQuality.veryBad ||
        quality == NENetworkQuality.down;
  }
}
