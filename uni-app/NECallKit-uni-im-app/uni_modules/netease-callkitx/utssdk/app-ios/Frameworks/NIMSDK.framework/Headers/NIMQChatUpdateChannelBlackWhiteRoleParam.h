
//
//  NIMQChatUpdateChannelBlackWhiteRoleParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/10.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  
 */
@interface NIMQChatUpdateChannelBlackWhiteRoleParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;

/**
 * 成员身份组类型
 */
@property (nonatomic, assign) NIMQChatChannelMemberRoleType type;

/**
 * 频道成员身份组的操作类型
 */
@property (nonatomic, assign) NIMQChatChannelMemberRoleOpeType opeType;

/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long  roleId;

@end

NS_ASSUME_NONNULL_END
