//
//  NIMQChatRemoveMemberRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  删除频道下某人的定制权限
 */
@interface NIMQChatRemoveMemberRoleParam : NSObject

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
