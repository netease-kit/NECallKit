//
//  NIMQChatUpdateChannelCategoryRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatPermissionStatusInfo;
/**
 *  修改频道分组下某身份组的权限
 */
@interface NIMQChatUpdateChannelCategoryRoleParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;

/**
 * 操作的权限状态列表
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *auths;


@end


NS_ASSUME_NONNULL_END
