// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NECallEngineConsts.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECallEndInfo : NSObject

@property(nonatomic, assign) NERtcCallTerminalCode reasonCode;

/// 主叫hangup方法透传被叫字段
@property(nonatomic, strong, nullable) NSString *extraString;

/// reason 对应的描述信息
@property(nonatomic, strong, nullable) NSString *message;

@end

NS_ASSUME_NONNULL_END
