//
//  NIMQChatGetThreadMessagesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@class NIMQChatMessage;
@class NIMQChatMessageThreadInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  拉取Thread内聊天消息的回调类型
 */
@interface NIMQChatGetThreadMessagesResult : NSObject

/**
 * thread信息
 */
@property (nullable, nonatomic, copy) NIMQChatMessageThreadInfo *threadInfo;

/**
 * thread消息
 */
@property (nullable, nonatomic, copy) NIMQChatMessage *threadMessage;

/**
 * thread内消息
 */
@property (nullable, nonatomic, copy) NSArray<NIMQChatMessage *> *messages;

@end

NS_ASSUME_NONNULL_END
