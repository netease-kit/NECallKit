

//
//  NIMQChatGetChannelsInCategoryByPageParam.h
//  NIMSDK
//
//  Created by Evang on 2022/4/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询频道分组内频道信息
 */
@interface NIMQChatGetChannelsInCategoryByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;

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

