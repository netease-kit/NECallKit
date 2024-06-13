

//
//  NIMQChatGetCategoriesInServerByPageParam.h
//  NIMSDK
//
//  Created by Evang on 2022/4/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询服务器内频道分组
 */
@interface NIMQChatGetCategoriesInServerByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * timetag
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 每页个数
 */
@property (nonatomic, strong) NSNumber *limit;

@end

NS_ASSUME_NONNULL_END

