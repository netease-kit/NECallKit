// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'package:pigeon/pigeon.dart';

class SimpleResponse {
  final int code;

  final String? msg;

  final int? data1;

  final int? data2;

  final String? data3;

  SimpleResponse(this.code, this.msg, this.data1, this.data2, this.data3);
}

class CallResponse {
  final int code;

  final String? msg;

  final CallInfo? callInfo;

  CallResponse(this.code, this.msg, this.callInfo);
}

// **************************************************************************

// Live Communication Kit 配置
class LCKConfig {
  final bool enableLiveCommunicationKit; // 是否启用 Live Communication Kit，默认关闭
  final String? ringtoneName; // 铃声名称，可以不填

  LCKConfig({
    this.enableLiveCommunicationKit = false,
    this.ringtoneName,
  });
}

class SetupConfig {
  final String appKey;
  final int? currentUserRtcUid;
  final bool? enableJoinRtcWhenCall;
  final CallInitRtcMode? initRtcMode;
  final LCKConfig? lckConfig; // Live Communication Kit 配置

  SetupConfig({
    required this.appKey,
    this.currentUserRtcUid,
    this.enableJoinRtcWhenCall = false,
    this.initRtcMode = CallInitRtcMode.global,
    this.lckConfig,
  });
}

enum CallInitRtcMode {
  global, //全局初始化 rtc 一次
  inNeed, // 按需初始化，主叫在呼叫时初始化 rtc ，被叫在收到呼叫时初始化 rtc ，通话结束销毁 rtc
  inNeedDelayToAccept // 和inNeed类似，区别在于被叫接听时才初始化 rtc，其他一致
}

// 呼叫参数 - 根据 NECallParam.h 修正
class CallParam {
  final String accId; // 用户id
  final String? extraInfo; // 自定义信息
  final String? rtcChannelName; // RTC房间号
  final String? globalExtraCopy; // 全局抄送信息
  final CallType callType; // 通话类型
  final CallPushConfig? pushConfig; // 推送配置

  CallParam({
    required this.accId,
    this.extraInfo,
    this.rtcChannelName,
    this.globalExtraCopy,
    required this.callType,
    this.pushConfig,
  });
}

// 推送配置 - 根据 NECallPushConfig.h 修正
class CallPushConfig {
  final String? pushTitle; // 推送标题
  final String? pushContent; // 推送内容
  final String? pushPayload; // 推送自定义字段（JSON 字符串）
  final bool needBadge; // 是否计入未读计数，默认YES
  final bool needPush; // 是否需要推送，YES表示推送，NO表示不推送，默认YES

  CallPushConfig({
    this.pushTitle,
    this.pushContent,
    this.pushPayload,
    this.needBadge = true,
    this.needPush = true,
  });
}

// 通话类型枚举
enum CallType {
  none, // 无
  audio, // 音频
  video, // 视频
}

// 用户信息 - 根据 NEUserInfo.h 修正
class UserInfo {
  final String accId; // 用户 accid
  final int uid; // 用户rtc uid

  UserInfo({
    required this.accId,
    required this.uid,
  });
}

// 信令信息 - 根据 NESignalInfo.h 修正
class SignalInfo {
  final String? channelId; // 信令频道Id
  final String? requestId; // 信令邀请唯一标识
  final String? channelName; // 信令通道名称
  final String? extraInfo; // 扩展信息
  final String? globalExtraCopy; // 全局抄送信息

  SignalInfo({
    this.channelId,
    this.requestId,
    this.channelName,
    this.extraInfo,
    this.globalExtraCopy,
  });
}

// RTC信息 - 根据 NERtcInfo.h 修正
class RtcInfo {
  final String? channelName; // rtc 频道名
  final String? token; // rtc token
  final int uid; // rtc uid
  final int cid; // rtc cid

  RtcInfo({
    this.channelName,
    this.token,
    required this.uid,
    required this.cid,
  });
}

// 呼叫信息 - 根据 NECallInfo.h 修正
class CallInfo {
  final String callId; // 呼叫通话唯一Id
  final String currentAccId; // 当前用户IM accId
  final UserInfo? callerInfo; // 主叫方信息
  final UserInfo? calleeInfo; // 被叫方信息
  final CallType callType; // 通话类型
  final SignalInfo? signalInfo; // 信令配置相关参数
  final RtcInfo? rtcInfo; // 音视频频道相关信息
  final CallEngineStatus callStatus; // 通话状态

  CallInfo({
    required this.callId,
    required this.currentAccId,
    this.callerInfo,
    this.calleeInfo,
    required this.callType,
    this.signalInfo,
    this.rtcInfo,
    required this.callStatus,
  });
}

// 通话状态枚举
enum CallEngineStatus {
  idle, // 空闲
  calling, // 呼叫中
  called, // 正在被呼叫
  inCall, // 通话中
}

// 挂断参数 - 根据 NEHangupParam.h 修正
class HangupParam {
  final String? channelId; // 信令通道id
  final String? extraString; // 用户自定义信息

  HangupParam({
    this.channelId,
    this.extraString,
  });
}

// 切换参数 - 根据 NESwitchParam.h 修正
class SwitchParam {
  final CallType callType; // 通话类型
  final CallSwitchState state; // 切换状态

  SwitchParam({
    required this.callType,
    required this.state,
  });
}

// 切换状态枚举
enum CallSwitchState {
  invite, // 邀请
  agree, // 接受
  reject, // 拒绝
}

// 呼叫配置 - 根据 NECallConfig.h 修正
class CallConfig {
  final bool enableOffline; // 支持离线
  final bool enableSwitchVideoConfirm; // 开启切换视频通话确认
  final bool enableSwitchAudioConfirm; // 开启切换音频通话确认

  CallConfig({
    this.enableOffline = true,
    this.enableSwitchVideoConfirm = false,
    this.enableSwitchAudioConfirm = false,
  });
}

// 视图设置参数
class ViewParam {
  final int? viewId; // Flutter 生成的 native view ID

  ViewParam({
    this.viewId,
  });
}

// 邀请信息 - 根据 NEInviteInfo.h 修正
class InviteInfo {
  final String callerAccId; // 呼叫者的accId
  final CallType callType; // 呼叫类型
  final String? extraInfo; // 用户自定义信息
  final String? channelId; // 信令通道id

  InviteInfo({
    required this.callerAccId,
    required this.callType,
    this.extraInfo,
    this.channelId,
  });
}

// 通话结束信息 - 根据 NECallEndInfo.h 修正
class CallEndInfo {
  final CallTerminalCode reasonCode; // 结束原因码
  final String? extraString; // 主叫hangup方法透传被叫字段
  final String? message; // reason 对应的描述信息

  CallEndInfo({
    required this.reasonCode,
    this.extraString,
    this.message,
  });
}

// 通话结束原因枚举
enum CallTerminalCode {
  normal, // 正常流程
  tokenError, // token 请求失败
  timeOut, // 超时
  busy, // 用户占线
  rtcInitError, // rtc 初始化失败
  joinRtcError, // 加入rtc失败
  cancelErrorParam, // cancel 取消参数错误
  callFailed, // 发起呼叫失败
  kicked, // 账号被踢
  emptyUid, // uid 为空
  rtcDisconnected, // Rtc 断连
  callerCancel, // 取消呼叫
  calleeCancel, // 呼叫被取消
  calleeReject, // 拒绝呼叫
  callerRejected, // 呼叫被拒绝
  hangUp, // 挂断呼叫
  beHangUp, // 呼叫被挂断
  otherRejected, // 多端登录被其他端拒绝
  otherAccepted, // 多端登录被其他端接听
  userRtcDisconnected, // Rtc房间断开链接
  userRtcLeave, // 离开Rtc房间
  acceptFail, // 接听失败
}

// 通话类型切换信息 - 根据 NECallTypeChangeInfo.h 修正
class CallTypeChangeInfo {
  final CallType callType; // 音视频类型
  final CallSwitchState state; // 切换状态

  CallTypeChangeInfo({
    required this.callType,
    required this.state,
  });
}

// 话单配置 - 根据 NERecordConfig.h 修正
class RecordConfig {
  final String accId; // 话单接收者accId
  final CallType callType; // 配置话单中的通话类型
  final NIMRtcCallStatus callState; // 话单类型

  RecordConfig({
    required this.accId,
    required this.callType,
    required this.callState,
  });
}

// NIM RTC 通话状态枚举
enum NIMRtcCallStatus {
  completed, // 通话完成
  cancelled, // 通话取消
  rejected, // 通话拒绝
  timeout, // 超时未接听
  busy, // 对方忙线
}

// 虚拟背景状态原因枚举
enum RtcVirtualBackgroundSourceStateReason {
  success, // 成功
  failure, // 失败
  notSupported, // 不支持
}

// ASR 字幕配置 - 根据 NERtcASRCaptionConfig 修正
class NERtcASRCaptionConfig {
  /// 指定字幕的源语言。默认为AUTO
  final String? srcLanguage;

  /// 指定字幕的多个源语言。默认为空
  final List<String?>? srcLanguages;

  /// 指定字幕的目标语言（已废弃，建议使用 dstLanguages）
  final String? dstLanguage;

  /// 指定字幕的目标语言
  final List<String?>? dstLanguages;

  /// 当源语言与设置的目标语言相同时，是否仍要翻译。默认为 false
  final bool? needTranslateSameLanguage;

  NERtcASRCaptionConfig({
    this.srcLanguage,
    this.srcLanguages,
    this.dstLanguage,
    this.dstLanguages,
    this.needTranslateSameLanguage,
  });
}

// ASR 字幕结果 - 根据 NERtcAsrCaptionResult 修正
class NERtcAsrCaptionResult {
  final int uid; // 用户ID
  final bool isLocalUser; // 是否为本地用户
  final int timestamp; // 时间戳
  final String? content; // 识别的文本内容
  final String? language; // 语言
  final bool haveTranslation; // 是否有翻译
  final String? translatedText; // 翻译文本
  final String? translationLanguage; // 翻译语言
  final bool isFinal; // 是否为最终结果

  NERtcAsrCaptionResult({
    required this.uid,
    required this.isLocalUser,
    required this.timestamp,
    this.content,
    this.language,
    required this.haveTranslation,
    this.translatedText,
    this.translationLanguage,
    required this.isFinal,
  });
}

@HostApi(dartHostTestHandler: "CallKitApi")
abstract class CallKitApi {
  @async
  SimpleResponse setup(SetupConfig config);

  String getVersion();

  @async
  CallResponse call(CallParam param);

  @async
  CallResponse accept();

  @async
  SimpleResponse hangup(HangupParam param);

  @async
  SimpleResponse switchCallType(SwitchParam param);

  @async
  SimpleResponse setTimeout(int time);

  @async
  SimpleResponse setupLocalView(ViewParam param);

  @async
  SimpleResponse setupRemoteView(ViewParam param);

  @async
  SimpleResponse enableLocalVideo(bool enable);

  @async
  SimpleResponse muteLocalVideo(bool muted);

  @async
  SimpleResponse muteLocalAudio(bool muted);

  @async
  SimpleResponse switchCamera();

  @async
  bool isSpeakerphoneOn();

  @async
  SimpleResponse setSpeakerphoneOn(bool enable);

  @async
  SimpleResponse setCallConfig(CallConfig config);

  @async
  CallInfo? getCallInfo();

  @async
  CallConfig? getCallConfig();

  @async
  SimpleResponse destroy();

  @async
  SimpleResponse startASRCaption(NERtcASRCaptionConfig config);

  @async
  SimpleResponse stopASRCaption();

  @async
  UserInfo? getUserWithRtcUid(int uid);

  @async
  SimpleResponse setCallRecordProvider(bool enable);
}

// Flutter 回调接口
@FlutterApi()
abstract class CallKitEventSink {
  // NECallEngineDelegate 回调
  void onReceiveInvited(InviteInfo info);
  void onCallEnd(CallEndInfo info);
  void onCallConnected(CallInfo info);
  void onLCKAccept(CallResponse response);
  void onLCKHangup(SimpleResponse response);
  void onCallTypeChange(CallTypeChangeInfo info);
  void onVideoAvailable(bool available, String userID);
  void onVideoMuted(bool muted, String userID);
  void onAudioMuted(bool muted, String userID);
  void onLocalAudioMuted(bool muted);
  void onRtcInitEnd();

  // NERecordProvider 回调
  void onRecordSend(RecordConfig config);

  // NECallEngineRtcDelegateEx 回调
  void onNERtcEngineVirtualBackgroundSourceEnabled(bool enabled, int reason);

  // ASR 字幕回调
  void onAsrCaptionStateChanged(int asrState, int code, String message);
  void onAsrCaptionResult(List<NERtcAsrCaptionResult> result);
}

// ============================================================================
// 群呼 API 协议定义 (Group Call API)
// ============================================================================
//
// API 参考文档:
// - Android: https://doc.yunxin.163.com/nertccallkit/references/android/doxygen/Latest/zh/html/classcom_1_1netease_1_1yunxin_1_1kit_1_1call_1_1group_1_1_n_e_group_call.html
// - iOS: https://doc.yunxin.163.com/docs/interface/nertccallkit/iOS/doxygen/Latest/zh/html/interface_n_e_group_call_kit.html
// ============================================================================

// ============================================================================
// 群呼常量定义 (参考 Android NEGroupConstants)
// ============================================================================

/// 群组类型常量（不是通话类型）
///
/// 用于指定群呼关联的群组类型，不是通话类型（音频/视频）。
abstract class NEGroupCallGroupType {
  /// 讨论组
  static const int NORMAL_TEAM = 1;

  /// 高级群
  static const int ADVANCE_TEAM = 2;

  /// 聊天室
  static const int CHAT_ROOM = 3;
}

/// 用户状态常量
abstract class NEGroupUserState {
  /// 用户处于待接听状态
  static const int WAITING = 1;

  /// 用户已经接听加入多人通话
  static const int JOINED = 2;

  /// 用户离开多人通话
  static const int LEAVING = 3;

  /// 加入等待 RTC
  static const int JOIN_WAIT_RTC = 4;
}

/// 群呼状态常量
abstract class NEGroupCallState {
  /// 无通话状态
  static const int IDLE = 0;

  /// 收到通话邀请
  static const int INVITED = 1;

  /// 呼出通话中
  static const int CALL_OUT = 2;

  /// 正在通话中
  static const int ON_THE_CALL = 3;
}

/// 邀请模式常量
abstract class NEGroupInviteMode {
  /// 任何人都可以邀请他人（默认）
  static const int EVERYONE = 0;

  /// 只有主叫才能邀请他人
  static const int CALLER = 1;
}

/// 加入模式常量
abstract class NEGroupJoinMode {
  /// 每个人都能主动加入此多人通话（默认）
  static const int EVERYONE = 0;

  /// 不能主动加入，需要被动邀请
  static const int ONLY_BE_INVITED = 1;
}

/// 推送模式常量
abstract class NEGroupPushMode {
  /// 关闭推送
  static const int OFF = 0;

  /// 开启推送
  static const int ON = 1;

  /// 强制开启推送
  static const int FORCE_ON = 2;
}

/// RTC 安全模式常量
abstract class NEGroupRtcSafeMode {
  /// RTC 调试模式
  static const int MODE_DEBUG = 0;

  /// RTC 安全模式（默认）
  static const int MODE_SAFE = 1;
}

/// 用户动作常量
abstract class NEGroupUserAction {
  /// 用户接听
  static const String ACCEPT = 'accept';

  /// 用户加入
  static const String JOIN = 'join';

  /// 用户离开
  static const String LEAVE = 'leave';

  /// 用户拒绝
  static const String REJECT = 'reject';
}

/// 挂断原因常量
abstract class NEGroupHangupReason {
  /// 对方占线
  static const String BUSY = 'busy';

  /// 超时
  static const String TIMEOUT = 'timeout';

  /// 其他端接听
  static const String PEER_ACCEPT = 'peerAccept';

  /// 其他端拒绝
  static const String PEER_REJECT = 'peerReject';
}

/// 错误码常量
abstract class NEGroupErrorCode {
  /// 成功
  static const int OK = 0;

  /// 状态错误
  static const int STATE_ERROR = 30001;

  /// 当前群组呼叫信息为空
  static const int GROUP_CALL_INFO_EMPTY = 30002;

  /// 邀请时的 callId 错误
  static const int INVITE_WITH_WRONG_CALL_ID = 30003;

  /// 加入 RTC 房间时错误
  static const int JOIN_RTC_FAILED = 30004;

  /// 未初始化
  static const int NOT_INIT_ERROR = 30005;
}

// ============================================================================
// 群呼配置参数类
// ============================================================================

/// 群呼引擎配置参数
class NEGroupConfigParam {
  final String appKey;
  /// RTC 安全模式：0=调试模式，1=安全模式
  final int? rtcSafeMode;
  final int? timeout;
  final int? currentUserRtcUid;

  NEGroupConfigParam({
    required this.appKey,
    this.rtcSafeMode,
    this.timeout,
    this.currentUserRtcUid,
  });
}

/// 推送配置参数
class NEGroupPushParam {
  final String? pushContent;
  final String? pushPayload;
  final int? pushMode;
  final String? sound;

  NEGroupPushParam({
    this.pushContent,
    this.pushPayload,
    this.pushMode,
    this.sound,
  });
}

/// 发起群呼参数
class NEGroupCallParam {
  final String? callId;
  final List<String?> calleeList;
  final String? groupId;
  final int groupType;
  final int? inviteMode;
  final int? joinMode;
  final String? extraInfo;
  final NEGroupPushParam? pushParam;

  NEGroupCallParam({
    this.callId,
    required this.calleeList,
    this.groupId,
    required this.groupType,
    this.inviteMode,
    this.joinMode,
    this.extraInfo,
    this.pushParam,
  });
}

/// 接听群呼参数
class NEGroupAcceptParam {
  final String callId;

  NEGroupAcceptParam({required this.callId});
}

/// 挂断群呼参数
class NEGroupHangupParam {
  final String callId;
  final String? reason;

  NEGroupHangupParam({
    required this.callId,
    this.reason,
  });
}

/// 邀请成员参数
class NEGroupInviteParam {
  final String callId;
  final List<String?> calleeList;

  NEGroupInviteParam({
    required this.callId,
    required this.calleeList,
  });
}

/// 主动加入参数
class NEGroupJoinParam {
  final String callId;

  NEGroupJoinParam({required this.callId});
}

// ============================================================================
// 群呼数据模型类
// ============================================================================

/// 群呼成员信息
class NEGroupCallMember {
  final String accId;
  final int? rtcUid;
  final int? state;
  final String? action;
  final String? reason;

  NEGroupCallMember({
    required this.accId,
    this.rtcUid,
    this.state,
    this.action,
    this.reason,
  });
}

/// 群呼信息
class NEGroupCallInfo {
  final String callId;
  final String? groupId;
  final int? groupType;
  final String? callerAccId;
  final int? callerRtcUid;
  final List<NEGroupCallMember?>? memberList;
  final int? inviteMode;
  final int? joinMode;
  final String? extraInfo;
  final int? startTimestamp;

  NEGroupCallInfo({
    required this.callId,
    this.groupId,
    this.groupType,
    this.callerAccId,
    this.callerRtcUid,
    this.memberList,
    this.inviteMode,
    this.joinMode,
    this.extraInfo,
    this.startTimestamp,
  });
}

/// 群呼结束事件
class NEGroupCallEndEvent {
  final String callId;
  final int reason;
  final String? message;

  NEGroupCallEndEvent({
    required this.callId,
    required this.reason,
    this.message,
  });
}

/// 成员挂断事件
class NEGroupCallHangupEvent {
  final String callId;
  final int reason;
  final String? message;

  NEGroupCallHangupEvent({
    required this.callId,
    required this.reason,
    this.message,
  });
}

/// 音量信息
class NEAudioVolumeInfo {
  final int uid;
  final int volume;

  NEAudioVolumeInfo({
    required this.uid,
    required this.volume,
  });
}

/// 群呼视图设置参数
class NEGroupViewParam {
  final int? viewId;
  final int? uid;

  NEGroupViewParam({
    this.viewId,
    this.uid,
  });
}

// ============================================================================
// 群呼响应类型
// ============================================================================

/// 群呼简单响应
class GroupSimpleResponse {
  final int code;
  final String? msg;

  GroupSimpleResponse(this.code, this.msg);
}

/// 发起群呼响应
class GroupCallResponse {
  final int code;
  final String? msg;
  final NEGroupCallInfo? callInfo;

  GroupCallResponse(this.code, this.msg, this.callInfo);
}

/// 接听群呼响应
class GroupAcceptResponse {
  final int code;
  final String? msg;
  final NEGroupCallInfo? callInfo;

  GroupAcceptResponse(this.code, this.msg, this.callInfo);
}

/// 加入群呼响应
class GroupJoinResponse {
  final int code;
  final String? msg;
  final NEGroupCallInfo? callInfo;

  GroupJoinResponse(this.code, this.msg, this.callInfo);
}

/// 查询群呼信息响应
class GroupQueryCallInfoResponse {
  final int code;
  final String? msg;
  final NEGroupCallInfo? callInfo;

  GroupQueryCallInfoResponse(this.code, this.msg, this.callInfo);
}

/// 查询成员列表响应
class GroupQueryMembersResponse {
  final int code;
  final String? msg;
  final List<NEGroupCallMember?>? members;

  GroupQueryMembersResponse(this.code, this.msg, this.members);
}

// ============================================================================
// 群呼平台接口定义 (Flutter -> Native)
// ============================================================================

@HostApi(dartHostTestHandler: "GroupCallKitApi")
abstract class GroupCallKitApi {
  /// 初始化群呼引擎
  @async
  GroupSimpleResponse init(NEGroupConfigParam config);

  /// 释放群呼引擎
  @async
  GroupSimpleResponse release();

  /// 发起群呼
  @async
  GroupCallResponse groupCall(NEGroupCallParam param);

  /// 接听群呼
  @async
  GroupAcceptResponse groupAccept(NEGroupAcceptParam param);

  /// 挂断/拒绝群呼
  @async
  GroupSimpleResponse groupHangup(NEGroupHangupParam param);

  /// 邀请新成员
  @async
  GroupSimpleResponse groupInvite(NEGroupInviteParam param);

  /// 主动加入群呼
  @async
  GroupJoinResponse groupJoin(NEGroupJoinParam param);

  /// 查询群呼信息
  @async
  GroupQueryCallInfoResponse groupQueryCallInfo(String callId);

  /// 查询成员列表
  @async
  GroupQueryMembersResponse groupQueryMembers(String callId);

  // ========== 媒体操作接口 ==========

  /// 开关本端视频采集
  @async
  GroupSimpleResponse enableLocalVideo(bool enable);

  /// 静音本端视频发送
  @async
  GroupSimpleResponse muteLocalVideo(bool mute);

  /// 开关本端音频采集和发送
  @async
  GroupSimpleResponse enableLocalAudio(bool enable);

  /// 静音本端音频发送
  @async
  GroupSimpleResponse muteLocalAudio(bool mute);

  /// 设置扬声器开关
  @async
  GroupSimpleResponse setSpeakerphoneOn(bool enable);

  /// 获取扬声器状态
  @async
  bool isSpeakerphoneOn();

  /// 切换前后摄像头
  @async
  GroupSimpleResponse switchCamera();

  /// 设置本端视频画布
  @async
  GroupSimpleResponse setupLocalView(NEGroupViewParam param);

  /// 设置远端成员视频画布
  @async
  GroupSimpleResponse setupRemoteView(NEGroupViewParam param);

  /// 开启/关闭音量回调
  @async
  GroupSimpleResponse enableAudioVolumeIndication(bool enable, int interval);

  /// 设置音视频通话参数
  @async
  GroupSimpleResponse setParameters(Map<String?, Object?> params);
}

// ============================================================================
// 群呼回调接口定义 (Native -> Flutter)
// ============================================================================

/// 群呼业务回调
@FlutterApi()
abstract class GroupCallKitEventSink {
  /// 收到群呼邀请
  void onReceiveGroupInvitation(NEGroupCallInfo info);

  /// 成员列表变更
  void onGroupMemberListChanged(String callId, List<NEGroupCallMember?> members);

  /// 成员挂断回调
  void onGroupCallHangup(NEGroupCallHangupEvent event);

  /// 群呼结束回调
  void onGroupCallEnd(NEGroupCallEndEvent event);
}

/// 媒体事件回调
@FlutterApi()
abstract class GroupMediaEventSink {
  /// 远端用户开启音频
  void onUserAudioStart(int uid);

  /// 远端用户关闭音频
  void onUserAudioStop(int uid);

  /// 远端用户音频静音状态变更
  void onUserAudioMute(int uid, bool muted);

  /// 远端用户开启视频
  void onUserVideoStart(int uid, int maxProfile);

  /// 远端用户关闭视频
  void onUserVideoStop(int uid);

  /// 远端用户视频静音状态变更
  void onUserVideoMute(int uid, bool muted);

  /// 远端用户音量回调
  void onRemoteAudioVolumeIndication(List<NEAudioVolumeInfo?> volumes, int totalVolume);

  /// 与服务器连接中断
  void onDisconnect(int reason);

  /// 音视频组件运行时错误
  void onError(int code);
}

// ============================================================================
// 视频渲染器 API (Texture 方案)
// ============================================================================
//
// 用于替代 PlatformView 方案，提供更高性能的视频渲染。
// 渲染器实现 IVideoRender (Android) / NERtcEngineVideoRenderSink (iOS) 接口，
// 通过 NERtcEx.setupLocalVideoCanvas(renderer) 绑定视频流。
// ============================================================================

@HostApi()
abstract class CallkitVideoRendererApi {
  /// 创建视频渲染器，返回 textureId
  int createVideoRenderer();

  /// 设置镜像
  int setMirror(int textureId, bool mirror);

  /// 绑定为本地视频画布
  int setupLocalVideoRenderer(int textureId);

  /// 绑定为远端视频画布
  int setupRemoteVideoRenderer(int uid, int textureId);

  /// 释放视频渲染器
  void disposeVideoRenderer(int textureId);
}
