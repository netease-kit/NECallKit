/*
 * Copyright (c) 2022 NetEase, Inc. All rights reserved.
 * Use of this source code is governed by a MIT license that can be
 * found in the LICENSE file.
 */

#import <Foundation/Foundation.h>
#import <NEXKitBase/NEXKitBaseEvent.h>

NS_ASSUME_NONNULL_BEGIN

@interface NEXKitBaseReportService : NSObject

+ (instancetype)shared;

/// Enable/disable debug logging
/// @param enabled Whether to enable debug logs
- (instancetype)enableDebugLog:(BOOL)enabled;

/// Set common properties for event reporting
/// @param key Property key
/// @param value Property value
- (instancetype)setCommonProperty:(NSString *)key value:(id)value;

/// Set common properties for event reporting
/// @param properties Properties dictionary
- (instancetype)setCommonProperties:(NSDictionary<NSString *, id> *)properties;

/// Register module
/// @param moduleName Module name
/// @param moduleVersion Module version
/// @param moduleAppKey Module app key
/// @param framework Framework type (optional)
/// @param channel Channel (optional)
/// @param report Whether to immediately report init event
/// @return Returns YES for success, NO for failure
- (BOOL)registerModule:(NSString *)moduleName
         moduleVersion:(NSString *)moduleVersion
          moduleAppKey:(NSString *)moduleAppKey
             framework:(NSString * _Nullable)framework
               channel:(NSString * _Nullable)channel
                report:(BOOL)report;

/// Report event
/// @param moduleName Module name
/// @param userId User ID (optional)
/// @param event Event to report
/// @return Returns YES for success, NO for failure
- (BOOL)reportEvent:(NSString *)moduleName
             userId:(NSString * _Nullable)userId
              event:(id<NEXKitBaseEvent>)event;

/// Report event with module info
/// @param moduleName Module name
/// @param moduleVersion Module version
/// @param moduleAppKey Module app key
/// @param framework Framework type (optional)
/// @param channel Channel (optional)
/// @param userId User ID (optional)
/// @param event Event to report
/// @return Returns YES for success, NO for failure
- (BOOL)reportEventWithModuleInfo:(NSString *)moduleName
                    moduleVersion:(NSString *)moduleVersion
                     moduleAppKey:(NSString *)moduleAppKey
                        framework:(NSString * _Nullable)framework
                          channel:(NSString * _Nullable)channel
                           userId:(NSString * _Nullable)userId
                            event:(id<NEXKitBaseEvent>)event;

@end

NS_ASSUME_NONNULL_END
