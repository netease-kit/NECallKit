// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NEIncomingCallBannerWindow.h"
#import <NERtcCallKit/NECallEngine.h>
#import <YXAlog_iOS/YXAlog.h>
#import "NECallKitUtil.h"
#import "NERtcCallUIKit.h"
#import "NERingPlayerManager.h"

/// 横幅高度
static const CGFloat kBannerWindowHeight = 92.0;
/// 横幅距屏幕顶部距离（状态栏以下）
static const CGFloat kBannerWindowTopOffset = 54.0;
/// 横幅水平边距
static const CGFloat kBannerWindowHorizontalMargin = 12.0;
/// 动画时长
static const NSTimeInterval kBannerAnimationDuration = 0.3;

static NSString *NEIncomingBannerToastKeyForCallEndReason(NSInteger reasonCode) {
  switch (reasonCode) {
    case TerminalCalleeCancel:
      return @"remote_cancel";
    case TerminalOtherRejected:
      return @"other_client_reject";
    case TerminalOtherAccepted:
      return @"other_client_accept";
    default:
      return nil;
  }
}

@interface NEIncomingCallBannerWindow () <NECallEngineDelegate>

@property(nonatomic, strong, nullable) UIWindow *bannerWindow;
@property(nonatomic, weak, nullable) UIWindow *dismissingBannerWindow;
@property(nonatomic, weak, nullable) UIWindow *cachedHostWindow;
@property(nonatomic, strong, nullable) NEIncomingCallBannerView *bannerViewController;

/// T040：缓存上次来电信息与回调，用于前台重显
@property(nonatomic, strong, nullable) NEIncomingCallerInfo *lastCallerInfo;
@property(nonatomic, copy, nullable) NEIncomingCallBannerAcceptBlock lastAcceptBlock;
@property(nonatomic, copy, nullable) NEIncomingCallBannerRejectBlock lastRejectBlock;
@property(nonatomic, copy, nullable) NEIncomingCallBannerBodyTapBlock lastBodyTapBlock;

@end

@implementation NEIncomingCallBannerWindow

+ (instancetype)sharedInstance {
  static dispatch_once_t onceToken;
  static NEIncomingCallBannerWindow *instance;
  dispatch_once(&onceToken, ^{
    instance = [[self alloc] init];
  });
  return instance;
}

- (void)showWithCallerInfo:(NEIncomingCallerInfo *)callerInfo
                  onAccept:(NEIncomingCallBannerAcceptBlock)onAccept
                  onReject:(NEIncomingCallBannerRejectBlock)onReject
               onBodyTap:(NEIncomingCallBannerBodyTapBlock)onBodyTap {
  // T040：缓存来电信息与回调，以便前台重显
  self.lastCallerInfo = callerInfo;
  self.lastAcceptBlock = onAccept;
  self.lastRejectBlock = onReject;
  self.lastBodyTapBlock = onBodyTap;
  dispatch_async(dispatch_get_main_queue(), ^{
    // 前台重显场景：若已有横幅窗口，同步移除旧窗口。
    // 不能调用 dismiss（其内部再次 dispatch_async，Block 会在新窗口创建后才执行，
    // 导致新窗口被误关闭、lastCallerInfo 被清空，横幅消失无法接听）。
    if (self.bannerWindow != nil) {
      [[NECallEngine sharedInstance] removeCallDelegate:self];
      self.bannerWindow.hidden = YES;
      self.bannerWindow = nil;
      self.bannerViewController = nil;
      // 注意：不停止铃声（前台重显时铃声仍在播放中，下方会继续播放）
      // 注意：不清空缓存（下方 showWithCallerInfo: 入参会立即覆盖）
    }

    YXAlogInfo(@"showIncomingBanner callerAccId=%@ callType=%ld",
               callerInfo.accountId, (long)callerInfo.callType);

    self.cachedHostWindow = [self currentHostWindowExcludingBanner];

    // 注册 NECallEngineDelegate，监听通话结束事件
    [[NECallEngine sharedInstance] addCallDelegate:self];

    // 创建横幅视图控制器
    NEIncomingCallBannerView *bannerVC =
        [[NEIncomingCallBannerView alloc] initWithCallerInfo:callerInfo];
    self.bannerViewController = bannerVC;

    // 创建专用 UIWindow
    UIWindow *window = [self createBannerWindow];
    self.bannerWindow = window;
    window.rootViewController = bannerVC;

    // 设置初始位置（在屏幕上方，用于滑入动画）
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat bannerWidth = screenWidth - kBannerWindowHorizontalMargin * 2;
    CGRect finalFrame = CGRectMake(kBannerWindowHorizontalMargin,
                                   kBannerWindowTopOffset,
                                   bannerWidth,
                                   kBannerWindowHeight);
    CGRect initialFrame = CGRectMake(finalFrame.origin.x,
                                     -kBannerWindowHeight,
                                     finalFrame.size.width,
                                     finalFrame.size.height);
    window.frame = initialFrame;
    window.hidden = NO;

    // 滑入动画
    [UIView animateWithDuration:kBannerAnimationDuration
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                       window.frame = finalFrame;
                     }
                     completion:nil];

    // 播放被叫来电铃声（与全屏来电流程一致）。UTS 等外部 UI 接入可关闭 native 铃声。
    if ([[NERtcCallUIKit sharedInstance] isNativeIncomingRingEnabled]) {
      [[NERingPlayerManager shareInstance] playRingWithRingType:CRTCalleeRing isRtcPlay:NO];
      YXAlogInfo(@"bannerRingStart");
    }

    // 绑定回调。接听前可能需要在横幅窗口上展示权限引导，因此由业务回调决定何时 dismiss。
    __weak typeof(self) weakSelf = self;

    bannerVC.onAccept = ^{
      if (onAccept) {
        onAccept();
      }
    };

    bannerVC.onReject = ^{
      [weakSelf dismiss];
      if (onReject) {
        onReject();
      }
    };

    bannerVC.onBodyTap = ^{
      [weakSelf dismissKeepingRing];
      if (onBodyTap) {
        onBodyTap();
      }
    };
  });
}

- (void)show {
  if (self.lastCallerInfo == nil) {
    YXAlogInfo(@"NEIncomingCallBannerWindow show: no cached callerInfo, skip.");
    return;
  }
  YXAlogInfo(@"NEIncomingCallBannerWindow show (reshow) callerAccId=%@", self.lastCallerInfo.accountId);
  [self showWithCallerInfo:self.lastCallerInfo
                 onAccept:self.lastAcceptBlock
                 onReject:self.lastRejectBlock
              onBodyTap:self.lastBodyTapBlock];
}

- (void)dismiss {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.bannerWindow == nil) {
      return;
    }
    YXAlogInfo(@"dismissIncomingBanner reason=userAction");
    // 停止来电铃声
    [[NERingPlayerManager shareInstance] stopCurrentPlaying];
    YXAlogInfo(@"bannerRingStop");
    [self _dismissWindowOnly];
  });
}

/// 关闭横幅但不停止铃声（点击主体跳全屏来电时使用，铃声由全屏页面接管）
- (void)dismissKeepingRing {
  dispatch_async(dispatch_get_main_queue(), ^{
    if (self.bannerWindow == nil) {
      return;
    }
    YXAlogInfo(@"dismissIncomingBanner reason=bodyTap keepRing");
    [self _dismissWindowOnly];
  });
}

- (void)_dismissWindowOnly {
  // 注销 delegate，避免重复响应
  [[NECallEngine sharedInstance] removeCallDelegate:self];
  UIWindow *window = self.bannerWindow;
  self.bannerWindow = nil;
  self.dismissingBannerWindow = window;
  self.bannerViewController = nil;
  // T040：来电结束时清空缓存
  self.lastCallerInfo = nil;
  self.lastAcceptBlock = nil;
  self.lastRejectBlock = nil;
  self.lastBodyTapBlock = nil;

  CGRect dismissFrame = CGRectMake(window.frame.origin.x,
                                   -kBannerWindowHeight,
                                   window.frame.size.width,
                                   window.frame.size.height);
  [UIView animateWithDuration:kBannerAnimationDuration
      animations:^{
        window.frame = dismissFrame;
      }
      completion:^(BOOL finished) {
        window.hidden = YES;
        if (self.dismissingBannerWindow == window) {
          self.dismissingBannerWindow = nil;
        }
      }];
}

- (BOOL)isShowing {
  return self.bannerWindow != nil && !self.bannerWindow.isHidden;
}

- (BOOL)isBannerWindow:(UIWindow *)window {
  return window != nil && (window == self.bannerWindow || window == self.dismissingBannerWindow);
}

- (UIWindow *)hostWindow {
  return [self currentHostWindowExcludingBanner];
}

- (UIViewController *)presentingViewController {
  return self.bannerViewController;
}

#pragma mark - NECallEngineDelegate

- (void)onCallEnd:(NECallEndInfo *)info {
  NSString *toastKey = NEIncomingBannerToastKeyForCallEndReason(info.reasonCode);
  YXAlogInfo(@"dismissIncomingBanner reason=callEnded reasonCode=%ld", (long)info.reasonCode);
  dispatch_async(dispatch_get_main_queue(), ^{
    [self dismiss];
    if (toastKey.length > 0) {
      [NECallKitUtil makeToast:[NECallKitUtil localizableWithKey:toastKey]];
    }
  });
}

#pragma mark - Private

- (BOOL)isValidHostWindow:(UIWindow *)window {
  return window != nil && !window.isHidden && window.rootViewController != nil &&
         ![self isBannerWindow:window];
}

- (UIWindow *)currentHostWindowExcludingBanner {
  UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
  if ([self isValidHostWindow:keyWindow]) {
    return keyWindow;
  }
  if ([self isValidHostWindow:self.cachedHostWindow]) {
    return self.cachedHostWindow;
  }

  if (@available(iOS 13.0, *)) {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
      if (![scene isKindOfClass:[UIWindowScene class]]) {
        continue;
      }
      UIWindowScene *windowScene = (UIWindowScene *)scene;
      if (windowScene.activationState != UISceneActivationStateForegroundActive &&
          windowScene.activationState != UISceneActivationStateForegroundInactive) {
        continue;
      }
      for (UIWindow *window in windowScene.windows.reverseObjectEnumerator) {
        if ([self isValidHostWindow:window]) {
          return window;
        }
      }
    }
  }

  for (UIWindow *window in UIApplication.sharedApplication.windows.reverseObjectEnumerator) {
    if ([self isValidHostWindow:window]) {
      return window;
    }
  }

  return nil;
}

- (UIWindow *)createBannerWindow {
  UIWindow *window = nil;

  if (@available(iOS 13.0, *)) {
    for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes.allObjects) {
      if ([scene isKindOfClass:[UIWindowScene class]]) {
        UISceneActivationState state = scene.activationState;
        if (state == UISceneActivationStateForegroundActive ||
            state == UISceneActivationStateForegroundInactive) {
          window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
          break;
        }
      }
    }
  }

  if (window == nil) {
    window = [[UIWindow alloc] init];
  }

  window.windowLevel = UIWindowLevelStatusBar;
  window.backgroundColor = [UIColor clearColor];
  window.clipsToBounds = YES;
  window.layer.cornerRadius = 10.0;

  return window;
}

@end
