// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEUserInfo : NSObject

/// 用户 accid
@property(nonatomic, strong) NSString *accId;

/// 用户rtc uid
@property(nonatomic, assign) UInt64 uid;

@end

NS_ASSUME_NONNULL_END
