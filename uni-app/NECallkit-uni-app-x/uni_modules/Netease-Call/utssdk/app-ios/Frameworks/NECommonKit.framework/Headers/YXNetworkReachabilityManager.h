// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH
#import <SystemConfiguration/SystemConfiguration.h>

typedef NS_ENUM(NSInteger, YXNetworkReachabilityStatus) {
  YXNetworkReachabilityStatusUnknown = -1,
  YXNetworkReachabilityStatusNotReachable = 0,
  YXNetworkReachabilityStatusReachableViaWWAN = 1,
  YXNetworkReachabilityStatusReachableViaWiFi = 2,
};

NS_ASSUME_NONNULL_BEGIN

@interface YXNetworkReachabilityManager : NSObject

@property(readonly, nonatomic, assign) YXNetworkReachabilityStatus networkReachabilityStatus;

@property(readonly, nonatomic, assign, getter=isReachable) BOOL reachable;

@property(readonly, nonatomic, assign, getter=isReachableViaWWAN) BOOL reachableViaWWAN;

@property(readonly, nonatomic, assign, getter=isReachableViaWiFi) BOOL reachableViaWiFi;

+ (instancetype)sharedManager;

+ (instancetype)manager;

+ (instancetype)managerForDomain:(NSString *)domain;

+ (instancetype)managerForAddress:(const void *)address;

- (instancetype)initWithReachability:(SCNetworkReachabilityRef)reachability
    NS_DESIGNATED_INITIALIZER;

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (void)startMonitoring;

- (void)stopMonitoring;

- (NSString *)localizedNetworkReachabilityStatusString;

- (void)setReachabilityStatusChangeBlock:
    (nullable void (^)(YXNetworkReachabilityStatus status))block;

@end

FOUNDATION_EXPORT NSString *const YXNetworkingReachabilityDidChangeNotification;
FOUNDATION_EXPORT NSString *const YXNetworkingReachabilityNotificationStatusItem;

FOUNDATION_EXPORT NSString *YXStringFromNetworkReachabilityStatus(
    YXNetworkReachabilityStatus status);

NS_ASSUME_NONNULL_END

#endif
