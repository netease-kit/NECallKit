// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_callkit;

/// 群呼引擎接口
///
/// 提供群组音视频通话的核心功能，包括：
/// - 群呼基础操作（发起、接听、拒绝、挂断、邀请、加入）
/// - 媒体操作（音视频控制、扬声器、摄像头、视频画布）
/// - 事件回调管理
///
/// 获取实例：
/// ```dart
/// final engine = NEGroupCallEngine.instance;
/// ```
///
/// 基本使用流程：
/// 1. 初始化引擎
/// ```dart
/// await engine.init(NEGroupConfigParam(appKey: 'your-app-key'));
/// ```
///
/// 2. 注册回调
/// ```dart
/// engine.addGroupCallDelegate(NEGroupCallEngineDelegate(
///   onReceiveGroupInvitation: (info) { /* 处理邀请 */ },
///   onGroupCallEnd: (event) { /* 处理结束 */ },
/// ));
/// ```
///
/// 3. 发起群呼
/// ```dart
/// final result = await engine.groupCall(NEGroupCallParam(
///   calleeList: ['user1', 'user2'],
///   groupType: NEGroupCallGroupType.NORMAL_TEAM,
/// ));
/// ```
///
/// 4. 在成功发起/接听/加入群呼后，可: 
/// - 进行媒体相关操作（如开关音视频、设置画布、扬声器等）。
/// - 邀请新成员加入群呼。
///
/// 5. 释放资源
/// ```dart
/// await engine.release();
/// ```
@HawkEntryPoint()
abstract class NEGroupCallEngine {
  NEGroupCallEngine._();

  /// 获取群呼引擎单例实例
  static NEGroupCallEngine get instance => NEGroupCallEngineImpl.instance;

  // ============================================================================
  // 初始化与释放
  // ============================================================================

  /// 初始化群呼引擎
  ///
  /// 在使用群呼功能前必须先调用此方法进行初始化。
  /// [config] 群呼引擎配置参数
  /// 返回 [NEGroupResult]，code=0 表示成功
  /// 
  /// 注意：初始化群呼引擎前需要确保已经调用 [NECallEngine.setup] 完成单呼引擎初始化。
  Future<NEGroupResult> init(NEGroupConfigParam config);

  /// 释放群呼引擎
  ///
  /// 释放群呼相关资源，不再使用群呼功能时调用。
  /// 返回 [NEGroupResult]，code=0 表示成功
  Future<NEGroupResult> release();

  // ============================================================================
  // 群呼基础操作
  // ============================================================================

  /// 发起群呼
  ///
  /// 创建群组音视频通话并邀请指定用户。
  /// [param] 群呼参数，包含被邀请用户列表、群组类型等
  /// 返回 [NEGroupCallResult]，包含群呼信息
  /// 
  /// 前提条件：已经完成登录操作。
  /// For api test, you can use `DebugService.debugLogin` to login first.
  Future<NEGroupCallResult> groupCall(NEGroupCallParam param);

  /// 接听群呼
  ///
  /// 接受群呼邀请并加入通话。
  /// [param] 接听参数，包含 callId
  /// 返回 [NEGroupAcceptResult]，包含群呼信息
  /// 
  /// 前提条件：已经完成登录操作。
  Future<NEGroupAcceptResult> groupAccept(NEGroupAcceptParam param);

  /// 挂断/拒绝群呼
  ///
  /// 主动挂断离开群呼，或拒绝群呼邀请。
  /// [param] 挂断参数，包含 callId 和可选的挂断原因
  /// 返回 [NEGroupHangupResult]
  /// 
  /// 前提条件：已经完成登录操作。
  Future<NEGroupHangupResult> groupHangup(NEGroupHangupParam param);

  /// 邀请新成员
  ///
  /// 在通话进行中邀请新用户加入群呼。
  /// [param] 邀请参数，包含 callId 和被邀请用户列表
  /// 返回 [NEGroupInviteResult]
  Future<NEGroupInviteResult> groupInvite(NEGroupInviteParam param);

  /// 主动加入群呼
  ///
  /// 主动加入已存在的群呼（需要群呼允许主动加入）。
  /// [param] 加入参数，包含 callId
  /// 返回 [NEGroupJoinResult]，包含群呼信息
  /// 
  /// 前提条件：已经完成登录操作。
  Future<NEGroupJoinResult> groupJoin(NEGroupJoinParam param);

  /// 查询群呼信息
  ///
  /// 获取指定群呼的详细信息。
  /// [callId] 群呼唯一标识
  /// 返回 [NEGroupQueryCallInfoResult]，包含群呼信息
  Future<NEGroupQueryCallInfoResult> groupQueryCallInfo(String callId);

  /// 查询成员列表
  ///
  /// 获取指定群呼的成员列表。
  /// [callId] 群呼唯一标识
  /// 返回 [NEGroupQueryMembersResult]，包含成员列表
  Future<NEGroupQueryMembersResult> groupQueryMembers(String callId);

  // ============================================================================
  // 媒体操作接口
  // ============================================================================
  //
  // 以下媒体操作接口需在成功发起群呼（[groupCall]）、接听群呼（[groupAccept]）
  // 或主动加入群呼（[groupJoin]）之后调用；未进入群呼房间时调用可能无效或返回错误。

  /// 开关本端视频采集
  ///
  /// 控制本地摄像头的开启和关闭。
  /// [enable] true 开启视频采集，false 关闭
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> enableLocalVideo(bool enable);

  /// 静音本端视频发送
  ///
  /// 控制本地视频的发送，不影响采集。
  /// [mute] true 停止发送视频，false 恢复发送
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> muteLocalVideo(bool mute);

  /// 开关本端音频采集和发送
  ///
  /// 控制本地麦克风的开启和关闭。
  /// 默认加入房间后音频开启。
  /// [enable] true 开启音频采集和发送，false 关闭
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> enableLocalAudio(bool enable);

  /// 静音本端音频发送
  ///
  /// 控制本地音频的发送，不影响采集。
  /// [mute] true 停止发送音频，false 恢复发送
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> muteLocalAudio(bool mute);

  /// 设置扬声器开关
  ///
  /// 切换音频输出到扬声器或听筒。
  /// [enable] true 使用扬声器，false 使用听筒
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> setSpeakerphoneOn(bool enable);

  /// 获取扬声器状态
  ///
  /// 返回当前是否使用扬声器输出音频。
  Future<bool> isSpeakerphoneOn();

  /// 切换前后摄像头
  ///
  /// 在前置和后置摄像头之间切换。
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> switchCamera();

  /// 设置本端视频画布
  ///
  /// 设置本地视频预览的渲染视图。
  /// [viewId] Flutter 平台视图 ID
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> setupLocalView(int? viewId);

  /// 设置远端成员视频画布
  ///
  /// 设置指定远端用户视频的渲染视图。
  /// [uid] 用户 RTC UID
  /// [viewId] Flutter 平台视图 ID
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> setupRemoteView(int uid, int? viewId);

  /// 开启/关闭音量回调
  ///
  /// 开启后会定期通过 [NEGroupMediaDelegate.onRemoteAudioVolumeIndication] 回调音量信息。
  /// [enable] true 开启，false 关闭
  /// [interval] 回调间隔时间（毫秒）
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> enableAudioVolumeIndication(
      bool enable, int interval);

  /// 设置音视频通话参数
  ///
  /// 提供技术预览或特别定制功能的参数配置入口。
  /// [params] 参数键值对
  /// 返回 [NEGroupMediaResult]
  Future<NEGroupMediaResult> setParameters(Map<String, dynamic> params);

  // ============================================================================
  // 回调代理管理
  // ============================================================================

  /// 添加群呼业务回调代理
  ///
  /// 注册群呼业务事件监听器。
  /// [delegate] 回调代理实例
  void addGroupCallDelegate(NEGroupCallEngineDelegate delegate);

  /// 移除群呼业务回调代理
  ///
  /// 取消注册群呼业务事件监听器。
  /// [delegate] 要移除的回调代理实例
  void removeGroupCallDelegate(NEGroupCallEngineDelegate delegate);

  /// 添加媒体事件回调代理
  ///
  /// 注册媒体事件监听器。
  /// [delegate] 回调代理实例
  void addGroupMediaDelegate(NEGroupMediaDelegate delegate);

  /// 移除媒体事件回调代理
  ///
  /// 取消注册媒体事件监听器。
  /// [delegate] 要移除的回调代理实例
  void removeGroupMediaDelegate(NEGroupMediaDelegate delegate);
}
