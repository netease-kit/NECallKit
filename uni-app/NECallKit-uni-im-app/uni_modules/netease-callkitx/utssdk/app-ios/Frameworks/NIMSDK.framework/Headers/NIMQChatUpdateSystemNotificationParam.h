//
//  NIMQChatUpdateSystemNotificationParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatSystemNotification.h"

@class NIMQChatUpdateParam;

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新圈组系统通知的参数
 */
@interface NIMQChatUpdateSystemNotificationParam : NSObject

/**
 * 更新操作通用参数，设置该操作相关的附加字段，设置该操作引发的推送内容，必填
 */
@property (nonnull, nonatomic, copy) NIMQChatUpdateParam * updateParam;

/**
 * 系统通知的服务端ID，必填
 */
@property (nonatomic, assign) unsigned long long msgServerId;

/**
 * 系统通知的类型，必填
 */
@property (nonatomic, assign) NIMQChatSystemNotificationType notificationType;

/**
 * 系统通知内容
 */
@property(nullable, nonatomic, copy) NSString *body;

/**
 * 系统通知自定义扩展字段，推荐使用json格式
 */
@property(nullable, nonatomic, copy) NSString *extension;

/**
 * 系统通知状态，大于等于10000有效
 */
@property(nonatomic, assign) NSInteger status;

@end

NS_ASSUME_NONNULL_END
