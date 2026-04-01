// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:netease_callkit/netease_callkit.dart';
import '../utils/callkit_ui_log.dart';

/// 讲话状态管理器
///
/// 负责处理音量回调并判断用户是否正在讲话：
/// - 音量阈值: >= 20 判定为正在讲话
/// - 超时时间: 1秒无音量回调则重置讲话状态
/// - 本地用户不显示讲话状态
class SpeakingStateManager {
  static const String _tag = 'SpeakingStateManager';

  /// 音量阈值（音量值 >= 20 判定为正在讲话）
  static const int _volumeThreshold = 20;

  /// 讲话状态超时时间（1秒）
  static const Duration _speakingTimeout = Duration(seconds: 1);

  /// 用户讲话状态 Map (userId -> isSpeaking)
  final Map<String, bool> _speakingStates = {};

  /// 用户讲话状态超时定时器 Map (userId -> Timer)
  final Map<String, Timer> _speakingTimers = {};

  /// 本地用户 ID（本地用户不显示讲话状态）
  String? _localUserId;

  /// 讲话状态变更回调
  final void Function(String userId, bool isSpeaking)? onSpeakingStateChanged;

  SpeakingStateManager({
    this.onSpeakingStateChanged,
  });

  /// 设置本地用户 ID
  void setLocalUserId(String userId) {
    _localUserId = userId;
  }

  /// 处理音量回调
  ///
  /// [volumes] 各用户的音量信息列表
  /// [totalVolume] 总音量 (0-100)
  void handleVolumeIndication(List<NEAudioVolumeInfo> volumes, int totalVolume) {
    for (final volumeInfo in volumes) {
      final userId = volumeInfo.uid.toString(); // 将 RTC UID 转为字符串
      final volume = volumeInfo.volume;

      // 本地用户不显示讲话状态
      if (userId == _localUserId) {
        continue;
      }

      final isSpeaking = volume >= _volumeThreshold;
      final currentState = _speakingStates[userId] ?? false;

      // 状态变更时触发回调
      if (isSpeaking != currentState) {
        _speakingStates[userId] = isSpeaking;
        onSpeakingStateChanged?.call(userId, isSpeaking);
        CallKitUILog.d(_tag, 'handleVolumeIndication: userId=$userId, isSpeaking=$isSpeaking, volume=$volume');
      }

      // 重置超时定时器
      if (isSpeaking) {
        _resetSpeakingTimer(userId);
      }
    }
  }

  /// 重置讲话状态超时定时器
  void _resetSpeakingTimer(String userId) {
    // 取消旧定时器
    _speakingTimers[userId]?.cancel();

    // 创建新定时器
    _speakingTimers[userId] = Timer(_speakingTimeout, () {
      // 超时后重置讲话状态
      final currentState = _speakingStates[userId] ?? false;
      if (currentState) {
        _speakingStates[userId] = false;
        onSpeakingStateChanged?.call(userId, false);
        CallKitUILog.d(_tag, '_resetSpeakingTimer: userId=$userId timeout, reset to false');
      }
      _speakingTimers.remove(userId);
    });
  }

  /// 清除指定用户的讲话状态
  void clearUserState(String userId) {
    _speakingTimers[userId]?.cancel();
    _speakingTimers.remove(userId);
    _speakingStates.remove(userId);
  }

  /// 清除所有讲话状态
  void clearAll() {
    for (final timer in _speakingTimers.values) {
      timer.cancel();
    }
    _speakingTimers.clear();
    _speakingStates.clear();
  }

  /// 获取用户当前讲话状态
  bool isSpeaking(String userId) {
    return _speakingStates[userId] ?? false;
  }

  /// 释放资源
  void dispose() {
    clearAll();
  }
}
