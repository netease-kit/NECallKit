// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"
NS_ASSUME_NONNULL_BEGIN

@interface NESwitchParam : NSObject

/// 通话类型
@property(nonatomic, assign) NECallType callType;

/// 切换状态，在开启音视频切换需确认配置条件下 1 发起切换请求  2 同意切换  3 拒绝切换
@property(nonatomic, assign) NECallSwitchState state;

@end

NS_ASSUME_NONNULL_END
