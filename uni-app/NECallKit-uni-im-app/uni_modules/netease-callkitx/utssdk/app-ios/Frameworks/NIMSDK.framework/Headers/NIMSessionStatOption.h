//
//  NIMSessionStatOption.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  会话统计选项
 */
@interface NIMSessionStatOption : NSObject

/**
 *  需要的统计项
 *  @discussion 指定NIMSessionStatKey
 */
@property (nullable, nonatomic,strong)       NSArray<NSString *> *statKeys;

@end

NS_ASSUME_NONNULL_END
