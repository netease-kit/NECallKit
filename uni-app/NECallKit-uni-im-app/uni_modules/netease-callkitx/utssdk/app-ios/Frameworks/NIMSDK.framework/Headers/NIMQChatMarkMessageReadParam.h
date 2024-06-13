//
//  NIMQChatMarkMessageReadParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  标记消息已读的参数
 */
@interface NIMQChatMarkMessageReadParam : NSObject

/**
 * 圈组服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 圈组频道ID
 */
@property(nonatomic, assign) unsigned long long channelId;

/**
 * 已读时间戳
 */
@property(nonatomic, assign) NSTimeInterval ackTimestamp;

@end

NS_ASSUME_NONNULL_END
