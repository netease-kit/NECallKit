//
//  NIMQChatAddMemberRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  为某个人定制某频道的权限
 */
@interface NIMQChatAddMemberRoleParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long  channelId;
/**
 * 用户id
 */
@property (nonatomic, copy) NSString *accid;

@end


NS_ASSUME_NONNULL_END
