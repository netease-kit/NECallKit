//
//  NIMQChatMarkSystemNotificationsReadParam.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatSystemNotification.h"

/**
 *  标记系统通知已读的参数中一项的类型
 */
@interface NIMQChatMarkSystemNotificationsReadItem : NSObject <NSCopying>

@property(nonatomic, assign) unsigned long long messageServerId;

@property(nonatomic, assign) NIMQChatSystemNotificationType type;

@end

/**
 *  标记系统通知已读的参数
 */
@interface NIMQChatMarkSystemNotificationsReadParam : NSObject <NSCopying>

@property(nonnull, nonatomic, copy) NSArray<NIMQChatMarkSystemNotificationsReadItem *> *items;

@end
