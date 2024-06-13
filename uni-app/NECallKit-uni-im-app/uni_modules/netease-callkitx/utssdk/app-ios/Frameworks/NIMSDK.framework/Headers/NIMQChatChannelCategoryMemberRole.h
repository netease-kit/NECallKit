//
//  NIMQChatChannelCategoryMemberRole.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatPermissionStatusInfo;

@interface NIMQChatChannelCategoryMemberRole : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 定制权限id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 用户id
 */
@property (nonatomic, copy) NSString *accid;
/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long categoryId;
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
/**
 * 昵称
 * */
@property (nonatomic, copy) NSString *nick;
/**
 * 头像
 */
@property (nonatomic, copy) NSString *avatar;
/**
 * 自定义字段
 */
@property (nonatomic, copy) NSString *custom;
/**
 * 成员类型
 */
@property (nonatomic, assign) NIMQChatServerMemberType type;
/**
 * 加入时间
 */
@property (nonatomic, assign) NSTimeInterval joinTime;
/**
 * 邀请者accid
 */
@property (nonatomic, copy) NSString *inviter;

@end

NS_ASSUME_NONNULL_END
