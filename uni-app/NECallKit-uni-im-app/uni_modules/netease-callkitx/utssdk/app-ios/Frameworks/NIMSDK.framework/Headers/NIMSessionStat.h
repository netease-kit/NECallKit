//
//  NIMSessionStat.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  会话统计信息
 */
@interface NIMSessionStat : NSObject <NSCopying>

/**
 *  所属会话
 */
@property (nonnull,nonatomic,copy,readonly)        NIMSession *session;

/**
 *  统计项
 *  @discussion 指定NIMSessionStatKey
 */
@property (nullable,nonatomic,copy,readonly)       NSDictionary *stat;

@end

NS_ASSUME_NONNULL_END
