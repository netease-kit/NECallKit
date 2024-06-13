//
//  NIMQChatChannelMember.h
//  NIMLib
//
//  Created by 齐洪茹 on 2022/8/23.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatChannelMember : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;
/**
 * 头像
 */
@property (nonatomic, copy)   NSString *avatar;

/**
 * 用户accid
 */
@property (nonatomic, copy) NSString *accid;

/**
 * 昵称
 */
@property (nonatomic, copy)   NSString *nick;

/**
 * 创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 修改时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;


@end

NS_ASSUME_NONNULL_END
