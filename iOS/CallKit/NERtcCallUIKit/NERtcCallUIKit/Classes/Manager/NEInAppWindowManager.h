// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 应用内小窗管理器
@interface NEInAppWindowManager : NSObject

/// 单例
+ (instancetype)sharedInstance;

/// 显示应用内小窗（自动从 NECallStateManager 获取通话类型）
- (void)showInAppSmallWindow;

/// 关闭应用内小窗
- (void)closeInAppSmallWindow;

@end

NS_ASSUME_NONNULL_END
