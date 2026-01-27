/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBaseEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEXKitBaseTimeConsumingOperation : NSObject

- (instancetype)setResult:(NSInteger)code 
                  message:(NSString * _Nullable)message 
                requestId:(NSString * _Nullable)requestId 
               serverCost:(NSTimeInterval)serverCost;

- (void)addParams:(NSDictionary<NSString *, id> *)params;
- (void)addParam:(NSString *)key value:(id _Nullable)value;
- (void)removeParam:(NSString *)key;

- (NSDictionary<NSString *, id> *)toMap;

@end

@interface NEXKitBaseIntervalStep : NEXKitBaseTimeConsumingOperation

@property (nonatomic, readonly) NSString *name;

- (instancetype)initWithName:(NSString *)name;

@end

@interface NEXKitBaseIntervalEvent : NEXKitBaseTimeConsumingOperation <NEXKitBaseEvent>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NEXKitBaseEventPriority priority;

- (instancetype)initWithEventId:(NSString *)eventId 
                       priority:(NEXKitBaseEventPriority)priority;

- (NEXKitBaseIntervalStep *)beginStep:(NSString *)name;
- (NEXKitBaseIntervalStep * _Nullable)currentStep;
- (NEXKitBaseIntervalStep * _Nullable)getStep:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
