//
//  NIMQChatInviteServerMembersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  邀请服务器成员的参数
 */
@interface NIMQChatInviteServerMembersParam : NSObject <NSCopying>
/**
 * 圈组服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 邀请对象的账号数组
 */
@property (nonnull, nonatomic, copy) NSArray<NSString *> * accids;

/**
 * 附言（最长5000）
 */
@property (nullable, nonatomic, copy) NSString *postscript;

/**
 * 过期时间（秒），NSTimeInterval
 */
@property (nullable, nonatomic, copy)  NSNumber *ttl;
@end


NS_ASSUME_NONNULL_END
