//
//  NIMQChatUpdateMessageResult.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新圈组消息的回调参数类型
 */
@interface NIMQChatUpdateMessageResult : NSObject

/**
 * 消息
 */
@property (nullable, nonatomic, strong) NIMQChatMessage *message;

@end

NS_ASSUME_NONNULL_END
