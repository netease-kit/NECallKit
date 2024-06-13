// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ReportEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECorePVInfoEvent : NSObject <NECoreEvent>

/// 用户标识
@property(nonatomic, strong, nullable) NSString *user;
/// 当前页面
@property(nonatomic, strong, nullable) NSString *page;
/// 扩展信息
@property(nonatomic, strong, nullable) NSString *extra;
/// 事件名称
@property(nonatomic, strong) NSString *eventName;
/// 前一个页面
@property(nonatomic, strong, nullable) NSString *prePage;
/// accid
@property(nonatomic, strong, nullable) NSString *accid;

@end

NS_ASSUME_NONNULL_END
