//
//  NIMQChatChannelCategoryRole.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatPermissionStatusInfo;
@interface NIMQChatChannelCategoryRole : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 继承服务器的身份组id
 */
@property (nonatomic, assign) unsigned long long parentRoleId;
/**
 * 分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;
/**
 * 名称
 */
@property (nonnull, nonatomic, copy) NSString *name;
/**
 * 类型
 */
@property (nonatomic, assign) NIMQChatRoleType type;
/**
 * icon图
 */
@property (nonatomic, copy) NSString *icon;
/**
 * 自定义扩展
 */
@property (nonatomic, copy) NSString *ext;
/**
 * 该身份组各资源的权限状态
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *auths;
/**
 * 创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;
/**
 * 更新时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

@end

NS_ASSUME_NONNULL_END
