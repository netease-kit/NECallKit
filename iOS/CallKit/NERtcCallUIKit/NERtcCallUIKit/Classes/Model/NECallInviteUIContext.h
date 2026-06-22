// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NECallInviteUIContext : NSObject

/// 当前通话 ID，用于业务页面标识、日志和 API 上报。
@property(nonatomic, copy) NSString *callId;

/// 当前信令房间 ID；业务通常不需要，仅用于调试或 API 上报。
@property(nonatomic, copy, nullable) NSString *channelId;

/// 当前登录用户账号。
@property(nonatomic, copy) NSString *currentUserID;

/// 已在通话中的账号；业务选人页应过滤或置灰。
@property(nonatomic, copy) NSArray<NSString *> *inCallUserIDs;

/// 当前还可邀请的人数；业务选人页应限制最大选择数。
@property(nonatomic, assign) NSInteger remainingCount;

/// 本次通话最大人数，一期默认 10。
@property(nonatomic, assign) NSInteger maxMembers;

@end

NS_ASSUME_NONNULL_END
