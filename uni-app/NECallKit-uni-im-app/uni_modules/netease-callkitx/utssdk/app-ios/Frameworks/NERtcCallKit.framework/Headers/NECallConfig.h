// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NECallConfig : NSObject

/// 支持离线，默认支持离线
@property(nonatomic, assign) BOOL enableOffline;

/// 开启切换视频通话确认，默认不开启
@property(nonatomic, assign) BOOL enableSwitchVideoConfirm;

/// 开启切换音频通话确认，默认不开启
@property(nonatomic, assign) BOOL enableSwitchAudioConfirm;

@end

NS_ASSUME_NONNULL_END
