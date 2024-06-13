//
//  NIMQChatGetMessageCacheResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@class NIMQChatMessage;
@class NIMQChatMessageQuickCommentInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  拉取聊天消息的回调类型
 */
@interface NIMQChatGetMessageCacheResult : NSObject
/**
 * 查询结果
 */
@property (nullable, nonatomic, copy) NSArray<NIMQChatMessage *> *messages;

/**
 * 查询结果引用到的消息
 *  @discussion key为消息的messageId。根据返回的消息的replyRefer或threadRefer中的messageId查询
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NIMQChatMessage *> *messagesRefered;

/**
 * 查询结果的快捷评论
 *  @discussion key为消息的serverID
 */
@property (nullable, nonatomic, copy) NSDictionary<NSString *, NIMQChatMessageQuickCommentInfo *> *comments;

@end

NS_ASSUME_NONNULL_END
