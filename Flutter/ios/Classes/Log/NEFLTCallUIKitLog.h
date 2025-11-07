// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBase.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEFLTCallUIKitLog : NSObject

+ (void)setupLog;

+ (void)apiLog:(NSString *)className desc:(NSString *)desc;
+ (void)apiLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;

+ (void)infoLog:(NSString *)className desc:(NSString *)desc;
+ (void)infoLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)infoResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)infoEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;

/// warn类型 log
+ (void)warnLog:(NSString *)className desc:(NSString *)desc;
+ (void)warnLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)warnEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)warnResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;

+ (void)successLog:(NSString *)className desc:(NSString *)desc;

/// error类型 log
+ (void)errorLog:(NSString *)className desc:(NSString *)desc;
+ (void)errorLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)errorEventLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;
+ (void)errorResultLog:(NSString *)className desc:(NSString *)desc function:(NSString *)function;

+ (void)messageLog:(NSString *)className desc:(NSString *)desc;
+ (void)networkLog:(NSString *)className desc:(NSString *)desc;

@end

NS_ASSUME_NONNULL_END
