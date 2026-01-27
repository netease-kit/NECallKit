//
//  V2NIMNotificationRouteConfig.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 路由抄送相关配置
@interface V2NIMNotificationRouteConfig : NSObject
/// 是否需要路由通知。（抄送）true：需要。false：不需要
@property(nonatomic,assign,readwrite) BOOL routeEnabled;
/// 环境变量，用于指向不同的抄送，第三方回调等配置
@property(nonatomic,strong,readwrite) NSString *routeEnvironment;
@end

NS_ASSUME_NONNULL_END
