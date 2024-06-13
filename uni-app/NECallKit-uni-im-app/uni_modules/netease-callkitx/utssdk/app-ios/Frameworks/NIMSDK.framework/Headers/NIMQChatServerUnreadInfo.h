//
//  NIMQChatServerUnreadInfo.h
//  NIMLib
//
//  Created by Evang on 2022/6/10.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatServerUnreadInfo : NSObject <NSCopying>

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


@end

NS_ASSUME_NONNULL_END
