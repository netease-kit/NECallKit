//
//  NIMSessionStatContext.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  会话统计上下文信息
 */
@interface NIMSessionStatContext : NSObject

/**
 *  总数
 */
@property (nonatomic,assign,readonly)       NSInteger total;

/**
 *  当前序号（1 based）
 */
@property (nonatomic,assign,readonly)       NSInteger current;

@end

NS_ASSUME_NONNULL_END
