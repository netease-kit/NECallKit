//
//  NIMQChatGetChannelsByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页获取频道列表的入参
 */
@interface NIMQChatGetChannelsByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * timetag
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 每页个数
 */
@property (nonatomic, assign) NSInteger limit;

@end


NS_ASSUME_NONNULL_END
