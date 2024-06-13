
//
//  NIMQChatGetExistingChannelRolesByServerRoleIdsParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 *  查询一批服务器身份组在频道中的身份组信息入参
 */
@interface NIMQChatGetExistingChannelRolesByServerRoleIdsParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;

/**
 * 身份组roleid数组
 */
@property (nonatomic, copy) NSArray <NSNumber *> *roleIds;

@end

NS_ASSUME_NONNULL_END

