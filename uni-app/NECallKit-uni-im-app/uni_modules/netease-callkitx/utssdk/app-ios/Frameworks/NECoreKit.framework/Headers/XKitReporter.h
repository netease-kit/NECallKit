// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "BaseReportData.h"
#import "ReportConfig.h"
#import "ReportEvent.h"
#import "ReportModuleInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface XKitReporter : NSObject

@property(nonatomic, strong) NSString *defaultKey;

@property(nonatomic, assign) NSInteger requestTimeOut;

+ (instancetype)shared;

/// 注册模块
/// - Parameters:
///   - serviceName: 模块名称
///   - versionName: 版本
///   - moduleAppKey: appKey
- (void)registerModule:(NSString *)serviceName
           withVersion:(NSString *)versionName
          moduleAppKey:(NSString *)moduleAppKey;

/// 注册模块
/// - Parameters:
///   - serviceName: 模块名称
///   - versionName: 版本
///   - moduleAppKey: appKey
///   - channel: 渠道信息
///   - framework: 渠道信息
- (void)registerModule:(NSString *)serviceName
           withVersion:(NSString *)versionName
          moduleAppKey:(NSString *)moduleAppKey
               channel:(NSString *__nullable)channel
             framework:(NSString *__nullable)framework;

/// 上报 (通过模块信息)
/// - Parameters:
///   - moduleInfo: 模块信息
///   - userId: 用户id
///   - event: 上报的事件
- (void)reportModuleInfo:(ReportModuleInfo *)moduleInfo
                  userId:(NSString *__nullable)userId
                   event:(id<NECoreEvent>)event;

/// 上报 (通过模块名称)
/// - Parameters:
///   - moduleName: 模块名称
///   - userId: 用户id
///   - event: 上报的事件
- (void)reportModuleName:(NSString *)moduleName
                  userId:(NSString *__nullable)userId
                   event:(id<NECoreEvent>)event;

/// 上报对象
/// @param data 数据对象
- (void)report:(nullable BaseReportData *)data;

/// 手动上传并清空缓存队列
- (void)flushAsync;

@end

NS_ASSUME_NONNULL_END
