// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NEGroupCallInfo.h"
#import "NEGroupInfo.h"
NS_ASSUME_NONNULL_BEGIN

@interface GroupBaseResult : NSObject

/// 错误码
@property(nonatomic, assign) NSInteger code;

@end

@interface GroupCallResult : GroupBaseResult

/// 通话id
@property(nonatomic, strong) NSString *callId;

/// 主叫id
@property(nonatomic, assign) NSInteger callerUid;

/// 通话发起时间
@property(nonatomic, assign) NSInteger startTimestamp;

/// 信令通道id
@property(nonatomic, assign) uint64_t channelId;

@end

@interface GroupHangupResult : GroupBaseResult

/// 通话id
@property(nonatomic, strong) NSString *callId;

/// 挂断原因
@property(nonatomic, assign) NSInteger reason;

@end

@interface GroupAcceptResult : GroupBaseResult

/// 多人通话信息
@property(nonatomic, strong) NEGroupCallInfo *groupCallInfo;

/// 信令通道id
@property(nonatomic, assign) uint64_t channelId;

@end

@interface GroupInviteResult : GroupBaseResult

/// 通话id
@property(nonatomic, strong) NSString *callId;

@end

@interface GroupJoinResult : GroupBaseResult

/// 多人通话信息
@property(nonatomic, strong) NEGroupCallInfo *groupCallInfo;

/// 信令通道id
@property(nonatomic, assign) uint64_t channelId;

@end

@interface GroupQueryCallInfoResult : GroupBaseResult

/// 多人通话信息
@property(nonatomic, strong) NEGroupInfo *groupCallInfo;

@end

@interface GroupQueryMembersResult : GroupBaseResult

/// 通话id
@property(nonatomic, strong) NSString *callId;

/// 多人通话信息
@property(nonatomic, strong) GroupCallMember *callerInfo;

/// 被叫列表
@property(nonatomic, strong) NSArray<GroupCallMember *> *calleeList;

@end

NS_ASSUME_NONNULL_END
