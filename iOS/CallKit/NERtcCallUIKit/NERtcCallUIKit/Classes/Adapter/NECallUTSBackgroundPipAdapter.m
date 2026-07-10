// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import "NECallUTSBackgroundPipAdapter.h"
#import "NECallStateManager.h"
#import <NERtcCallKit/NECallEngine.h>
#import <NEXKitBase/NEXKitBase.h>
#import <UIKit/UIKit.h>

@implementation NECallUTSBackgroundPipAdapter

static NSDate *sSuppressInAppForegroundRecoveryUntil = nil;
static BOOL sSwitchingToAudio = NO;

+ (NSUInteger)effectiveCallTypeForUTSVideoPipWithEngineCallInfo:(NECallInfo *)callInfo {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NSString *framework = engine.config.framework ?: @"";
  NECallType engineCallType = callInfo.callType;
  NECallType stateCallType = NECallStateManager.sharedInstance.callType;
  if ([framework isEqualToString:@"UniApp-uts"] &&
      engine.callStatus == NERtcCallStatusInCall &&
      stateCallType == NECallTypeVideo &&
      engineCallType != NECallTypeVideo) {
    NEXKitBaseLogInfo(
        @"[UTSBackgroundPipAdapter] use state callType for pip, engineCallType:%lu "
         @"stateCallType:%lu",
        (unsigned long)engineCallType, (unsigned long)stateCallType);
    return stateCallType;
  }
  return engineCallType;
}

+ (BOOL)isUTSVideoCall {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NSString *framework = engine.config.framework ?: @"";
  NECallInfo *callInfo = [engine getCallInfo];
  NECallType effectiveCallType =
      [self effectiveCallTypeForUTSVideoPipWithEngineCallInfo:callInfo];
  return [framework isEqualToString:@"UniApp-uts"] &&
         engine.callStatus == NERtcCallStatusInCall && effectiveCallType == NECallTypeVideo;
}

+ (BOOL)isUTSVideoCallWithInAppFloatWindowActive:(BOOL)active {
  return [self isUTSVideoCall] && active;
}

+ (UIView *)pipSourceViewWithDefaultSourceView:(UIView *)defaultSourceView
                       inAppFloatWindowActive:(BOOL)active {
  if (![self isUTSVideoCallWithInAppFloatWindowActive:active]) {
    return defaultSourceView;
  }

  UIWindow *defaultWindow = defaultSourceView.window;
  BOOL defaultWindowIsSmall =
      defaultWindow != nil &&
      (CGRectGetWidth(defaultWindow.bounds) < CGRectGetWidth(UIScreen.mainScreen.bounds) * 0.8 ||
       CGRectGetHeight(defaultWindow.bounds) < CGRectGetHeight(UIScreen.mainScreen.bounds) * 0.8);
  if (!defaultWindowIsSmall) {
    NEXKitBaseLogInfo(
        @"[UTSBackgroundPipAdapter] pip source view keep default:%@ defaultWindow:%@ "
         @"inAppFloat:%d",
        defaultSourceView, defaultWindow, active);
    return defaultSourceView;
  }

  UIWindow *mainWindow = nil;
  if (@available(iOS 13.0, *)) {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
      if (![scene isKindOfClass:UIWindowScene.class]) {
        continue;
      }
      UIWindowScene *windowScene = (UIWindowScene *)scene;
      if (windowScene.activationState != UISceneActivationStateForegroundActive) {
        continue;
      }
      for (UIWindow *window in windowScene.windows) {
        if (window == defaultWindow || window.hidden || window.rootViewController == nil) {
          continue;
        }
        if (CGRectGetWidth(window.bounds) < CGRectGetWidth(UIScreen.mainScreen.bounds) * 0.8 ||
            CGRectGetHeight(window.bounds) < CGRectGetHeight(UIScreen.mainScreen.bounds) * 0.8) {
          continue;
        }
        mainWindow = window;
        break;
      }
      if (mainWindow != nil) {
        break;
      }
    }
  }
  if (mainWindow == nil) {
    for (UIWindow *window in UIApplication.sharedApplication.windows) {
      if (window == defaultWindow || window.hidden || window.rootViewController == nil) {
        continue;
      }
      if (CGRectGetWidth(window.bounds) < CGRectGetWidth(UIScreen.mainScreen.bounds) * 0.8 ||
          CGRectGetHeight(window.bounds) < CGRectGetHeight(UIScreen.mainScreen.bounds) * 0.8) {
        continue;
      }
      mainWindow = window;
      break;
    }
  }
  UIView *sourceView = mainWindow.rootViewController.view ?: defaultSourceView;
  NEXKitBaseLogInfo(
      @"[UTSBackgroundPipAdapter] pip source view, default:%@ defaultWindow:%@ source:%@ "
       @"sourceWindow:%@ inAppFloat:%d",
      defaultSourceView, defaultWindow, sourceView, sourceView.window, active);
  return sourceView;
}

+ (BOOL)shouldStartPipBeforeBackgroundWithInAppFloatWindowActive:(BOOL)active {
  return [self shouldStartPipBeforeBackgroundWithInAppFloatWindowActive:active
                                                forceForDirectVideoCall:NO];
}

+ (BOOL)shouldStartPipBeforeBackgroundWithInAppFloatWindowActive:(BOOL)active
                                         forceForDirectVideoCall:(BOOL)force {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NSString *framework = engine.config.framework ?: @"";
  NECallInfo *callInfo = [engine getCallInfo];
  NECallType effectiveCallType =
      [self effectiveCallTypeForUTSVideoPipWithEngineCallInfo:callInfo];
  BOOL shouldStart = active ? [self isUTSVideoCallWithInAppFloatWindowActive:active]
                            : (force && [self isUTSVideoCall]);
  if (shouldStart) {
    NEXKitBaseLogInfo(
        @"[UTSBackgroundPipAdapter] start pip before background, framework:%@ "
         @"callStatus:%lu callType:%lu callId:%@ inAppFloat:%d force:%d",
        framework, (unsigned long)engine.callStatus, (unsigned long)effectiveCallType,
        callInfo.callId, active, force);
  }
  return shouldStart;
}

+ (BOOL)shouldKeepPipControllerWhenInAppFloatWindowInactive {
  if (sSwitchingToAudio) {
    NEXKitBaseLogInfo(
        @"[UTSBackgroundPipAdapter] stop keeping pip controller while switching to audio");
    return NO;
  }
  BOOL shouldKeep = [self isUTSVideoCall];
  if (shouldKeep) {
    NEXKitBaseLogInfo(
        @"[UTSBackgroundPipAdapter] keep pip controller after in-app small window inactive");
  }
  return shouldKeep;
}

+ (void)setSwitchingToAudio:(BOOL)switchingToAudio {
  sSwitchingToAudio = switchingToAudio;
  NEXKitBaseLogInfo(@"[UTSBackgroundPipAdapter] switchingToAudio:%d", switchingToAudio);
}

+ (void)prepareForBackgroundPipIfNeeded {
  NECallEngine *engine = [NECallEngine sharedInstance];
  NSString *framework = engine.config.framework ?: @"";
  NECallInfo *callInfo = [engine getCallInfo];
  NECallType effectiveCallType =
      [self effectiveCallTypeForUTSVideoPipWithEngineCallInfo:callInfo];
  if (![framework isEqualToString:@"UniApp-uts"] || engine.callStatus != NERtcCallStatusInCall ||
      effectiveCallType != NECallTypeVideo) {
    return;
  }

  NEXKitBaseLogInfo(
      @"[UTSBackgroundPipAdapter] keep in-app small window for background pip, framework:%@ "
       @"callStatus:%lu callType:%lu callId:%@",
      framework, (unsigned long)engine.callStatus, (unsigned long)effectiveCallType,
      callInfo.callId);
}

+ (BOOL)shouldSuppressInAppSmallWindowForegroundRecoveryWithPipActive:(BOOL)pipActive {
  if (![self isUTSVideoCall] || !pipActive) {
    return NO;
  }
  NEXKitBaseLogInfo(@"[UTSBackgroundPipAdapter] suppress in-app small window foreground recovery");
  return YES;
}

+ (BOOL)shouldCompleteSystemPipRestoreUIWithPipActive:(BOOL)pipActive {
  if (![self isUTSVideoCall] || !pipActive) {
    return NO;
  }
  NEXKitBaseLogInfo(@"[UTSBackgroundPipAdapter] complete system pip restore UI");
  return YES;
}

+ (void)suppressInAppSmallWindowForegroundRecoveryUntil:(NSDate *)date {
  if (![self isUTSVideoCall] || date == nil) {
    return;
  }
  sSuppressInAppForegroundRecoveryUntil = date;
}

+ (BOOL)isInAppSmallWindowForegroundRecoverySuppressed {
  NSDate *date = sSuppressInAppForegroundRecoveryUntil;
  if (![date isKindOfClass:NSDate.class]) {
    return NO;
  }
  BOOL suppressed = [date timeIntervalSinceNow] > 0;
  if (!suppressed) {
    sSuppressInAppForegroundRecoveryUntil = nil;
  }
  return suppressed;
}

@end
