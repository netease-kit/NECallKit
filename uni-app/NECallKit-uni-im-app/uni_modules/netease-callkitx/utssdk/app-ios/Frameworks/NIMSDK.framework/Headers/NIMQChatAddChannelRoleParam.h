//
//  NIMQChatAddChannelRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  将某身份组加入某频道
 */
@interface NIMQChatAddChannelRoleParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;
/**
 * 服务器身份组id
 */
@property (nonatomic, assign) unsigned long long parentRoleId;

@end


NS_ASSUME_NONNULL_END
