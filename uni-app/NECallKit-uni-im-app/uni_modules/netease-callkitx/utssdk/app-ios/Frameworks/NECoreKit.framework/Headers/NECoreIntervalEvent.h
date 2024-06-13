// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import "ReportEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface NECoreTimeConsumingOperation : NSObject
- (void)setResult:(NSInteger)code
          message:(NSString *__nullable)message
        requestId:(NSString *__nullable)requestId
       serverCost:(double)serverCost;
- (void)setParams:(NSDictionary *)params;
- (void)addParams:(NSString *)key value:(id)value;
- (void)removeParams:(NSString *)key;
- (NSDictionary *)toMap;
@end

@interface NECoreIntervalStep : NECoreTimeConsumingOperation
@property(nonatomic, copy) NSString *name;
- (instancetype)initWithName:(NSString *)name;
@end

@interface NECoreIntervalEvent : NECoreTimeConsumingOperation <NECoreEvent>
- (instancetype)initWithEventId:(NSString *)eventId;

- (NECoreIntervalStep *)beginStep:(NSString *)name;
- (NECoreIntervalStep *_Nullable)currentStep;
- (NECoreIntervalStep *_Nullable)getStep:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
