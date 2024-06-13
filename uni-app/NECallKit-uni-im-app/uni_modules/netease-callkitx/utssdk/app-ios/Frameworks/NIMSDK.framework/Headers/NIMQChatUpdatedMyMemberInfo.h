
//
//  NIMQChatUpdateMyMemberInfo.h
//  NIMSDK
//
//  Created by cqu227hk on 2023/2/20.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  当前用户成员信息发生变更的信息
 */
@interface NIMQChatUpdatedMyMemberInfo : NSObject

/**
 * 当前用户成员信息发生变更的服务器Id
 */
@property (nonatomic, assign,readonly) unsigned long long  serverId;

/**
 * 昵称是否发生变更
 */
@property (nonatomic, assign,readonly) BOOL nickChanged;
/**
 * 变更后的昵称,nickChanged == YES 时生效
 */
@property (nullable, nonatomic, copy, readonly) NSString *nick;

/**
 * 头像是否发生变更
 */
@property (nonatomic, assign,readonly) BOOL avatarChanged;

/**
 * 变更后的头像,avatarChanged == YES 时生效
 */
@property (nullable, nonatomic, copy, readonly) NSString *avatar;

@end

NS_ASSUME_NONNULL_END
