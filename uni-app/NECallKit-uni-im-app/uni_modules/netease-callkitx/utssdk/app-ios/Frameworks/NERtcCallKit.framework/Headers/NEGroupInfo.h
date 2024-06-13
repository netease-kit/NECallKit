// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "GroupCallMember.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEGroupInfo : NSObject

/// 通话id
@property(nonatomic, strong) NSString *callId;

/// 主叫信息
@property(nonatomic, strong) GroupCallMember *callerInfo;

/// 群id
@property(nonatomic, strong) NSString *groupId;

/// 群类型
@property(nonatomic, assign) NSInteger groupType;

/// 邀请模式，GroupInviteMode
@property(nonatomic, assign) NSInteger inviteMode;

/// 加入模式，GroupJoinMode
@property(nonatomic, assign) NSInteger joinMode;

/// 通话开始时间
@property(nonatomic, assign) NSInteger startTimestamp;

/// 自定义信息
@property(nonatomic, strong) NSString *extraInfo;

@end

NS_ASSUME_NONNULL_END
