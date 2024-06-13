//
//  NIMQChatReceiveSystemNotificationResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatSystemNotification;
/**
 * 圈组系统消息接收事件的回调类型
 */
@interface NIMQChatReceiveSystemNotificationResult : NSObject

@property (nullable, nonatomic, copy) NSArray<NIMQChatSystemNotification *> *systemNotifications;

@end

NS_ASSUME_NONNULL_END
