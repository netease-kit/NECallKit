//
//  NIMQChatUnreadInfo.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  圈组未读信息
 */
@interface NIMQChatUnreadInfo : NSObject

/**
 * 频道ID
 */
@property(nonatomic, assign, readonly) unsigned long long channelId;

/**
 * 服务器ID
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;

/**
 * 未读数
 */
@property(nonatomic, assign, readonly) NSUInteger unreadCount;

/**
 * @的未读数
 */
@property(nonatomic, assign, readonly) NSUInteger mentionedCount;

/**
 * 最大未读数
 */
@property(nonatomic, assign, readonly) NSUInteger maxCount;

/**
 * 已读时间戳
 */
@property(nonatomic, assign, readonly) NSTimeInterval ackTimestamp;

/**
 * 最新消息时间戳
 */
@property(nonatomic, assign, readonly) NSTimeInterval lastMessageTimestamp;

/**
 * 数据时间戳
 */
@property(nonatomic, assign, readonly) NSTimeInterval timestamp;


@end

NS_ASSUME_NONNULL_END
