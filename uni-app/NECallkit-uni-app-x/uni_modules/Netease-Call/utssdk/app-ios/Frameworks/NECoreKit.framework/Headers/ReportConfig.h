// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportConfig : NSObject

@property(nonatomic, strong) NSString *appKey;
// Rtc SDK 版本
@property(nonatomic, strong) NSString *nertcVersion;
// IM SDK 版本
@property(nonatomic, strong) NSString *imVersion;

@property(nonatomic, assign) NSInteger cacheCount;
// 组件平台信息，开发者无需关心
@property(nonatomic, strong) NSString *framework;
// 组件平台信息，开发者无需关心
@property(nonatomic, strong) NSString *channel;

@end

NS_ASSUME_NONNULL_END
