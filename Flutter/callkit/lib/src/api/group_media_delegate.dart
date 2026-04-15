// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_callkit;

/// 媒体事件回调代理
///
/// 用于监听 NERtc 媒体相关事件，包括：
/// - 远端用户音视频状态变更
/// - 音量回调
/// - 连接状态变更
/// - 运行时错误
///
/// 使用方式：
/// ```dart
/// final delegate = NEGroupMediaDelegate(
///   onUserAudioStart: (uid) {
///     print('用户 $uid 开启音频');
///   },
///   onUserVideoStart: (uid, maxProfile) {
///     print('用户 $uid 开启视频');
///   },
///   onRemoteAudioVolumeIndication: (volumes, totalVolume) {
///     for (var info in volumes) {
///       print('用户 ${info.uid} 音量: ${info.volume}');
///     }
///   },
///   onDisconnect: (reason) {
///     print('连接断开: $reason');
///   },
/// );
///
/// NEGroupCallEngine.instance.addGroupMediaDelegate(delegate);
/// ```
class NEGroupMediaDelegate {
  /// 构造函数
  const NEGroupMediaDelegate({
    this.onUserAudioStart,
    this.onUserAudioStop,
    this.onUserAudioMute,
    this.onUserVideoStart,
    this.onUserVideoStop,
    this.onUserVideoMute,
    this.onRemoteAudioVolumeIndication,
    this.onDisconnect,
    this.onError,
  });

  /// 远端用户开启音频回调
  ///
  /// 当远端用户开启音频采集时触发。
  /// [uid] 用户 RTC UID
  final void Function(int uid)? onUserAudioStart;

  /// 远端用户关闭音频回调
  ///
  /// 当远端用户关闭音频采集时触发。
  /// [uid] 用户 RTC UID
  final void Function(int uid)? onUserAudioStop;

  /// 远端用户音频静音状态变更回调
  ///
  /// 当远端用户静音/取消静音音频发送时触发。
  /// 注意：这只是控制发送，采集可能仍在进行。
  /// [uid] 用户 RTC UID
  /// [muted] 是否静音
  final void Function(int uid, bool muted)? onUserAudioMute;

  /// 远端用户开启视频回调
  ///
  /// 当远端用户开启视频采集时触发。
  /// [uid] 用户 RTC UID
  /// [maxProfile] 视频配置档位
  final void Function(int uid, int maxProfile)? onUserVideoStart;

  /// 远端用户关闭视频回调
  ///
  /// 当远端用户关闭视频采集时触发。
  /// [uid] 用户 RTC UID
  final void Function(int uid)? onUserVideoStop;

  /// 远端用户视频静音状态变更回调
  ///
  /// 当远端用户静音/取消静音视频发送时触发。
  /// 注意：这只是控制发送，采集可能仍在进行。
  /// [uid] 用户 RTC UID
  /// [muted] 是否静音
  final void Function(int uid, bool muted)? onUserVideoMute;

  /// 远端用户音量回调
  ///
  /// 定期返回各远端用户的音量信息。
  /// 需要先调用 [NEGroupCallEngine.enableAudioVolumeIndication] 开启。
  /// [volumes] 各用户的音量信息列表
  /// [totalVolume] 总音量 (0-100)
  final void Function(List<NEAudioVolumeInfo> volumes, int totalVolume)?
      onRemoteAudioVolumeIndication;

  /// 与服务器连接中断回调
  ///
  /// 当网络异常或服务器主动断开连接时触发。
  /// [reason] 断开原因码
  final void Function(int reason)? onDisconnect;

  /// 音视频组件运行时错误回调
  ///
  /// 当 NERtc 运行时发生错误时触发，需要应用层处理。
  /// [code] 错误码
  final void Function(int code)? onError;
}
