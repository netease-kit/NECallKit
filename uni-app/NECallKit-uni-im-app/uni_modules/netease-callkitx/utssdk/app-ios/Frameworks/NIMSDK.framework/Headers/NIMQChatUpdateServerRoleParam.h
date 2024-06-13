//
//  NIMQChatUpdateServerRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatPermissionStatusInfo;
/**
 *  修改服务器身份组信息
 */
@interface NIMQChatUpdateServerRoleParam : NSObject
/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 名称
 */
@property (nonnull, nonatomic, copy) NSString *name;
/**
 * icon图
 */
@property (nonatomic, copy) NSString *icon;
/**
 * 自定义扩展
 */
@property (nonatomic, copy) NSString *ext;

/**
 * 操作的权限状态列表
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *commands;
/**
 * 优先级
 */
@property (nonatomic, strong) NSNumber *priority;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;


@end


NS_ASSUME_NONNULL_END
