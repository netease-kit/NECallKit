//
//  V2NIMNotificationServiceProtocol.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"

@class V2NIMCustomNotification;
@class V2NIMSendCustomNotificationParams;
@class V2NIMBroadcastNotification;

@protocol V2NIMNotificationListener;

NS_ASSUME_NONNULL_BEGIN

@protocol V2NIMNotificationService <NSObject>

/**
 *  发送自定义通知
 *
 *  @param converstaionId 会话Id
 *  @param params 自定义通知参数
 *  @param success  成功回调
 *  @param failure  失败回调
 */
- (void)sendCustomNotification:(NSString *)converstaionId
                       content:(NSString *)content
                        params:(V2NIMSendCustomNotificationParams *)params
                       success:(V2NIMSuccessCallback)success
                       failure:(V2NIMFailureCallback)failure;

/**
 *  添加通知监听
 *
 *  @param listener 监听器
 */
- (void)addNoticationListener:(id<V2NIMNotificationListener>)listener;
/**
 *  移除通知监听
 *
 *  @param listener 监听器
 */
- (void)removeNotificationListener:(id<V2NIMNotificationListener>)listener;
@end

/// 消息监听回调
@protocol V2NIMNotificationListener <NSObject>
/**
 *  移除通知监听
 *
 *  @param customNotifications
 */
- (void)onReceiveCustomNotifications:(NSArray <V2NIMCustomNotification *> *)customNotifications;
/**
 *  移除通知监听
 *
 *  @param boradcastNotifications
 */
- (void)onReceiveBroadcastNotifications:(NSArray <V2NIMBroadcastNotification *> *)boradcastNotifications;

@end

NS_ASSUME_NONNULL_END
