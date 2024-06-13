//
//  NIMQChatGetMessageHistoryParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  从服务端查询历史消息的参数类型
 */
@interface NIMQChatGetMessageHistoryParam : NSObject

/**
 * 圈组服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 圈组频道ID
 */
@property(nonatomic, assign) unsigned long long channelId;

/**
 * 起始时间 - NSTimeInterval
 * 起始时间 < 结束时间
 */
@property(nonatomic, assign) NSTimeInterval fromTime;

/**
 * 结束时间 - NSTimeInterval
 * 结束时间 > 起始时间
 */
@property(nonatomic, copy) NSNumber *toTime;

/**
 * 需要排除的消息服务端ID - unsigned long long
 * 如果reverse为NO，则查询起点为toTime；如果reverse为YES，则查询起点为fromTime
 * 如果查询起点上有多条消息，可以通过excludeMsgId来指定实际的起始消息为excludeMsgId对应的消息的下一条
 */
@property(nonatomic, copy) NSNumber *excludeMsgId;

/**
 * 条数限制 - NSInteger
 */
@property(nonatomic, copy) NSNumber *limit;

/**
 * 是否反向 - BOOL
 * NO(默认)：从toTime往fromTime查询，不包括fromTime上的消息，包括toTime上的消息
 * YES：从fromTime往toTime查询，包括fromTime上的消息，包括toTime上的消息
 */
@property(nonatomic, copy) NSNumber *reverse;

@end

NS_ASSUME_NONNULL_END
