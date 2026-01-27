//
//  V2NIMRouteConfig.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 登录抄送环境相关参数
@interface V2NIMRouteConfig : NSObject

/// 是否需要路由消息。（抄送）YES：需要。NO：不需要, 抄送需要打开控制台抄送配置，默认YES
@property(nonatomic,assign) BOOL routeEnabled;

/// 环境变量，用于指向不同的抄送，第三方回调等配置如果不填， 则使用控制台默认抄送地址
@property(nullable,nonatomic,strong) NSString *routeEnvironment;

@end

NS_ASSUME_NONNULL_END
