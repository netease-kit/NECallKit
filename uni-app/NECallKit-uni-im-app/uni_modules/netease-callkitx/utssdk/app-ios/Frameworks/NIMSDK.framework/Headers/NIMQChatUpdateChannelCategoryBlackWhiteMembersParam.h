
//
//  NIMQChatUpdateChannelCategoryBlackWhiteMembersParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/10.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新频道分组黑白成员参数
 */
@interface NIMQChatUpdateChannelCategoryBlackWhiteMembersParam : NSObject

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
 * 用户accid数组
 */
@property (nonatomic, copy) NSArray <NSString *> *accids;

@end

NS_ASSUME_NONNULL_END
