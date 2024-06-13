// Copyright (c) 2022 NetEase, Inc. All rights reserved.
// Use of this source code is governed by a MIT license that can be
// found in the LICENSE file.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ReportModuleInfo : NSObject

@property(nonatomic, copy) NSString *serviceName;

@property(nonatomic, copy) NSString *versionName;

@property(nonatomic, copy, nullable) NSString *appkey;
@property(nonatomic, copy, nullable) NSString *framework;
@property(nonatomic, copy, nullable) NSString *channel;

- (instancetype)initWithName:(NSString *)name
                     version:(NSString *)version
                      appKey:(NSString *__nullable)appKey
                   framework:(NSString *__nullable)framework
                     channel:(NSString *__nullable)channel;
- (NSDictionary *)toMap;
@end

NS_ASSUME_NONNULL_END
