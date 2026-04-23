// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';

import 'group_call_member_ui.dart';
import 'group_call_ui_state.dart';

/// 群呼状态管理类
///
/// 使用 ChangeNotifier 管理群呼状态，支持 UI 响应式更新
/// 生命周期由 GroupCallManager 管理，非全局单例
class GroupCallState extends ChangeNotifier {
  /// 当前 UI 状态
  GroupCallUIState _uiState;

  /// 群呼 ID
  final String callId;

  /// 邀请者用户 ID（主叫方）
  final String? callerUserId;

  /// 群呼参与者列表（包括自己）
  List<GroupCallMemberUI> _members = [];

  /// 麦克风状态（初始为关闭）
  bool _isMicrophoneMute = true;

  /// 摄像头状态（初始为关闭）
  bool _isCameraOpen = false;

  /// 扬声器状态（初始为开启）
  bool _isSpeakerOn = true;

  /// 是否处于放大模式
  bool _isEnlargedMode = false;

  /// 放大模式中被放大的成员 userId
  String? _enlargedMemberUserId;

  /// 通话计时器
  Timer? _callTimer;

  /// 通话时长（秒）
  int _callDurationSeconds = 0;

  /// 通话时长通知器（独立更新，不触发整体 UI 重建）
  final ValueNotifier<String> _durationNotifier = ValueNotifier('00:00');

  /// 加入成功的成员数（包括自己）
  int _joinedMemberCount = 0;

  /// 自己是否已加入成功
  bool _selfJoined = false;

  /// 是否已被 dispose
  bool _isDisposed = false;

  /// 是否已被 dispose（公开访问）
  bool get isDisposed => _isDisposed;

  GroupCallState({
    required this.callId,
    required GroupCallUIState initialState,
    required String localUserId,
    this.callerUserId,
  }) : _uiState = initialState {
    // 初始化时添加本地用户到成员列表
    _members = [
      GroupCallMemberUI(
        userId: localUserId,
        isLocal: true,
        isJoined: false,
        isMicOn: !_isMicrophoneMute,
        isVideoStarted: _isCameraOpen,
        isVideoMuted: false,
      ),
    ];

    // 初始状态为 inCall 时直接启动计时器（groupJoin 主动加入场景）
    if (initialState == GroupCallUIState.inCall) {
      startCallTimer();
    }
  }

  // ============= Getters =============

  GroupCallUIState get uiState => _uiState;

  List<GroupCallMemberUI> get members => List.unmodifiable(_members);

  bool get isMicrophoneMute => _isMicrophoneMute;

  bool get isCameraOpen => _isCameraOpen;

  bool get isSpeakerOn => _isSpeakerOn;

  bool get isEnlargedMode => _isEnlargedMode;

  String? get enlargedMemberUserId => _enlargedMemberUserId;

  int get callDurationSeconds => _callDurationSeconds;

  /// 通话时长通知器，用于独立更新时间显示
  ///
  /// UI 组件应使用 ValueListenableBuilder 监听此 notifier，
  /// 这样时间更新不会触发整体 UI 重建
  ValueNotifier<String> get durationNotifier => _durationNotifier;

  String get formattedDuration {
    final hours = _callDurationSeconds ~/ 3600;
    final minutes = (_callDurationSeconds % 3600) ~/ 60;
    final seconds = _callDurationSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  int get joinedMemberCount => _joinedMemberCount;

  bool get selfJoined => _selfJoined;

  // ============= Setters =============

  /// 更新 UI 状态
  void updateUIState(GroupCallUIState newState) {
    if (_uiState != newState) {
      _uiState = newState;
      notifyListeners();

      // 进入通话中状态时启动计时器
      if (newState == GroupCallUIState.inCall) {
        startCallTimer();
      } else {
        stopCallTimer();
      }
    }
  }

  /// 更新成员列表
  void updateMembers(List<GroupCallMemberUI> newMembers) {
    _members = newMembers;
    _updateJoinedCount();
    notifyListeners();
  }

  /// 添加成员
  void addMember(GroupCallMemberUI member) {
    if (!_members.any((m) => m.userId == member.userId)) {
      _members.add(member);
      _updateJoinedCount();
      notifyListeners();
    }
  }

  /// 移除成员
  void removeMember(String userId) {
    _members.removeWhere((m) => m.userId == userId);
    _updateJoinedCount();

    // 如果移除的是当前放大的成员，退出放大模式
    if (_isEnlargedMode && _enlargedMemberUserId == userId) {
      exitEnlargedMode();
    }

    notifyListeners();
  }

  /// 更新单个成员状态
  void updateMemberState({
    required String userId,
    bool? isJoined,
    bool? isMicOn,
    bool? isVideoStarted,
    bool? isVideoMuted,
    bool? isSpeaking,
  }) {
    final index = _members.indexWhere((m) => m.userId == userId);
    if (index >= 0) {
      _members[index] = _members[index].copyWith(
        isJoined: isJoined,
        isMicOn: isMicOn,
        isVideoStarted: isVideoStarted,
        isVideoMuted: isVideoMuted,
        isSpeaking: isSpeaking,
      );
      _updateJoinedCount();
      notifyListeners();
    }
  }

  /// 更新麦克风状态
  void updateMicrophoneState(bool isMute) {
    if (_isMicrophoneMute != isMute) {
      _isMicrophoneMute = isMute;

      // 更新本地成员的麦克风状态
      final localIndex = _members.indexWhere((m) => m.isLocal);
      if (localIndex >= 0) {
        _members[localIndex] = _members[localIndex].copyWith(isMicOn: !isMute);
      }

      notifyListeners();
    }
  }

  /// 更新摄像头状态
  void updateCameraState(bool isOpen) {
    if (_isCameraOpen != isOpen) {
      _isCameraOpen = isOpen;

      // 更新本地成员的视频状态
      final localIndex = _members.indexWhere((m) => m.isLocal);
      if (localIndex >= 0) {
        _members[localIndex] = _members[localIndex].copyWith(
          isVideoStarted: isOpen,
          isVideoMuted: false, // 本地用户开启摄像头时，默认不静音
        );
      }

      notifyListeners();
    }
  }

  /// 更新扬声器状态
  void updateSpeakerState(bool isOn) {
    if (_isSpeakerOn != isOn) {
      _isSpeakerOn = isOn;
      notifyListeners();
    }
  }

  /// 更新成员媒体状态（按 userId 查找）
  ///
  /// 用于更新远端成员的音视频状态和讲话状态
  /// [userId] 用户ID
  /// [isMicOn] 麦克风是否开启（可选）
  /// [isVideoStarted] 视频流是否开启（可选）
  /// [isVideoMuted] 视频是否静音（可选）
  /// [isSpeaking] 是否正在讲话（可选）
  void updateMemberMediaState({
    required String userId,
    bool? isMicOn,
    bool? isVideoStarted,
    bool? isVideoMuted,
    bool? isSpeaking,
  }) {
    final index = _members.indexWhere((m) => m.userId == userId);
    if (index >= 0) {
      _members[index] = _members[index].copyWith(
        isMicOn: isMicOn ?? _members[index].isMicOn,
        isVideoStarted: isVideoStarted ?? _members[index].isVideoStarted,
        isVideoMuted: isVideoMuted ?? _members[index].isVideoMuted,
        isSpeaking: isSpeaking ?? _members[index].isSpeaking,
      );
      notifyListeners();
    }
  }

  /// 更新成员媒体状态（按 rtcUid 查找）
  ///
  /// 用于处理媒体回调时按 RTC uid 查找并更新成员状态
  /// [rtcUid] RTC 用户 ID
  /// [isMicOn] 麦克风是否开启（可选）
  /// [isVideoStarted] 视频流是否开启（可选）
  /// [isVideoMuted] 视频是否静音（可选）
  /// [isSpeaking] 是否正在讲话（可选）
  void updateMemberMediaStateByRtcUid({
    required int rtcUid,
    bool? isMicOn,
    bool? isVideoStarted,
    bool? isVideoMuted,
    bool? isSpeaking,
  }) {
    final index = _members.indexWhere((m) => m.rtcUid == rtcUid);
    if (index >= 0) {
      _members[index] = _members[index].copyWith(
        isMicOn: isMicOn ?? _members[index].isMicOn,
        isVideoStarted: isVideoStarted ?? _members[index].isVideoStarted,
        isVideoMuted: isVideoMuted ?? _members[index].isVideoMuted,
        isSpeaking: isSpeaking ?? _members[index].isSpeaking,
      );
      notifyListeners();
    }
  }

  /// 根据 rtcUid 查找成员的 userId
  ///
  /// 用于将媒体回调中的 rtcUid 映射为 userId
  /// 返回 null 表示未找到对应成员
  String? findUserIdByRtcUid(int rtcUid) {
    final member = _members.firstWhere(
      (m) => m.rtcUid == rtcUid,
      orElse: () => const GroupCallMemberUI(userId: ''),
    );
    return member.userId.isNotEmpty ? member.userId : null;
  }

  /// 进入放大模式
  void enterEnlargedMode(String userId) {
    _isEnlargedMode = true;
    _enlargedMemberUserId = userId;
    notifyListeners();
  }

  /// 退出放大模式
  void exitEnlargedMode() {
    _isEnlargedMode = false;
    _enlargedMemberUserId = null;
    notifyListeners();
  }

  /// 切换放大的成员
  void switchEnlargedMember(String userId) {
    if (_isEnlargedMode) {
      _enlargedMemberUserId = userId;
      notifyListeners();
    }
  }

  // ============= Timer Management =============

  /// 启动通话计时器
  void startCallTimer() {
    if (_callTimer != null && _callTimer!.isActive) {
      return;
    }

    _callDurationSeconds = 0;
    _durationNotifier.value = formattedDuration;
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      _callDurationSeconds++;
      // 只更新时间通知器，不触发整体 UI 重建
      _durationNotifier.value = formattedDuration;
    });
  }

  /// 停止通话计时器
  void stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  /// 更新加入成功的成员数量
  void _updateJoinedCount() {
    _joinedMemberCount = _members.where((m) => m.isJoined).length;
    _selfJoined = _members.any((m) => m.isLocal && m.isJoined);
  }

  // ============= 状态迁移方法 =============

  /// 根据群呼信息更新状态
  /// 实现 UI 状态自动迁移逻辑
  void updateFromCallInfo({
    required int totalMembers,
    required int joinedMembers,
    required bool isSelfJoined,
  }) {
    _selfJoined = isSelfJoined;
    _joinedMemberCount = joinedMembers;

    // 状态迁移规则：
    // calling -> inCall: 至少有一个被叫加入成功
    if (_uiState == GroupCallUIState.calling && joinedMembers >= 2) {
      updateUIState(GroupCallUIState.inCall);
    }

    // incoming -> inCall: 自己接听后进入通话中
    if (_uiState == GroupCallUIState.incoming && isSelfJoined) {
      updateUIState(GroupCallUIState.inCall);
    }

    notifyListeners();
  }

  @override
  void notifyListeners() {
    if (_isDisposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    stopCallTimer();
    _durationNotifier.dispose();
    super.dispose();
  }
}
