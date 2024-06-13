//
// Created by chenjili on 2022/2/19.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIMQChatUpdateChannelBlackWhiteRoleInfo: NSObject

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
