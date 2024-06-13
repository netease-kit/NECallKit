//
//  NIMQChatUpdateMessageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;
@class NIMQChatUpdateMessageInfo;
@class NIMQChatUpdateParam;

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新圈组消息的参数
 */
@interface NIMQChatUpdateMessageParam : NSObject

/**
 * 更新操作目标消息，必填
 */
@property(nonnull, nonatomic, strong) NIMQChatMessage *message;

/**
 * 更新内容，必填
 */
@property(nonnull, nonatomic, strong) NIMQChatUpdateMessageInfo *updateInfo;

/**
 * 更新操作通用参数，设置该操作相关的附加字段，设置该操作引发的推送内容，必填
 */
@property(nonnull, nonatomic, strong) NIMQChatUpdateParam *updateParam;

@end

NS_ASSUME_NONNULL_END
