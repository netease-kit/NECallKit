// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

/// 群呼成员 UI 数据模型
///
/// 封装单个群呼成员的展示所需信息，包括用户信息、媒体状态、讲话状态等
class GroupCallMemberUI {
  /// 用户 ID (账号 ID，作为成员唯一标识)
  final String userId;

  /// RTC 用户 ID
  /// 用于匹配媒体回调中的 uid
  final int? rtcUid;

  /// 用户昵称
  final String? nickname;

  /// 用户头像 URL
  final String? avatar;

  /// 是否是本地用户（自己）
  final bool isLocal;

  /// 是否已加入通话（已接听）
  final bool isJoined;

  /// 麦克风是否开启
  final bool isMicOn;

  /// 视频流是否已开启（对应 videoStart/videoStop）
  final bool isVideoStarted;

  /// 视频是否静音/暂停（对应 videoMute）
  final bool isVideoMuted;

  /// 是否正在讲话
  final bool isSpeaking;

  const GroupCallMemberUI({
    required this.userId,
    this.rtcUid,
    this.nickname,
    this.avatar,
    this.isLocal = false,
    this.isJoined = false,
    this.isMicOn = false,
    this.isVideoStarted = false,
    this.isVideoMuted = false,
    this.isSpeaking = false,
  });

  /// 摄像头是否真正开启（计算属性）
  /// 只有当视频流已开启且未静音时，才认为摄像头开启
  bool get isCameraOn => isVideoStarted && !isVideoMuted;

  /// 复制并更新部分字段
  GroupCallMemberUI copyWith({
    String? userId,
    int? rtcUid,
    String? nickname,
    String? avatar,
    bool? isLocal,
    bool? isJoined,
    bool? isMicOn,
    bool? isVideoStarted,
    bool? isVideoMuted,
    bool? isSpeaking,
  }) {
    return GroupCallMemberUI(
      userId: userId ?? this.userId,
      rtcUid: rtcUid ?? this.rtcUid,
      nickname: nickname ?? this.nickname,
      avatar: avatar ?? this.avatar,
      isLocal: isLocal ?? this.isLocal,
      isJoined: isJoined ?? this.isJoined,
      isMicOn: isMicOn ?? this.isMicOn,
      isVideoStarted: isVideoStarted ?? this.isVideoStarted,
      isVideoMuted: isVideoMuted ?? this.isVideoMuted,
      isSpeaking: isSpeaking ?? this.isSpeaking,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupCallMemberUI &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          rtcUid == other.rtcUid &&
          nickname == other.nickname &&
          avatar == other.avatar &&
          isLocal == other.isLocal &&
          isJoined == other.isJoined &&
          isMicOn == other.isMicOn &&
          isVideoStarted == other.isVideoStarted &&
          isVideoMuted == other.isVideoMuted &&
          isSpeaking == other.isSpeaking;

  @override
  int get hashCode => Object.hash(
        userId,
        rtcUid,
        nickname,
        avatar,
        isLocal,
        isJoined,
        isMicOn,
        isVideoStarted,
        isVideoMuted,
        isSpeaking,
      );

  @override
  String toString() {
    return 'GroupCallMemberUI{userId: $userId, rtcUid: $rtcUid, nickname: $nickname, isJoined: $isJoined, isMicOn: $isMicOn, isVideoStarted: $isVideoStarted, isVideoMuted: $isVideoMuted, isCameraOn: $isCameraOn, isSpeaking: $isSpeaking}';
  }
}
