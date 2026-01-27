/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBaseEvent.h>


NS_ASSUME_NONNULL_BEGIN

@interface NEXKitBaseActionEvent : NEXKitBaseEventCommonFields <NEXKitBaseEvent>

@property (nonatomic, readonly) NSString *eventId;
@property (nonatomic, readonly) NEXKitBaseEventPriority priority;

- (instancetype)initWithType:(NSString *)type 
                  actionName:(NSString *)actionName 
                 actionTitle:(NSString * _Nullable)actionTitle;

+ (instancetype)clickWithName:(NSString *)name title:(NSString * _Nullable)title;
+ (instancetype)inputWithName:(NSString *)name title:(NSString * _Nullable)title;
+ (instancetype)customWithName:(NSString *)name title:(NSString * _Nullable)title;

@end

NS_ASSUME_NONNULL_END
