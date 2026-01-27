// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"
#import "NERtcInfo.h"
#import "NESignalInfo.h"
#import "NEUserInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallInfo : NSObject

/// 呼叫通话唯一Id
@property(nonatomic, strong) NSString *callId;

/// 当前用户IM accId
@property(nonatomic, strong) NSString *currentAccId;

/// 主叫方信息
@property(nonatomic, strong) NEUserInfo *callerInfo;

/// 被叫方信息
@property(nonatomic, strong) NEUserInfo *calleeInfo;

/// 通话类型，1 音频，2 视频
@property(nonatomic, assign) NECallType callType;

/// 信令配置相关参数
@property(nonatomic, strong) NESignalInfo *signalInfo;

/// 音视频频道相关信息
@property(nonatomic, strong) NERtcInfo *rtcInfo;

/// 0 空闲，1 呼叫中 2 正在被呼叫 3 通话中
@property(nonatomic, assign) NECallEngineStatus callStatus;

@end

NS_ASSUME_NONNULL_END
