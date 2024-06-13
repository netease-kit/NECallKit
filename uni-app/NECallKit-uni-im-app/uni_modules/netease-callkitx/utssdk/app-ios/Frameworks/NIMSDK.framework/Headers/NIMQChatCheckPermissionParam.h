//
//  NIMQChatCheckPermissionParam.h
//  NIMLib
//
//  Created by Evang on 2022/3/24.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  查询是否有某个权限的入参
 */
@interface NIMQChatCheckPermissionParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 *  频道id, 可选，如果不传则只查server权限
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 权限类型
 */
@property (nonatomic, assign) NIMQChatPermissionType permissionType;

@end

NS_ASSUME_NONNULL_END
