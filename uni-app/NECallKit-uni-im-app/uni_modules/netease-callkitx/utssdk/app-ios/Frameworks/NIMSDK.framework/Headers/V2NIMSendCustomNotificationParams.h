//
//  V2NIMSendCustomNotificationParams.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMNotificationConfig;
@class V2NIMNotificationPushConfig;
@class V2NIMNotificationAntispamConfig;
@class V2NIMNotificationRouteConfig;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMSendCustomNotificationParams : NSObject
/// 通知相关配置，具体参见每一个字段定义
@property(nonatomic,strong) V2NIMNotificationConfig *notificationConfig;
/// 离线推送配置相关
@property(nonatomic,strong) V2NIMNotificationPushConfig *pushConfig;
/// 反垃圾相关配置是路由抄送相关配置
@property(nonatomic,strong) V2NIMNotificationAntispamConfig *antispamConfig;
/// 离线推送配置相关
@property(nonatomic,strong) V2NIMNotificationRouteConfig *routeConfig;
@end

NS_ASSUME_NONNULL_END
