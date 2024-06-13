//
//  NIMQChatUpdateChannelCategoryBlackWhiteRoleInfo.h
//  NIMLib
//
//  Created by Evang on 2022/5/5.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@interface NIMQChatUpdateChannelCategoryBlackWhiteRoleInfo: NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;

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
