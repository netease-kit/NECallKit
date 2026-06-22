// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// Data models and enums used by the NetEase CallKit Flutter plugin.
///
/// These types are serialized to and from JSON and are used in the public
/// [NECallEngine] API surface.
library netease_callkit_models;

import 'package:json_annotation/json_annotation.dart';

part 'models.g.dart';

// ==================== Enums ====================

/// Defines how the RTC engine should be initialized for calls.
enum NECallInitRtcMode {
  /// Initialize RTC once globally and reuse it across calls.
  @JsonValue(0)
  global,

  /// Lazily initialize RTC when needed (caller on call, callee on invite).
  @JsonValue(1)
  inNeed,

  /// Lazily initialize RTC when the callee accepts the call.
  @JsonValue(2)
  inNeedDelayToAccept,
}

/// Preferred desktop video render path used during RTC initialization.
enum NEDesktopVideoRenderMode {
  /// Let the desktop runtime infer the render mode from available resources.
  @JsonValue(0)
  auto,

  /// Initialize RTC for texture/external-renderer output.
  @JsonValue(1)
  externalRenderer,

  /// Initialize RTC for native platform-window rendering.
  @JsonValue(2)
  platformWindow,
}

/// Type of call.
enum NECallType {
  /// No call type.
  @JsonValue(0)
  none,

  /// Audio-only call.
  @JsonValue(1)
  audio,

  /// Video call.
  @JsonValue(2)
  video,
}

/// Overall status of the call engine.
enum NECallEngineStatus {
  /// Engine is idle; there is no active call.
  @JsonValue(0)
  idle,

  /// Outgoing call is in progress.
  @JsonValue(1)
  calling,

  /// Incoming call is being received.
  @JsonValue(2)
  called,

  /// Call is connected and in progress.
  @JsonValue(3)
  inCall,
}

/// State of switching between call types (audio/video).
enum NECallSwitchState {
  /// A switch invitation has been sent.
  @JsonValue(0)
  invite,

  /// The switch request has been accepted.
  @JsonValue(1)
  agree,

  /// The switch request has been rejected.
  @JsonValue(2)
  reject,
}

/// Reason why a call ended.
///
/// Desktop runtime reuses the same public terminal space as mobile. Multi-
/// client login alignment on desktop is normalized into [kicked],
/// [otherRejected] and [otherAccepted] instead of introducing a
/// desktop-only terminal model.
enum NECallTerminalCode {
  /// Normal termination.
  @JsonValue(0)
  normal,

  /// Failed to obtain or validate token.
  @JsonValue(1)
  tokenError,

  /// Call timed out without being answered.
  @JsonValue(2)
  timeOut,

  /// Callee is busy.
  @JsonValue(3)
  busy,

  /// RTC engine initialization error.
  @JsonValue(4)
  rtcInitError,

  /// Failed to join the RTC channel.
  @JsonValue(5)
  joinRtcError,

  /// Invalid parameters in cancel request.
  @JsonValue(6)
  cancelErrorParam,

  /// Failed to place the call.
  @JsonValue(7)
  callFailed,

  /// Account was kicked offline.
  @JsonValue(8)
  kicked,

  /// UID is empty.
  @JsonValue(9)
  emptyUid,

  /// RTC connection was lost.
  @JsonValue(10)
  rtcDisconnected,

  /// Caller cancelled the call.
  @JsonValue(11)
  callerCancel,

  /// Call was cancelled by the callee.
  @JsonValue(12)
  calleeCancel,

  /// Callee rejected the call.
  @JsonValue(13)
  calleeReject,

  /// Caller was rejected.
  @JsonValue(14)
  callerRejected,

  /// Caller hung up.
  @JsonValue(15)
  hangUp,

  /// Call was hung up by the other side.
  @JsonValue(16)
  beHangUp,

  /// Rejected on another logged-in device.
  @JsonValue(17)
  otherRejected,

  /// Accepted on another logged-in device.
  @JsonValue(18)
  otherAccepted,

  /// User RTC connection was disconnected.
  @JsonValue(19)
  userRtcDisconnected,

  /// User left the RTC channel.
  @JsonValue(20)
  userRtcLeave,

  /// Call accept failed.
  @JsonValue(21)
  acceptFail,
}

/// Status of a call record from NIM RTC.
enum NIMCallStatus {
  /// Call was completed successfully.
  @JsonValue(0)
  completed,

  /// Call was cancelled.
  @JsonValue(1)
  cancelled,

  /// Call was rejected.
  @JsonValue(2)
  rejected,

  /// Call timed out.
  @JsonValue(3)
  timeout,

  /// Callee was busy.
  @JsonValue(4)
  busy,
}

/// Reason for the state of the virtual background feature.
enum NERtcVirtualBackgroundSourceStateReason {
  /// Virtual background is enabled successfully.
  @JsonValue(0)
  success,

  /// Virtual background failed to enable.
  @JsonValue(1)
  failure,

  /// Virtual background is not supported on this device.
  @JsonValue(2)
  notSupported,
}

/// Shared public timeout contract for single-call engines.
class NECallTimeoutPolicy {
  NECallTimeoutPolicy._();

  static const int defaultSeconds = 30;
  static const int maxSeconds = 120;
}

// ==================== Models ====================

/// Basic response model used by the CallKit API.
@JsonSerializable()
class SimpleResponse {
  SimpleResponse({
    required this.code,
    this.msg,
    this.data1,
    this.data2,
    this.data3,
  });

  final int code;
  final String? msg;
  final int? data1;
  final int? data2;
  final String? data3;

  factory SimpleResponse.fromJson(Map<String, dynamic> json) =>
      _$SimpleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$SimpleResponseToJson(this);
}

/// Configuration for Live Communication Kit integration.
@JsonSerializable()
class NELCKConfig {
  NELCKConfig({
    required this.enableLiveCommunicationKit,
    this.ringtoneName,
  });

  final bool enableLiveCommunicationKit;
  final String? ringtoneName;

  factory NELCKConfig.fromJson(Map<String, dynamic> json) =>
      _$NELCKConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NELCKConfigToJson(this);
}

/// Configuration used when setting up the CallKit engine.
@JsonSerializable()
class NESetupConfig {
  NESetupConfig({
    required this.appKey,
    this.currentAccountId,
    this.currentUserRtcUid,
    this.enableJoinRtcWhenCall,
    this.initRtcMode,
    this.desktopVideoRenderMode,
    this.lckConfig,
  });

  final String appKey;
  final String? currentAccountId;
  final int? currentUserRtcUid;
  final bool? enableJoinRtcWhenCall;
  final NECallInitRtcMode? initRtcMode;
  final NEDesktopVideoRenderMode? desktopVideoRenderMode;
  final NELCKConfig? lckConfig;

  factory NESetupConfig.fromJson(Map<String, dynamic> json) =>
      _$NESetupConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NESetupConfigToJson(this);
}

/// Parameters used when placing a call.
@JsonSerializable()
class NECallParam {
  NECallParam({
    required this.accId,
    this.extraInfo,
    this.rtcChannelName,
    this.globalExtraCopy,
    required this.callType,
    this.pushConfig,
  });

  final String accId;
  final String? extraInfo;
  final String? rtcChannelName;
  final String? globalExtraCopy;
  final NECallType callType;
  final NECallPushConfig? pushConfig;

  factory NECallParam.fromJson(Map<String, dynamic> json) =>
      _$NECallParamFromJson(json);

  Map<String, dynamic> toJson() => _$NECallParamToJson(this);
}

/// Push notification configuration for call invites.
@JsonSerializable()
class NECallPushConfig {
  NECallPushConfig({
    this.pushTitle,
    this.pushContent,
    this.pushPayload,
    required this.needBadge,
    required this.needPush,
  });

  final String? pushTitle;
  final String? pushContent;
  final String? pushPayload;
  final bool needBadge;
  final bool needPush;

  factory NECallPushConfig.fromJson(Map<String, dynamic> json) =>
      _$NECallPushConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NECallPushConfigToJson(this);
}

/// Basic user information associated with a call.
@JsonSerializable()
class NEUserInfo {
  NEUserInfo({
    required this.accId,
    required this.uid,
  });

  final String accId;
  final int uid;

  factory NEUserInfo.fromJson(Map<String, dynamic> json) =>
      _$NEUserInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NEUserInfoToJson(this);
}

/// Call-related signaling information.
@JsonSerializable()
class NESignalInfo {
  NESignalInfo({
    this.channelId,
    this.requestId,
    this.channelName,
    this.extraInfo,
    this.globalExtraCopy,
  });

  final String? channelId;
  final String? requestId;
  final String? channelName;
  final String? extraInfo;
  final String? globalExtraCopy;

  factory NESignalInfo.fromJson(Map<String, dynamic> json) =>
      _$NESignalInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NESignalInfoToJson(this);
}

/// RTC information for the call, including channel and user IDs.
@JsonSerializable()
class NERtcInfo {
  NERtcInfo({
    this.channelName,
    this.token,
    required this.channelId,
    required this.uid,
  });

  final String? channelName;
  final String? token;
  final int channelId;
  final int uid;

  factory NERtcInfo.fromJson(Map<String, dynamic> json) =>
      _$NERtcInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NERtcInfoToJson(this);
}

/// High-level information describing the current call.
@JsonSerializable()
class NECallInfo {
  NECallInfo({
    required this.callId,
    required this.currentAccId,
    this.callerInfo,
    this.calleeInfo,
    required this.callType,
    this.signalInfo,
    this.rtcInfo,
    required this.callStatus,
  });

  final String callId;
  final String currentAccId;
  final NEUserInfo? callerInfo;
  final NEUserInfo? calleeInfo;
  final NECallType callType;
  final NESignalInfo? signalInfo;
  final NERtcInfo? rtcInfo;
  final NECallEngineStatus callStatus;

  factory NECallInfo.fromJson(Map<String, dynamic> json) =>
      _$NECallInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NECallInfoToJson(this);
}

/// Parameters used when hanging up a call.
@JsonSerializable()
class NEHangupParam {
  NEHangupParam({
    required this.channelId,
    this.extraString,
  });

  final String channelId;
  final String? extraString;

  factory NEHangupParam.fromJson(Map<String, dynamic> json) =>
      _$NEHangupParamFromJson(json);

  Map<String, dynamic> toJson() => _$NEHangupParamToJson(this);
}

/// Parameters used when switching the call type.
@JsonSerializable()
class NESwitchParam {
  NESwitchParam({
    required this.callType,
    required this.state,
  });

  final NECallType callType;
  final NECallSwitchState state;

  factory NESwitchParam.fromJson(Map<String, dynamic> json) =>
      _$NESwitchParamFromJson(json);

  Map<String, dynamic> toJson() => _$NESwitchParamToJson(this);
}

/// Configuration describing call behavior and capabilities.
@JsonSerializable()
class NECallConfig {
  NECallConfig({
    required this.enableOffline,
    required this.enableSwitchVideoConfirm,
    required this.enableSwitchAudioConfirm,
  });

  final bool enableOffline;
  final bool enableSwitchVideoConfirm;
  final bool enableSwitchAudioConfirm;

  factory NECallConfig.fromJson(Map<String, dynamic> json) =>
      _$NECallConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NECallConfigToJson(this);
}

/// Parameters that describe a platform view used to render video.
@JsonSerializable()
class NEViewParam {
  NEViewParam({
    this.viewId,
  });

  final int? viewId;

  factory NEViewParam.fromJson(Map<String, dynamic> json) =>
      _$NEViewParamFromJson(json);

  Map<String, dynamic> toJson() => _$NEViewParamToJson(this);
}

/// Desktop video capture device descriptor exposed by the desktop bridge.
class NEDesktopVideoDevice {
  const NEDesktopVideoDevice({
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;

  String get displayName => deviceName.isNotEmpty ? deviceName : deviceId;
}

/// Desktop audio device descriptor exposed by the desktop bridge.
class NEDesktopAudioDevice {
  const NEDesktopAudioDevice({
    required this.deviceId,
    required this.deviceName,
  });

  final String deviceId;
  final String deviceName;

  String get displayName => deviceName.isNotEmpty ? deviceName : deviceId;
}

/// Invite information for an incoming call.
@JsonSerializable()
class NEInviteInfo {
  NEInviteInfo({
    required this.callerAccId,
    required this.callType,
    this.callId,
    this.extraInfo,
    this.channelId,
  });

  final String callerAccId;
  final NECallType callType;
  final String? callId;
  final String? extraInfo;
  final String? channelId;

  factory NEInviteInfo.fromJson(Map<String, dynamic> json) =>
      _$NEInviteInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NEInviteInfoToJson(this);
}

/// Result of a Live Communication Kit accept action.
///
/// This callback reports the action result from the iOS system incoming-call UI.
/// It does not mean the call has already reached the connected state.
class NELCKAcceptResult {
  NELCKAcceptResult({
    required this.code,
    this.msg,
    this.callInfo,
  });

  final int code;
  final String? msg;
  final NECallInfo? callInfo;
}

/// Result of a Live Communication Kit hangup action.
///
/// This callback reports the action result from the iOS system incoming-call UI.
/// It does not replace the final `onCallEnd` lifecycle callback.
class NELCKHangupResult {
  NELCKHangupResult({
    required this.code,
    this.msg,
  });

  final int code;
  final String? msg;
}

/// Information describing why and how a call ended.
@JsonSerializable()
class NECallEndInfo {
  NECallEndInfo({
    required this.reasonCode,
    this.callId,
    this.extraString,
    this.message,
  });

  final NECallTerminalCode reasonCode;
  final String? callId;
  final String? extraString;
  final String? message;

  factory NECallEndInfo.fromJson(Map<String, dynamic> json) =>
      _$NECallEndInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NECallEndInfoToJson(this);
}

/// Information describing a call type change event.
@JsonSerializable()
class NECallTypeChangeInfo {
  NECallTypeChangeInfo({
    required this.callType,
    required this.state,
  });

  final NECallType callType;
  final NECallSwitchState state;

  factory NECallTypeChangeInfo.fromJson(Map<String, dynamic> json) =>
      _$NECallTypeChangeInfoFromJson(json);

  Map<String, dynamic> toJson() => _$NECallTypeChangeInfoToJson(this);
}

/// Configuration for a call record entry.
///
/// The public record payload intentionally stays minimal across mobile and
/// desktop: only [accId], [callType] and [callState] are exposed to a custom
/// [NERecordProvider].
@JsonSerializable()
class NERecordConfig {
  NERecordConfig({
    required this.accId,
    required this.callType,
    required this.callState,
  });

  final String accId;
  final NECallType callType;
  final NIMCallStatus callState;

  factory NERecordConfig.fromJson(Map<String, dynamic> json) =>
      _$NERecordConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NERecordConfigToJson(this);
}

/// Configuration for ASR (speech-to-text) captions.
@JsonSerializable()
class NEASRCaptionConfig {
  NEASRCaptionConfig({
    this.srcLanguage,
    this.srcLanguages,
    this.dstLanguage,
    this.dstLanguages,
    this.needTranslateSameLanguage,
  });

  /// Source language of the captions. Defaults to AUTO if not specified.
  final String? srcLanguage;

  /// Multiple possible source languages for captions. Empty by default.
  final List<String?>? srcLanguages;

  /// Target language for captions (deprecated, prefer [dstLanguages]).
  final String? dstLanguage;

  /// Target languages for captions.
  final List<String?>? dstLanguages;

  /// Whether to translate when source and target languages are the same.
  ///
  /// Defaults to `false`.
  final bool? needTranslateSameLanguage;

  factory NEASRCaptionConfig.fromJson(Map<String, dynamic> json) =>
      _$NEASRCaptionConfigFromJson(json);

  Map<String, dynamic> toJson() => _$NEASRCaptionConfigToJson(this);
}

/// Result of a single ASR caption recognition segment.
@JsonSerializable()
class NEAsrCaptionResult {
  NEAsrCaptionResult({
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

  int uid;

  bool isLocalUser;

  int timestamp;

  String? content;

  String? language;

  bool haveTranslation;

  String? translatedText;

  String? translationLanguage;

  bool isFinal;

  factory NEAsrCaptionResult.fromJson(Map<String, dynamic> json) =>
      _$NEAsrCaptionResultFromJson(json);

  Map<String, dynamic> toJson() => _$NEAsrCaptionResultToJson(this);
}
