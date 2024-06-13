//
//  NIMCollectQueryParams.h
//  NIMLib
//
//  Created by 丁文超 on 2020/3/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMCollectQueryOptions : NSObject

/**
 * 最小时间(s)
 */
@property (nonatomic, assign) NSTimeInterval fromTime;

/**
 * 最大时间，传0表示当前时间(s)
 */
@property (nonatomic, assign) NSTimeInterval toTime;

/**
 * 上一页最后一条ID，第一条传0
 */
@property (nonatomic, assign) NSInteger excludeId;

/**
 * 查询条数，默认100
 */
@property (nonatomic, assign) NSInteger limit;

/**
 * 是否倒序
 */
@property (nonatomic, assign) BOOL reverse;

/**
 * 收藏类型
 */
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
