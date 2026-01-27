// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NERtcCallKitPushConfig : NSObject

/// 推送标题，可修改
@property(nonatomic, copy) NSString *pushTitle;

/// 推送内容，可修改
@property(nonatomic, copy) NSString *pushContent;

/// 推送payload内容，可自行添加键值对
@property(nonatomic, strong, readonly) NSMutableDictionary *pushPayload;

@end

NS_ASSUME_NONNULL_END
