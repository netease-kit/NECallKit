//
//  NIMQChatServerRole.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatPermissionStatusInfo;

/**
 *  服务器身份组
 */
@interface NIMQChatServerRole : NSObject
/**
 * 服务器id
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
 * 该身份组的成员数量，everyone身份组数量为-1
 */
@property (nonatomic, assign) NSInteger memberCount;
/**
 * 身份组优先级，everyone为0，custom 的优先级数字越小优先级越高，最高为1
 */
@property (nonatomic, strong) NSNumber *priority;
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
