/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NEXKitBaseEventPriority) {
    NEXKitBaseEventPriorityLow = 0,
    NEXKitBaseEventPriorityNormal = 1,
    NEXKitBaseEventPriorityHigh = 2
};

@protocol NEXKitBaseEvent <NSObject>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NEXKitBaseEventPriority priority;

- (NSDictionary<NSString *, id> *)toMap;

@end

@interface NEXKitBaseRawEvent : NSObject <NEXKitBaseEvent>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NEXKitBaseEventPriority priority;

- (instancetype)initWithEventId:(NSString *)eventId 
                       priority:(NEXKitBaseEventPriority)priority 
                           data:(NSDictionary<NSString *, id> *)data;

@end

@interface NEXKitBaseEventCommonFields : NSObject

@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@property (nonatomic, copy, nullable) NSString *id1;
@property (nonatomic, copy, nullable) NSString *id2;

- (void)setStartTime:(NSTimeInterval)time;
- (void)setEndTime:(NSTimeInterval)time;
- (void)setId1:(NSString *)id1;
- (void)setId2:(NSString *)id2;
- (void)addParam:(NSString *)key value:(id)value;
- (void)addParams:(NSDictionary<NSString *, id> *)params;
- (NSDictionary<NSString *, id> *)commonFieldsMap;

@end

@interface NEXKitBaseEventConstants : NSObject

+ (NSString *)keyAppKey;
+ (NSString *)keyComponent;
+ (NSString *)keyVersion;
+ (NSString *)keyPlatform;
+ (NSString *)keyStartTime;
+ (NSString *)keyEndTime;
+ (NSString *)keyTimestamp;
+ (NSString *)keyNertcVersion;
+ (NSString *)keyImVersion;
+ (NSString *)keyReportType;
+ (NSString *)keyDuration;
+ (NSString *)keyData;
+ (NSString *)keyExtra;
+ (NSString *)keyEventName;
+ (NSString *)keyCode;
+ (NSString *)keyMessage;
+ (NSString *)keyApiName;
+ (NSString *)keyApiExtension;
+ (NSString *)keyApiId1;
+ (NSString *)keyApiId2;
+ (NSString *)keyEventParam;
+ (NSString *)keyEventRequestId;
+ (NSString *)keyDeviceId;
+ (NSString *)keyDeviceModel;
+ (NSString *)keyDeviceManufacturer;
+ (NSString *)keyOsVersion;
+ (NSString *)keyAppName;
+ (NSString *)keyAppVersion;
+ (NSString *)keyPackageId;
+ (NSString *)keyFramework;
+ (NSString *)keyChannel;
+ (NSString *)keyUserId;
+ (NSString *)keyNetworkType;
+ (NSString *)keyType;
+ (NSString *)keyActionName;
+ (NSString *)keyActionTitle;
+ (NSString *)keyPageName;
+ (NSString *)keyPrePageName;

+ (NSString *)actionTypeClick;
+ (NSString *)actionTypeInput;
+ (NSString *)actionTypeCustom;
+ (NSString *)pageTypeOpen;
+ (NSString *)pageTypeClose;
+ (NSString *)platform;

@end

NS_ASSUME_NONNULL_END
