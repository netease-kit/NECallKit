// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

/// 事件优先级
typedef NS_ENUM(NSInteger, NECoreEventPriority) {
  /// 低优先级
  NECoreEventPriorityLow,
  /// 中优先级
  NECoreEventPriorityNormal,
  /// 高优先级
  NECoreEventPriorityHigh
};

@protocol NECoreEvent <NSObject>
- (NSString *)eventId;
- (NECoreEventPriority)priorty;
- (NSDictionary<NSString *, id> *)toMap;
@end

@protocol NECoreEventPropertyProvider <NSObject>
+ (NSDictionary<NSString *, id> *)provideProperties;
@end

@interface NECoreRawEvent : NSObject <NECoreEvent>

@property(nonatomic, copy, readonly) NSDictionary<NSString *, id> *data;
- (instancetype)initWithEventId:(NSString *)eventId
                       priority:(NECoreEventPriority)priority
                           data:(NSDictionary<NSString *, id> *)data;
@end
