// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh';

  static String m0(count) => "等${count}人";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "accept": MessageLookupByLibrary.simpleMessage("接听"),
    "answerOnOtherDevice": MessageLookupByLibrary.simpleMessage("其他端已经接听"),
    "applyForCameraPermission": MessageLookupByLibrary.simpleMessage("申请摄像头权限"),
    "applyForMicrophoneAndCameraPermissions":
        MessageLookupByLibrary.simpleMessage("申请麦克风、摄像头权限"),
    "applyForMicrophonePermission": MessageLookupByLibrary.simpleMessage(
      "申请麦克风权限",
    ),
    "blurBackground": MessageLookupByLibrary.simpleMessage("模糊背景"),
    "callFailedUserIdEmpty": MessageLookupByLibrary.simpleMessage(
      "呼叫失败，用户ID为空",
    ),
    "cameraIsOff": MessageLookupByLibrary.simpleMessage("摄像头已关闭"),
    "cameraIsOn": MessageLookupByLibrary.simpleMessage("摄像头已开启"),
    "displayPopUpWindowWhileRunningInTheBackgroundAndDisplayPopUpWindowPermissions":
        MessageLookupByLibrary.simpleMessage("请同时打开后台弹出界面和显示悬浮窗权限"),
    "errorInPeerBlacklist": MessageLookupByLibrary.simpleMessage(
      "发起通话失败，用户在黑名单中，禁止发起！",
    ),
    "groupCallConnecting": MessageLookupByLibrary.simpleMessage("连接中..."),
    "groupCallCreateFailed": MessageLookupByLibrary.simpleMessage("创建群呼失败"),
    "groupCallDuration": MessageLookupByLibrary.simpleMessage("通话时长"),
    "groupCallEnded": MessageLookupByLibrary.simpleMessage("群呼已结束"),
    "groupCallIgnore": MessageLookupByLibrary.simpleMessage("忽略"),
    "groupCallInProgress": MessageLookupByLibrary.simpleMessage("通话中"),
    "groupCallInitFailed": MessageLookupByLibrary.simpleMessage("群呼初始化失败"),
    "groupCallInvitation": MessageLookupByLibrary.simpleMessage("群呼邀请"),
    "groupCallInvite": MessageLookupByLibrary.simpleMessage("邀请"),
    "groupCallInviteMore": MessageLookupByLibrary.simpleMessage("邀请更多成员"),
    "groupCallInviteYouToJoin": MessageLookupByLibrary.simpleMessage("邀请你加入群呼"),
    "groupCallJoinFailed": MessageLookupByLibrary.simpleMessage("加入群呼失败"),
    "groupCallJoining": MessageLookupByLibrary.simpleMessage("正在加入..."),
    "groupCallMemberJoined": MessageLookupByLibrary.simpleMessage("已加入"),
    "groupCallMemberLeft": MessageLookupByLibrary.simpleMessage("已离开"),
    "groupCallMembersFull": MessageLookupByLibrary.simpleMessage("群呼人数已达上限"),
    "groupCallMinimize": MessageLookupByLibrary.simpleMessage("最小化"),
    "groupCallMuted": MessageLookupByLibrary.simpleMessage("已静音"),
    "groupCallNetworkError": MessageLookupByLibrary.simpleMessage("网络错误，请稍后重试"),
    "groupCallNoVideo": MessageLookupByLibrary.simpleMessage("对方未开启视频"),
    "groupCallOtherMembers": m0,
    "groupCallSpeaking": MessageLookupByLibrary.simpleMessage("正在讲话"),
    "groupCallSwitchCamera": MessageLookupByLibrary.simpleMessage("切换摄像头"),
    "groupCallToggleCamera": MessageLookupByLibrary.simpleMessage("摄像头"),
    "groupCallToggleMic": MessageLookupByLibrary.simpleMessage("麦克风"),
    "groupCallToggleSpeaker": MessageLookupByLibrary.simpleMessage("扬声器"),
    "groupCallMicOn": MessageLookupByLibrary.simpleMessage("麦克风已开"),
    "groupCallMicOff": MessageLookupByLibrary.simpleMessage("麦克风已关"),
    "groupCallSpeakerOn": MessageLookupByLibrary.simpleMessage("扬声器已开"),
    "groupCallSpeakerOff": MessageLookupByLibrary.simpleMessage("扬声器已关"),
    "groupCallCameraOn": MessageLookupByLibrary.simpleMessage("摄像头已开"),
    "groupCallCameraOff": MessageLookupByLibrary.simpleMessage("摄像头已关"),
    "groupCallWaiting": MessageLookupByLibrary.simpleMessage("等待接听"),
    "hangUp": MessageLookupByLibrary.simpleMessage("挂断"),
    "initEngineFail": MessageLookupByLibrary.simpleMessage("引擎初始化失败"),
    "insufficientPermissions": MessageLookupByLibrary.simpleMessage(
      "新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。",
    ),
    "microphoneIsOff": MessageLookupByLibrary.simpleMessage("麦克风已关闭"),
    "microphoneIsOn": MessageLookupByLibrary.simpleMessage("麦克风已开启"),
    "needBackgroundStartPermission": MessageLookupByLibrary.simpleMessage(
      "你的手机没有授权应用获得后台弹出界面的权限，通话最小化不能正常使用",
    ),
    "needFloatWindowPermission": MessageLookupByLibrary.simpleMessage(
      "你的手机没有授权应用获得浮窗权限,通话最小化不能正常使用",
    ),
    "needToAccessCameraPermission": MessageLookupByLibrary.simpleMessage(
      "需要访问您的摄像头权限，开启后用于视频通话等功能。请点击\"前往设置\"按钮进入权限相关页面，进行设置。",
    ),
    "needToAccessMicrophoneAndCameraPermissions":
        MessageLookupByLibrary.simpleMessage(
          "需要访问您的麦克风和摄像头权限，开启后用于语音通话、视频通话等功能。请点击\"前往设置\"按钮进入权限相关页面，进行设置",
        ),
    "needToAccessMicrophonePermission": MessageLookupByLibrary.simpleMessage(
      "需要访问您的麦克风权限，开启后用于语音通话、视频通话等功能。请点击\"前往设置\"按钮进入权限相关页面，进行设置。",
    ),
    "noBackgroundStartPermission": MessageLookupByLibrary.simpleMessage(
      "后台弹出界面权限未获取",
    ),
    "noFloatWindowPermission": MessageLookupByLibrary.simpleMessage("浮窗权限未获取"),
    "permissionResultFail": MessageLookupByLibrary.simpleMessage("权限校验失败"),
    "rejectOnOtherDevice": MessageLookupByLibrary.simpleMessage("其他端已经拒绝"),
    "remoteCancel": MessageLookupByLibrary.simpleMessage("对方取消"),
    "remoteTimeout": MessageLookupByLibrary.simpleMessage("对方超时未响应"),
    "remoteUserReject": MessageLookupByLibrary.simpleMessage("对方已经拒绝"),
    "speakerIsOff": MessageLookupByLibrary.simpleMessage("扬声器已关闭"),
    "speakerIsOn": MessageLookupByLibrary.simpleMessage("扬声器已开启"),
    "startCameraPermissionDenied": MessageLookupByLibrary.simpleMessage(
      "启动摄像头权限被拒绝",
    ),
    "switchCamera": MessageLookupByLibrary.simpleMessage("切换摄像头"),
    "userBusy": MessageLookupByLibrary.simpleMessage("对方占线"),
    "userInCall": MessageLookupByLibrary.simpleMessage("用户已在通话中"),
    "waiting": MessageLookupByLibrary.simpleMessage("等待接听"),
    "youHaveANewCall": MessageLookupByLibrary.simpleMessage("您有一个新的通话"),
  };
}
