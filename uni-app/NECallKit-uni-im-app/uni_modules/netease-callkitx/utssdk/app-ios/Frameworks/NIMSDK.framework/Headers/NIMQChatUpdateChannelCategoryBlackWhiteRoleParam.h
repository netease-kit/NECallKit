
//
//  NIMQChatUpdateChannelCategoryBlackWhiteRoleParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/10.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新频道分组黑白名单身份组参数
 */
@interface NIMQChatUpdateChannelCategoryBlackWhiteRoleParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 分组id
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

NS_ASSUME_NONNULL_END
