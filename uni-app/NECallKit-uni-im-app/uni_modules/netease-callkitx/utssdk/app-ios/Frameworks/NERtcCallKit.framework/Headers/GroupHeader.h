// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#ifndef GroupHeader_h
#define GroupHeader_h

/// 邀请模式
typedef NS_ENUM(NSUInteger, GroupInviteMode) {
  /// 任何人可以邀请
  AnyoneInviteMode = 0,
  /// 发起者才能邀请
  OwnerInviteMode = 1
};

/// 加入模式
typedef NS_ENUM(NSUInteger, GroupJoinMode) {
  /// 任何人都可以加入群聊通话
  JoinModeAnyone = 0,
  /// 只能被邀请
  JoinModeInvited = 1
};

/// 群类型
typedef NS_ENUM(NSUInteger, GroupType) {
  /// 讨论组
  GroupTypeDiscussion = 1,
  /// 高级群
  GroupTypeSenior = 2,
  /// 聊天室
  GroupTypeChatroom = 3
};

/// 用户状态
typedef NS_ENUM(NSInteger, GroupMemberState) {
  /// 等待接听
  GroupMemberStateWaitting = 1,
  /// 已经在房间中
  GroupMemberStateInChannel = 2,
  /// 用户已经挂断
  GroupMemberStateHangup = 3,
  /// 已接收邀请但未在rtc通道中
  GroupMemberStateAccept = 4,
};

/// 推送模式
typedef NS_ENUM(NSInteger, GroupPushMode) {
  /// 关闭
  GroupPushModeClose = 0,
  /// 开启
  GroupPushModeOpen = 1,
  /// 强制推送
  GroupPushModeForce = 2,
};

#pragma mark - 用户行为
/// 用户接受邀请
static NSString *kActionAccept = @"accept";
/// 用户拒绝邀请
static NSString *kActionReject = @"reject";
/// 用户离开
static NSString *kActionLeave = @"leave";
/// 用户加入
static NSString *kActionJoin = @"join";

#pragma mark - 挂断原因
/// 超时
static NSString *kReasonTimeout = @"timeout";
/// 忙线
static NSString *kReasonBusy = @"busy";
/// 其他端接听
static NSString *kReasonPeerAccept = @"peerAccept";
/// 其他端拒绝
static NSString *kReasonPeerReject = @"peerReject";

#endif /* GroupHeader_h */
