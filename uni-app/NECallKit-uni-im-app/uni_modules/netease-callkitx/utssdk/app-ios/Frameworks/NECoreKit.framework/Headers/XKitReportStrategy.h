// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ReportEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface XKitStrategy : NSObject
@property(nonatomic, assign) BOOL enabled;
@property(nonatomic, assign) BOOL lowPriorityEnabled;
@property(nonatomic, assign) BOOL normalPriorityEnabled;
@property(nonatomic, assign) BOOL highPriorityEnabled;
@property(nonatomic, strong) NSMutableArray<NSString *> *blackList;
@property(nonatomic, strong) NSMutableArray<NSString *> *whiteList;
- (instancetype)initWithEnabled:(BOOL)enabled;
- (BOOL)inBlackList:(NSString *)component;
- (BOOL)inWhiteList:(NSString *)component;
@end

/// 上报策略
@interface XKitReportStrategy : NSObject
- (instancetype)initWithAppKey:(NSString *)appKey;
- (BOOL)shouldReportEvent:(NSString *)appKey
                component:(NSString *)component
                 priority:(NECoreEventPriority)priorty;
- (void)ensureStrategyReady:(void (^)(void))completion;
@end

NS_ASSUME_NONNULL_END
