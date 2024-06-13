//
//  NIMQChatUpdateSystemNotificationResult.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatSystemNotification;

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新系统通知的回调参数类型
 */
@interface NIMQChatUpdateSystemNotificationResult : NSObject

/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy) NIMQChatSystemNotification *systemNotification;

@end

NS_ASSUME_NONNULL_END
