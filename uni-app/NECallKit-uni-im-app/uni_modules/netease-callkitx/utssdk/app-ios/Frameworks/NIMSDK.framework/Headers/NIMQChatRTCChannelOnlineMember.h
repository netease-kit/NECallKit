//
//  NIMQChatRTCChannelOnlineMember.h
//  NIMLib
//
//  Created by lihuang on 2022/6/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  多媒体频道在线成员
 */
@interface NIMQChatRTCChannelOnlineMember : NSObject <NSCopying>

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 应用id
 */
@property (nonatomic, assign) NSInteger appId;

/**
 * 用户accid
 */
@property (nonatomic, copy) NSString *accid;

/**
 * 昵称
 */
@property (nonatomic, copy)   NSString *nick;

/**
 * 头像
 */
@property (nonatomic, copy)   NSString *avatar;

/**
 * 邀请人
 */
@property (nonatomic, copy)   NSString *inviter;

/**
 * 自定义扩展
 */
@property (nonatomic, copy)   NSString *custom;

/**
 * 类型：0-普通成员，1-所有者
 */
@property (nonatomic, assign) NIMQChatServerMemberType type;

/**
 * 加入时间
 */
@property (nonatomic, assign) NSTimeInterval joinTime;

/**
 * 有效标志： 0-无效，1-有效
 */
@property (nonatomic, assign) BOOL validFlag;

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
