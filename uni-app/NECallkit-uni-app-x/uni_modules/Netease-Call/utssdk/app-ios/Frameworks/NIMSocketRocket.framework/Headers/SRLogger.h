//
//  SRLogger.h
//
//  Created by Netease.
//  Copyright (c) 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol NIMSRLogger <NSObject>

- (void)logMessage:(NSString *)message
              file:(NSString *)file
              line:(NSUInteger)line;

@end

@interface NIMSRLogger : NSObject

@property(class,nonatomic,strong) id<NIMSRLogger> logger;

@end

NS_ASSUME_NONNULL_END
