// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NECallKitLiveCommunicationKitConfig;

typedef void (^NECallUILiveCommunicationKitIncomingStateHandler)(BOOL isIncoming);

FOUNDATION_EXPORT NSNotificationName const
    NECallUILiveCommunicationKitIncomingStateChangedNotification;
FOUNDATION_EXPORT NSString *const NECallUILiveCommunicationKitIncomingStateKey;

/// Internal bridge for UTS iOS LiveCommunicationKit integration.
/// This header is a project header and must not be added to public umbrella headers.
@interface NECallUILiveCommunicationKitBridge : NSObject

+ (instancetype)shared;

- (void)enableLiveCommunicationKit:(BOOL)enabled;

- (void)setLiveCommunicationKitConfig:(NECallKitLiveCommunicationKitConfig *)config;

- (void)setIncomingStateChangedHandler:
    (nullable NECallUILiveCommunicationKitIncomingStateHandler)handler;

@end

NS_ASSUME_NONNULL_END
