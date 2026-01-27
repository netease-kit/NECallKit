/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBaseEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEXKitBasePageEvent : NEXKitBaseEventCommonFields <NEXKitBaseEvent>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NEXKitBaseEventPriority priority;

- (instancetype)initWithType:(NSString *)type 
                    pageName:(NSString *)pageName 
                 prePageName:(NSString * _Nullable)prePageName;

- (instancetype)turnClose;

+ (instancetype)openWithPageName:(NSString *)pageName prePageName:(NSString * _Nullable)prePageName;
+ (instancetype)closeWithPageName:(NSString *)pageName prePageName:(NSString * _Nullable)prePageName;

@end

NS_ASSUME_NONNULL_END
