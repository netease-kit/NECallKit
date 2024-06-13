//
//  NIMQChatGetServerRolesParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 查询服务器下身份组列表
 */
@interface NIMQChatGetServerRolesParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 每页个数
 */
@property (nonatomic, assign) NSInteger limit;

/**
 * 优先级
 */
@property (nullable, nonatomic, strong) NSNumber *priority;

/**
 * 以channelId的名义查询，可选，如果传了，则只需要有该channel的管理权限即可，否则需要有server的管理权限
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 频道分组id,以categoryId的名义查询，可选，如果传了，则只需要有该channel category的管理角色权限即可，否则需要有server的管理权限
 */
@property (nonatomic, assign) unsigned long long categoryId;

@end


NS_ASSUME_NONNULL_END
