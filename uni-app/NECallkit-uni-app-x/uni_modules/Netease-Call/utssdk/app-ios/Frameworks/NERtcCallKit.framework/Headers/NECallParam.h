// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcSDK/NERtcSDK.h>
#import "NECallEngineConsts.h"
#import "NECallPushConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallParam : NSObject

/// 用户id
@property(nonatomic, strong) NSString *accId;

/// 自定义信息
@property(nonatomic, strong, nullable) NSString *extraInfo;

/// RTC房间号
@property(nonatomic, strong, nullable) NSString *rtcChannelName;

/// 全局抄送信息
@property(nonatomic, strong, nullable) NSString *globalExtraCopy;

/// 通话类型
@property(nonatomic, assign) NECallType callType;

/// 推送配置
@property(nonatomic, strong, nullable) NECallPushConfig *pushConfig;

- (instancetype)initWithAccId:(NSString *)accId withCallType:(NECallType)callType;

@end

NS_ASSUME_NONNULL_END
