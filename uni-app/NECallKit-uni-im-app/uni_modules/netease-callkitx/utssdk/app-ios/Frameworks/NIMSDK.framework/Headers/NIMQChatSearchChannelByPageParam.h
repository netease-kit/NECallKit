//
// Created by chenjili on 2022/4/28.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * 分页检索频道信息的参数
 */
@interface NIMQChatSearchChannelByPageParam : NSObject <NSCopying>
/**
 * 检索关键字，目标检索服务器名称
 */
@property(nonnull, nonatomic, copy) NSString* keyword;

/**
 * 排序规则 true：正序；false：反序
 */
@property(nonatomic, assign) BOOL asc;

/**
 * 查询时间范围的开始时间，单位s
 */
@property(nullable, nonatomic, copy) NSNumber *startTime;

/**
 * 查询时间范围的结束时间，要求比开始时间大，单位s
 */
@property(nullable, nonatomic, copy) NSNumber * endTime;

/**
 * 检索返回的最大记录数，最大和默认都是100
 */
@property(nullable, nonatomic, copy) NSNumber * limit;

/**
 * 服务器ID，填0表示不限制在某个服务器内查询
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 返回值的排序类型
 */
@property(nonatomic, assign) NIMQChatSearchChannelSortType sortType;

/**
 * 查询游标，查询的起始位置，上一次查询会返回cursor字段
 */
@property(nullable, nonatomic, copy) NSString *cursor;

@end

NS_ASSUME_NONNULL_END
