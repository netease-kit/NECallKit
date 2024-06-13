//
//  NIMQChatMessageTypingEvent.h
//  NIMLib
//
//  Created by Evang on 2022/4/18.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatMessageTypingEvent : NSObject <NSCopying>

/**
 * 消息所属的服务器ID
 */
@property(nonatomic, assign) unsigned long long  serverId;

/**
 * 消息所属的频道ID
 */
@property(nonatomic, assign) unsigned long long  channelId;

/**
 * 消息自定义扩展字段，推荐使用json格式
 */
@property(nullable, nonatomic, copy) NSString *ext;

/**
 * uuid，由SDK生成
 */
@property(nonatomic, copy, readonly) NSString *uuid;

/**
 * 时间戳
 */
@property (nonatomic, assign, readonly) NSTimeInterval timestamp;

/**
 * 消息发送者的accid, 开发者无需自己传
 */
@property(nullable, nonatomic, copy, readonly) NSString *fromAccount;

/**
 * 发送方昵称, 开发者无需自己传
 */
@property(nullable, nonatomic, copy, readonly) NSString *fromNick;

@end

NS_ASSUME_NONNULL_END
