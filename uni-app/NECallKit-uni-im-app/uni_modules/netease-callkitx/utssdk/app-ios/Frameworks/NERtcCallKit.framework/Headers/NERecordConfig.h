// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NIMSDK/NIMSDK.h>
#import "NECallEngineConsts.h"
NS_ASSUME_NONNULL_BEGIN

@interface NERecordConfig : NSObject

/// 话单接收者accId
@property(nonatomic, strong) NSString *accId;

/// 配置话单中的通话类型 1 音频 2 视频
@property(nonatomic, assign) NECallType callType;

/// 话单类型， 1 通话完成 2 通话取消 3 通话拒绝 4 超时未接听 5 对方忙线
@property(nonatomic, assign) NIMRtcCallStatus callState;

@end

NS_ASSUME_NONNULL_END
