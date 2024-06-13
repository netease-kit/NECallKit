// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcInfo : NSObject

/// rtc 频道名
@property(nonatomic, strong) NSString *channelName;

/// rtc token
@property(nonatomic, strong) NSString *token;

/// rtc uid
@property(nonatomic, assign) long channelId;

@end

NS_ASSUME_NONNULL_END
