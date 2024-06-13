//
//  NIMQChatUserPushNotificationConfig.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMPushNotificationSetting.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  圈组用户配置维度
 */
typedef NS_ENUM(NSInteger, NIMQChatUserPushNotificationConfigType) {
    /**
     *  圈组频道用户配置维度
     */
    NIMQChatUserPushNotificationConfigTypeChannel = 1,
    /**
     *  圈组服务器用户配置维度
     */
    NIMQChatUserPushNotificationConfigTypeServer = 2,
    /**
     *  圈组频道分组用户配置维度
     */
    NIMQChatUserPushNotificationConfigTypeCategory = 3,
};

/**
 *  圈组用户推送配置
 */
@interface NIMQChatUserPushNotificationConfig : NSObject

/**
 *  圈组用户配置维度
 */
@property (nonatomic, assign, readonly) NIMQChatUserPushNotificationConfigType type;

/**
 *  服务器ID
 */
@property (nonatomic, assign, readonly) unsigned long long serverId;

/**
 *  频道ID
 */
@property (nonatomic, assign, readonly) unsigned long long channelId;

/**
 * 频道分组id
 */
@property (nonatomic, assign, readonly) unsigned long long categoryId;

/**
 *  推送等级配置
 */
@property (nonatomic, assign, readonly) NIMPushNotificationProfile profile;

@end

NS_ASSUME_NONNULL_END
