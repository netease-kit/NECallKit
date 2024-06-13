
//
//  NIMQChatGetChannelMembersByPageParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/10.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  
 */
@interface NIMQChatGetChannelMembersByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;

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
