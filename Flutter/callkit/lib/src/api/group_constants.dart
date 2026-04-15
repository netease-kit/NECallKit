// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

part of netease_callkit;

// ============================================================================
// 群呼常量定义
// 参考: Android NEGroupConstants
// https://doc.yunxin.163.com/nertccallkit/references/android/doxygen/Latest/zh/html/interfacecom_1_1netease_1_1yunxin_1_1kit_1_1call_1_1group_1_1_n_e_group_constants.html
// ============================================================================

/// 群组类型常量
///
/// 用于指定群呼关联的群组类型。
/// **注意**: 这是群组类型（讨论组/高级群/聊天室），不是通话类型（音频/视频）。
/// 通话类型通过媒体设置控制。
abstract class NEGroupCallGroupType {
  NEGroupCallGroupType._();

  /// 讨论组
  static const int NORMAL_TEAM = 1;

  /// 高级群
  static const int ADVANCE_TEAM = 2;

  /// 聊天室
  static const int CHAT_ROOM = 3;
}

/// 用户状态常量
///
/// 表示群呼成员的当前状态。
abstract class NEGroupUserState {
  NEGroupUserState._();

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
///
/// 表示群呼的整体状态。
abstract class NEGroupCallState {
  NEGroupCallState._();

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
///
/// 控制谁可以邀请新成员加入群呼。
abstract class NEGroupInviteMode {
  NEGroupInviteMode._();

  /// 任何人都可以邀请他人（默认）
  static const int EVERYONE = 0;

  /// 只有主叫才能邀请他人
  static const int CALLER = 1;
}

/// 加入模式常量
///
/// 控制如何加入群呼。
abstract class NEGroupJoinMode {
  NEGroupJoinMode._();

  /// 每个人都能主动加入此多人通话（默认）
  static const int EVERYONE = 0;

  /// 不能主动加入，需要被动邀请
  static const int ONLY_BE_INVITED = 1;
}

/// 推送模式常量
///
/// 控制群呼推送通知行为。
abstract class NEGroupPushMode {
  NEGroupPushMode._();

  /// 关闭推送
  static const int OFF = 0;

  /// 开启推送
  static const int ON = 1;

  /// 强制开启推送
  static const int FORCE_ON = 2;
}

/// RTC 安全模式常量
///
/// 控制 RTC 连接的安全级别。
abstract class NEGroupRtcSafeMode {
  NEGroupRtcSafeMode._();

  /// RTC 调试模式
  static const int MODE_DEBUG = 0;

  /// RTC 安全模式（默认）
  static const int MODE_SAFE = 1;
}

/// 用户动作常量
///
/// 表示用户在群呼中执行的动作。
abstract class NEGroupUserAction {
  NEGroupUserAction._();

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
///
/// 表示用户挂断/离开群呼的原因。
abstract class NEGroupHangupReason {
  NEGroupHangupReason._();

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
///
/// 群呼相关的错误码定义。
abstract class NEGroupErrorCode {
  NEGroupErrorCode._();

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
