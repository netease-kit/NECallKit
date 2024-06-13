//
//  NIMQChatSystemNotificationUpdateResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatUpdateParam;
@class NIMQChatSystemNotification;

/**
 * 圈组系统通知更新同步事件回调参数类型
 */
@interface NIMQChatSystemNotificationUpdateResult: NSObject

@property (nullable, nonatomic, copy, readonly) NIMQChatUpdateParam * updateParam;

@property (nullable, nonatomic, copy, readonly) NIMQChatSystemNotification *systemNotification;

@end
