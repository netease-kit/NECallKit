//
//  NIMSystemNotificationSetting.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  自定义系统通知配置
 */
@interface NIMQChatSystemNotificationSetting : NSObject<NSCopying>

/**
 * 是否存离线，只有toAccids不为空，才能设置为存离线，默认NO
 */
@property(nonatomic, assign) BOOL persistEnable;

/**
 * 是否需要推送, 默认NO
 */
@property(nonatomic, assign) BOOL pushEnable;

/**
 * 是否需要系统通知展示角标, 默认YES
 */
@property(nonatomic, assign) BOOL needBadge;

/**
 * 是否需要推送昵称, 默认YES
 */
@property(nonatomic, assign) BOOL needPushNick;

/**
 * 是否需要抄送, 默认YES
 */
@property(nonatomic, assign) BOOL routeEnable;

@end
NS_ASSUME_NONNULL_END
