// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallTypeChangeInfo : NSObject

/// 音视频类型，1 音频  2 视频
@property(nonatomic, assign) NECallType callType;

/// 1 申请切换  2 同意切换  3 拒绝切换
@property(nonatomic, assign) NECallSwitchState state;

@end

NS_ASSUME_NONNULL_END
