//
//  NIMQChatGetMessageHistoryResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>

@class NIMQChatMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  拉取聊天消息的回调类型
 */
@interface NIMQChatGetMessageHistoryResult : NSObject
/**
 * 查询结果
 */
@property (nullable, nonatomic, copy) NSArray<NIMQChatMessage *> *messages;

@end

NS_ASSUME_NONNULL_END
