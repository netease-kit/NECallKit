//
//  NIMQChatGetServerMembersByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatChannel;


NS_ASSUME_NONNULL_BEGIN

/**
 *  分页检索频道信息的参数
 */
@interface NIMQChatSearchChannelByPageResult : NSObject <NSCopying>

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
 * 圈组频道
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatChannel *> *channels;


@end


NS_ASSUME_NONNULL_END
