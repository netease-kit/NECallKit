// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NECallPushConfig : NSObject

/// 推送标题
@property(nonatomic, strong) NSString *pushTitle;

/// 推送内容
@property(nonatomic, strong) NSString *pushContent;

/// 推送自定义字段
@property(nonatomic, strong) NSMutableDictionary *pushPayload;

/// 是否计入未读计数，默认YES
@property(nonatomic, assign) BOOL needBadge;

/// 是否需要推送，YES表示推送，NO表示不推送，默认YES
@property(nonatomic, assign) BOOL needPush;

@end

NS_ASSUME_NONNULL_END
