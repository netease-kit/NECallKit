//
//  NIMQChatRevokeMessageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;
@class NIMQChatUpdateParam;

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询服务器下的申请邀请记录的参数
 */
@interface NIMQChatGetInviteApplyRecordOfServerParam : NSObject <NSCopying>

/**
 * 服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;
/**
 * 开始时间（秒），NSTimeInterval
 */
@property(nullable, nonatomic, copy)NSNumber *fromTime;
/**
 * 结束时间（秒），NSTimeInterval
 */
@property(nullable, nonatomic, copy)NSNumber *toTime;
/**
 * 是否逆序，同历史消息查询，默认从现在查到过去，BOOL
 */
@property(nullable, nonatomic, copy)NSNumber *reverse;
/**
 * 最大数量限制，默认100，最大100，NSUInteger
 */
@property(nullable, nonatomic, copy)NSNumber *limit;
/**
 * 排除id，long
 */
@property(nullable, nonatomic, copy)NSNumber *excludeRecordId;

@end

NS_ASSUME_NONNULL_END
