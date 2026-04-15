// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_callkit;

/// 群呼业务回调代理
///
/// 用于监听群呼业务相关事件，包括：
/// - 收到群呼邀请
/// - 成员列表变更
/// - 成员挂断
/// - 群呼结束
///
/// 使用方式：
/// ```dart
/// final delegate = NEGroupCallEngineDelegate(
///   onReceiveGroupInvitation: (info) {
///     print('收到群呼邀请: ${info.callId}');
///   },
///   onGroupMemberListChanged: (callId, members) {
///     print('成员变更: $callId, 成员数: ${members.length}');
///   },
///   onGroupCallHangup: (event) {
///     print('成员挂断: ${event.callId}');
///   },
///   onGroupCallEnd: (event) {
///     print('群呼结束: ${event.callId}');
///   },
/// );
///
/// NEGroupCallEngine.instance.addGroupCallDelegate(delegate);
/// ```
class NEGroupCallEngineDelegate {
  /// 构造函数
  const NEGroupCallEngineDelegate({
    this.onReceiveGroupInvitation,
    this.onGroupMemberListChanged,
    this.onGroupCallHangup,
    this.onGroupCallEnd,
  });

  /// 收到群呼邀请回调
  ///
  /// 当其他用户发起群呼并邀请当前用户时触发。
  /// [info] 包含群呼的完整信息，包括发起者、成员列表等。
  /// 类型为 Pigeon 生成的 [NEGroupCallInfo]
  final void Function(NEGroupCallInfo info)? onReceiveGroupInvitation;

  /// 成员列表变更回调
  ///
  /// 当群呼中有成员加入、离开或状态变化时触发。
  /// [callId] 群呼唯一标识
  /// [members] 更新后的成员列表，类型为 Pigeon 生成的 [NEGroupCallMember]
  final void Function(String callId, List<NEGroupCallMember> members)?
      onGroupMemberListChanged;

  /// 成员挂断回调
  ///
  /// 当群呼中有成员主动挂断时触发。
  /// 注意：挂断用户的信息需要通过 [onGroupMemberListChanged] 获取，
  /// 因为 [NEGroupCallHangupEvent] 不包含 accId 字段。
  /// 类型为 Pigeon 生成的 [NEGroupCallHangupEvent]
  final void Function(NEGroupCallHangupEvent event)? onGroupCallHangup;

  /// 群呼结束回调
  ///
  /// 当群呼完全结束时触发（所有成员离开或服务端关闭）。
  /// [event] 包含结束原因和描述信息。
  /// 类型为 Pigeon 生成的 [NEGroupCallEndEvent]
  final void Function(NEGroupCallEndEvent event)? onGroupCallEnd;
}
