// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "NEIncomingCallBannerView.h"

NS_ASSUME_NONNULL_BEGIN

/// 来电横幅专用 UIWindow 管理器
@interface NEIncomingCallBannerWindow : NSObject

+ (instancetype)sharedInstance;

/// 展示来电横幅
/// @param callerInfo 来电方信息
/// @param onAccept 接听回调
/// @param onReject 拒绝回调
/// @param onBodyTap 点击主体回调
- (void)showWithCallerInfo:(NEIncomingCallerInfo *)callerInfo
                  onAccept:(NEIncomingCallBannerAcceptBlock)onAccept
                  onReject:(NEIncomingCallBannerRejectBlock)onReject
               onBodyTap:(NEIncomingCallBannerBodyTapBlock)onBodyTap;

/// 使用上次保存的来电信息重新展示横幅（前台重显，T040）
/// 若无缓存来电信息则不执行任何操作
- (void)show;

/// 隐藏并销毁横幅窗口
- (void)dismiss;

/// 隐藏横幅但不停止铃声（点击主体跳全屏来电时使用，铃声由全屏页面接管，FR-017）
- (void)dismissKeepingRing;

/// 当前横幅视图控制器，用于在横幅接听前展示权限引导
- (nullable UIViewController *)presentingViewController;

/// 横幅当前是否可见
- (BOOL)isShowing;

/// 判断 window 是否为当前来电横幅窗口或正在消失的横幅窗口
- (BOOL)isBannerWindow:(nullable UIWindow *)window;

/// 展示横幅前的宿主窗口，用于恢复业务窗口和小窗 sourceView
- (nullable UIWindow *)hostWindow;

@end

NS_ASSUME_NONNULL_END
