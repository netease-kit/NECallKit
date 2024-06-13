//
//  NIMQChatUpdateMessageEvent.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  圈组消息更新事件
 */
@interface NIMQChatUpdateMessageEvent : NSObject

/**
 * 消息
 */
@property(nonnull, nonatomic, strong) NIMQChatMessage *message;

/**
 * 消息更改信息
 */
@property(nonnull, nonatomic, strong) NIMQChatUpdateParam *updateParam;

@end

NS_ASSUME_NONNULL_END
