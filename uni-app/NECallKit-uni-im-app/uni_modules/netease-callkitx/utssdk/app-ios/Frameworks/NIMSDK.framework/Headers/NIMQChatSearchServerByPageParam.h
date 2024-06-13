//
// Created by chenjili on 2022/4/28.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
/**
 * 检索服务器列表的参数
 */
@interface NIMQChatSearchServerByPageParam : NSObject <NSCopying>
/**
 * 检索关键字，目标检索服务器名称
 */
@property(nonnull, nonatomic, copy) NSString* keyword;

/**
 * 排序规则 true：正序；false：反序
 */
@property(nonatomic, assign) BOOL asc;

/**
 * 搜索类型，广场搜索1，个人服务器搜索2
 */
@property(nonatomic, assign) NIMQChatSearchServerType searchType;

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
 * 服务器类型列表，服务器类型为正整数
 */
@property(nullable, nonatomic, copy) NSArray<NSNumber *> *serverTypes;

/**
 * 返回值的排序类型
 */
@property(nonatomic, assign) NIMQChatSearchServerSortType sortType;

/**
 * 查询游标，查询的起始位置，上一次查询会返回cursor字段
 */
@property(nullable, nonatomic, copy) NSString *cursor;

@end
NS_ASSUME_NONNULL_END
