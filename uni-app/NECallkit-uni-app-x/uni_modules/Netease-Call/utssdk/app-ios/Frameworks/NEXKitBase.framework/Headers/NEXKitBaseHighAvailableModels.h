/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 高可用服务的初始化配置。
 */
@interface NEXKitBaseHighAvailableInitConfig : NSObject

/// 数据缓存路径，用于缓存 DNS 的解析结果。
@property (nonatomic, strong, nonnull) NSString *path;

/// SDK 版本。
@property (nonatomic, strong, nonnull) NSString *version;

/// 用于切换服务器环境。
@property (nonatomic, strong, nullable) NSNumber *serverType;

/// LBS 服务器地址。
@property (nonatomic, strong, nullable) NSString *lbsServer;

/// 连接超时时间，单位为毫秒。
@property (nonatomic, strong, nullable) NSNumber *connectTimeout;

/// 读取超时时间，单位为毫秒。
@property (nonatomic, strong, nullable) NSNumber *readTimeout;

/// HTTP 请求的线程池大小。
@property (nonatomic, strong, nullable) NSNumber *threadPoolSize;

/// App Key (可选)
@property (nonatomic, strong, nullable) NSString *appKey;

- (NSString *)toJSONString;

@end

/**
 * 域名条目。
 */
@interface NEXKitBaseHighAvailableDomainItem : NSObject

/// 域名
@property (nonatomic, strong) NSString *domain;

@end

/**
 * 可用域名信息。
 */
@interface NEXKitBaseHighAvailableDomainInfo : NSObject

/// 缓存生存时间，单位为秒
@property (nonatomic, assign) long long ttl;

/// 更新时间，单位为毫秒
@property (nonatomic, assign) long long updateTime;

/// 并发数
@property (nonatomic, assign) int racingLimit;

/// 超时时间，单位为毫秒
@property (nonatomic, assign) long long switchTimeout;

/// 域名列表
@property (nonatomic, strong) NSArray<NEXKitBaseHighAvailableDomainItem *> *domainList;

@end

/**
 * 可用域名查询结果。
 */
@interface NEXKitBaseHighAvailableDomainInfoResult : NSObject

/// 错误码，0表示成功。
@property (nonatomic, assign) int code;

/// 错误信息。
@property (nonatomic, strong, nullable) NSString *msg;

/// 域名信息。
@property (nonatomic, strong, nullable) NEXKitBaseHighAvailableDomainInfo *data;

+ (instancetype)fromJSONString:(NSString *)jsonString;

@end

NS_ASSUME_NONNULL_END
