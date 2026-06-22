// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'call_ui_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class CallKitClientLocalizationsZh extends CallKitClientLocalizations {
  CallKitClientLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get youHaveANewCall => '您有一个新的通话';

  @override
  String get initEngineFail => '引擎初始化失败';

  @override
  String get callFailedUserIdEmpty => '呼叫失败，用户ID为空';

  @override
  String get permissionResultFail => '权限校验失败';

  @override
  String get startCameraPermissionDenied => '启动摄像头权限被拒绝';

  @override
  String get applyForMicrophonePermission => '申请麦克风权限';

  @override
  String get applyForCameraPermission => '申请摄像头权限';

  @override
  String get applyForMicrophoneAndCameraPermissions => '申请麦克风、摄像头权限';

  @override
  String get needToAccessMicrophonePermission =>
      '需要访问您的麦克风权限，开启后用于语音通话、视频通话等功能。请点击“前往设置”按钮进入权限相关页面，进行设置。';

  @override
  String get needToAccessCameraPermission =>
      '需要访问您的摄像头权限，开启后用于视频通话等功能。请点击“前往设置”按钮进入权限相关页面，进行设置。';

  @override
  String get errorInPeerBlacklist => '发起通话失败，用户在黑名单中，禁止发起！';

  @override
  String get insufficientPermissions => '新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。';

  @override
  String
      get displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions =>
          '请同时打开后台弹出界面和显示悬浮窗权限';

  @override
  String get needToAccessMicrophoneAndCameraPermissions =>
      '需要访问您的麦克风和摄像头权限，开启后用于语音通话、视频通话等功能。请点击“前往设置”按钮进入权限相关页面，进行设置';

  @override
  String get noFloatWindowPermission => '浮窗权限未获取';

  @override
  String get needFloatWindowPermission => '你的手机没有授权应用获得浮窗权限,通话最小化不能正常使用';

  @override
  String get noBackgroundStartPermission => '后台弹出界面权限未获取';

  @override
  String get needBackgroundStartPermission =>
      '你的手机没有授权应用获得后台弹出界面的权限，通话最小化不能正常使用';

  @override
  String get accept => '接听';

  @override
  String get cameraIsOn => '摄像头已开启';

  @override
  String get cameraIsOff => '摄像头已关闭';

  @override
  String get speakerIsOn => '扬声器已开启';

  @override
  String get speakerIsOff => '扬声器已关闭';

  @override
  String get microphoneIsOn => '麦克风已开启';

  @override
  String get microphoneIsOff => '麦克风已关闭';

  @override
  String get chooseMicrophone => '选择麦克风';

  @override
  String get chooseSpeaker => '选择扬声器';

  @override
  String get chooseCamera => '选择摄像头';

  @override
  String get openMicrophone => '打开麦克风';

  @override
  String get closeMicrophone => '关闭麦克风';

  @override
  String get openSpeaker => '打开扬声器';

  @override
  String get closeSpeaker => '关闭扬声器';

  @override
  String get openCamera => '打开摄像头';

  @override
  String get closeCamera => '关闭摄像头';

  @override
  String get blurBackground => '模糊背景';

  @override
  String get switchCamera => '切换摄像头';

  @override
  String get waiting => '等待接听';

  @override
  String get hangUp => '挂断';

  @override
  String get userBusy => '对方占线';

  @override
  String get userInCall => '用户已在通话中';

  @override
  String get answerOnOtherDevice => '其他端已经接听';

  @override
  String get rejectOnOtherDevice => '其他端已经拒绝';

  @override
  String get remoteUserReject => '对方已经拒绝';

  @override
  String get remoteTimeout => '对方超时未响应';

  @override
  String get remoteCancel => '对方取消';

  @override
  String get groupCallInvitation => '群呼邀请';

  @override
  String get groupCallWaiting => '等待接听';

  @override
  String get groupCallInProgress => '通话中';

  @override
  String get groupCallDuration => '通话时长';

  @override
  String get groupCallInvite => '邀请';

  @override
  String get groupCallIgnore => '忽略';

  @override
  String get groupCallJoining => '正在加入...';

  @override
  String get groupCallConnecting => '连接中...';

  @override
  String get groupCallMemberJoined => '已加入';

  @override
  String get groupCallMemberLeft => '已离开';

  @override
  String get groupCallInviteYouToJoin => '邀请你加入群呼';

  @override
  String groupCallOtherMembers(Object count) {
    return '等$count人';
  }

  @override
  String get groupCallToggleMic => '麦克风';

  @override
  String get groupCallToggleCamera => '摄像头';

  @override
  String get groupCallToggleSpeaker => '扬声器';

  @override
  String get groupCallMicOn => '麦克风已开';

  @override
  String get groupCallMicOff => '麦克风已关';

  @override
  String get groupCallSpeakerOn => '扬声器已开';

  @override
  String get groupCallSpeakerOff => '扬声器已关';

  @override
  String get groupCallCameraOn => '摄像头已开';

  @override
  String get groupCallCameraOff => '摄像头已关';

  @override
  String get groupCallSwitchCamera => '切换摄像头';

  @override
  String get groupCallMinimize => '最小化';

  @override
  String get groupCallInviteMore => '邀请更多成员';

  @override
  String get groupCallNoVideo => '对方未开启视频';

  @override
  String get groupCallSpeaking => '正在讲话';

  @override
  String get groupCallMuted => '已静音';

  @override
  String get groupCallInitFailed => '群呼初始化失败';

  @override
  String get groupCallJoinFailed => '加入群呼失败';

  @override
  String get groupCallCreateFailed => '创建群呼失败';

  @override
  String get groupCallNetworkError => '网络错误，请稍后重试';

  @override
  String get groupCallMembersFull => '群呼人数已达上限';

  @override
  String get groupCallEnded => '群呼已结束';

  @override
  String get cancel => '取消';

  @override
  String get goToSettings => '去设置';

  @override
  String get unknownUser => '未知用户';

  @override
  String groupCallOthersInCall(Object count) {
    return '还有 $count 人参与通话：';
  }
}
