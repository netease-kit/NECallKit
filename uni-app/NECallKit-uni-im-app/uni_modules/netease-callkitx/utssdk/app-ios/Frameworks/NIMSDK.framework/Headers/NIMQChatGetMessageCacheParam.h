//
//  NIMQChatGetMessageCacheParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  从本地缓存查询消息的参数类型
 */
@interface NIMQChatGetMessageCacheParam : NSObject

/**
 * 圈组服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 圈组频道ID
 */
@property(nonatomic, assign) unsigned long long channelId;

/**
 * 是否需要返回引用的消息
 */
@property(nonatomic, assign) BOOL withRefer;

/**
 * 是否需要返回快捷评论
 */
@property(nonatomic, assign) BOOL withQuickComment;

@end

NS_ASSUME_NONNULL_END
