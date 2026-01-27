/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBaseHighAvailableModels.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 高可用服务，可获取域名列表
 */
@interface NEXKitBaseHighAvailableService : NSObject

/// 服务器类型：线上环境
extern const int NEXKitBaseHighAvailableServerTypeOnline;

/// 服务器类型：测试环境
extern const int NEXKitBaseHighAvailableServerTypeTest;

/**
 * 获取单例实例
 * @return 高可用服务实例
 */
+ (instancetype)shared;

/**
 * 初始化高可用服务
 * @param config 初始化配置
 * @return 返回 YES 为成功，NO 为失败
 */
- (BOOL)initWithConfig:(NEXKitBaseHighAvailableInitConfig *)config;

/**
 * 获取可用域名信息
 * @param appKey 应用标识
 * @return 域名信息查询结果
 */
- (NEXKitBaseHighAvailableDomainInfoResult *)getAvailableDomainInfo:(NSString *)appKey;

@end

NS_ASSUME_NONNULL_END
