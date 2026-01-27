// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"
NS_ASSUME_NONNULL_BEGIN

@interface NESetupConfig : NSObject

/// app key , 管理后台申请
@property(nonatomic, strong) NSString *appkey;

/// Rtc私有化配置初始化对象，不需要私有化可空
@property(nonatomic, strong, nullable) NERtcEngineContext *rtcInfo;

/// 被叫是否自动加入channel，默认不加入
@property(nonatomic, assign) BOOL enableAutoJoinSignalChannel;

/// 主叫是否在呼叫时加入Rtc，默认不提前加入
@property(nonatomic, assign) BOOL enableJoinRtcWhenCall;

/// 是否在初始化的时候初始化Rtc，默认初始化(Web无此配置)
@property(nonatomic, assign) NECallInitRtcMode initRtcMode;

/// 当前用户rtcUid
@property(nonatomic, assign) uint64_t currentUserUid;

/// 组件平台信息，开发者无需关心
@property(nonatomic, copy) NSString *framework;

/// 组件平台信息，开发者无需关心
@property(nonatomic, copy) NSString *channel;

- (instancetype)initWithAppkey:(NSString *)appkey;

@end

NS_ASSUME_NONNULL_END
