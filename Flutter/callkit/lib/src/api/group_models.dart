// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_callkit;

// ============================================================================
// 群呼结果类型
// Pigeon 生成的参数和数据模型类直接通过 pigeon.dart 导出使用
// ============================================================================

/// 群呼通用结果
class NEGroupResult {
  /// 响应码 (0=成功)
  final int code;

  /// 消息
  final String? msg;

  const NEGroupResult({
    required this.code,
    this.msg,
  });

  /// 是否成功
  bool get isSuccess => code == 0;
}

/// 发起群呼结果
class NEGroupCallResult extends NEGroupResult {
  /// 群呼信息
  final NEGroupCallInfo? callInfo;

  const NEGroupCallResult({
    required super.code,
    super.msg,
    this.callInfo,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupCallResult.fromPigeon(GroupCallResponse response) {
    return NEGroupCallResult(
      code: response.code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }
}

/// 接听群呼结果
class NEGroupAcceptResult extends NEGroupResult {
  /// 群呼信息
  final NEGroupCallInfo? callInfo;

  const NEGroupAcceptResult({
    required super.code,
    super.msg,
    this.callInfo,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupAcceptResult.fromPigeon(GroupAcceptResponse response) {
    return NEGroupAcceptResult(
      code: response.code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }
}

/// 加入群呼结果
class NEGroupJoinResult extends NEGroupResult {
  /// 群呼信息
  final NEGroupCallInfo? callInfo;

  const NEGroupJoinResult({
    required super.code,
    super.msg,
    this.callInfo,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupJoinResult.fromPigeon(GroupJoinResponse response) {
    return NEGroupJoinResult(
      code: response.code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }
}

/// 邀请成员结果
class NEGroupInviteResult extends NEGroupResult {
  const NEGroupInviteResult({
    required super.code,
    super.msg,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupInviteResult.fromPigeon(GroupSimpleResponse response) {
    return NEGroupInviteResult(
      code: response.code,
      msg: response.msg,
    );
  }
}

/// 挂断群呼结果
class NEGroupHangupResult extends NEGroupResult {
  const NEGroupHangupResult({
    required super.code,
    super.msg,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupHangupResult.fromPigeon(GroupSimpleResponse response) {
    return NEGroupHangupResult(
      code: response.code,
      msg: response.msg,
    );
  }
}

/// 查询群呼信息结果
class NEGroupQueryCallInfoResult extends NEGroupResult {
  /// 群呼信息
  final NEGroupCallInfo? callInfo;

  const NEGroupQueryCallInfoResult({
    required super.code,
    super.msg,
    this.callInfo,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupQueryCallInfoResult.fromPigeon(
      GroupQueryCallInfoResponse response) {
    return NEGroupQueryCallInfoResult(
      code: response.code,
      msg: response.msg,
      callInfo: response.callInfo,
    );
  }
}

/// 查询成员列表结果
class NEGroupQueryMembersResult extends NEGroupResult {
  /// 成员列表
  final List<NEGroupCallMember>? members;

  const NEGroupQueryMembersResult({
    required super.code,
    super.msg,
    this.members,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupQueryMembersResult.fromPigeon(
      GroupQueryMembersResponse response) {
    return NEGroupQueryMembersResult(
      code: response.code,
      msg: response.msg,
      members: response.members?.whereType<NEGroupCallMember>().toList(),
    );
  }
}

/// 媒体操作结果（仅包含 code 和 msg）
class NEGroupMediaResult extends NEGroupResult {
  const NEGroupMediaResult({
    required super.code,
    super.msg,
  });

  /// 从 Pigeon 响应创建
  factory NEGroupMediaResult.fromPigeon(GroupSimpleResponse response) {
    return NEGroupMediaResult(
      code: response.code,
      msg: response.msg,
    );
  }
}
