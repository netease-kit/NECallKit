//
//  NIMQChatServerRoleMember.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatServerRoleMember : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 用户id
 */
@property (nonatomic, copy) NSString *accid;
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
@property (nonatomic, assign) NSTimeInterval jointime;
/**
 * 邀请者accid
 */
@property (nonatomic, copy) NSString *inviter;


@end

NS_ASSUME_NONNULL_END
