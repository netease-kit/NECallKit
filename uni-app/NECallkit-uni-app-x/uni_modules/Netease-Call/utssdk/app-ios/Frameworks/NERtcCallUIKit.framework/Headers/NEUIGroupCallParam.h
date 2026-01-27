// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NERtcCallKit/NERtcCallKit.h>
#import "NEGroupUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface NEUIGroupCallParam : NSObject

#pragma mark - 必要参数

/// 被叫用户列表（用户ID列表）
@property(nonatomic, strong) NSArray<NSString *> *remoteUsers;

#pragma mark - 可选参数

/// 指定通话 id 可选
@property(nonatomic, copy) NSString *callId;

#pragma mark - 推送配置

/// 推送配置参数，默认开启
@property(nonatomic, strong) GroupPushParam *pushParam;

@end

NS_ASSUME_NONNULL_END
