// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class UIView;
@class NECallInfo;

@interface NECallUTSBackgroundPipAdapter : NSObject

+ (NSUInteger)effectiveCallTypeForUTSVideoPipWithEngineCallInfo:(NECallInfo *)callInfo;

+ (UIView *)pipSourceViewWithDefaultSourceView:(UIView *)defaultSourceView
                       inAppFloatWindowActive:(BOOL)active;

+ (BOOL)shouldStartPipBeforeBackgroundWithInAppFloatWindowActive:(BOOL)active;

+ (BOOL)shouldStartPipBeforeBackgroundWithInAppFloatWindowActive:(BOOL)active
                                         forceForDirectVideoCall:(BOOL)force;

+ (BOOL)shouldKeepPipControllerWhenInAppFloatWindowInactive;

+ (void)setSwitchingToAudio:(BOOL)switchingToAudio;

+ (void)prepareForBackgroundPipIfNeeded;

+ (BOOL)shouldSuppressInAppSmallWindowForegroundRecoveryWithPipActive:(BOOL)pipActive;

+ (BOOL)shouldCompleteSystemPipRestoreUIWithPipActive:(BOOL)pipActive;

+ (void)suppressInAppSmallWindowForegroundRecoveryUntil:(NSDate *)date;

+ (BOOL)isInAppSmallWindowForegroundRecoverySuppressed;

@end

NS_ASSUME_NONNULL_END
