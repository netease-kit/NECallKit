//
//  V2NIMCustomNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMConversationEnum.h"

@class V2NIMNotificationConfig;
@class V2NIMNotificationPushConfig;
@class V2NIMNotificationAntispamConfig;
@class V2NIMNotificationRouteConfig;

NS_ASSUME_NONNULL_BEGIN

/// 自定义通知
/// SDK只负责传输， 不处理业务逻辑，客户可以采用发送自身相关的业务信息
@interface V2NIMCustomNotification : NSObject
/// 通知发送者账号
@property(nullable,nonatomic,strong,readonly) NSString *senderId;
/// 通知接收者账号
@property(nullable,nonatomic,strong,readonly) NSString *receiverId;
/// 通知所属会话类型
@property(nonatomic,assign,readonly) V2NIMConversationType conversationType;
/// 时间戳，客户设置时间戳
@property(nonatomic,assign,readonly) NSTimeInterval timestamp;
/// 通知内容,最大4096
@property(nullable,nonatomic,strong,readonly) NSString *content;
/// 通知相关配置，具体参见每一个字段定义
@property(nullable,nonatomic,strong,readonly) V2NIMNotificationConfig *notificationConfig;
/// 离线推送配置相关
@property(nullable,nonatomic,strong,readonly) V2NIMNotificationPushConfig *pushConfig;
/// 反垃圾相关配置
@property(nullable,nonatomic,strong,readonly) V2NIMNotificationAntispamConfig *antispamConfig;
/// 反垃圾相关配置
@property(nullable,nonatomic,strong,readonly) V2NIMNotificationRouteConfig *routeConfig;
@end

NS_ASSUME_NONNULL_END
