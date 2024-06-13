
//
//  NIMQChatGetExistingChannelCategoryBlackWhiteRolesParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  
 */
@interface NIMQChatGetExistingChannelCategoryBlackWhiteRolesParam : NSObject

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
 * 身份组roleid数组
 */
@property (nonatomic, copy) NSArray <NSNumber *> *roleIds;

@end

NS_ASSUME_NONNULL_END

