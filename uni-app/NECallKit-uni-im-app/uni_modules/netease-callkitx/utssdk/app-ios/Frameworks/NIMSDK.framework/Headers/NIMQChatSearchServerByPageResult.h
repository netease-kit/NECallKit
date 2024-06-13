//
//  NIMQChatGetServerMembersByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询服务器信息的结果
 */
@interface NIMQChatSearchServerByPageResult : NSObject <NSCopying>

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 查询游标，下一次查询的起始位置
 */
@property(nullable, nonatomic, copy) NSString *cursor;

/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatServer *> *servers;

@end


NS_ASSUME_NONNULL_END
