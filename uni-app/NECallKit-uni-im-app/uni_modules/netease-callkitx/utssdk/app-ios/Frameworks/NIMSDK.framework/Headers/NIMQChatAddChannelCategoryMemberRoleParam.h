//
//  NIMQChatAddChannelCategoryMemberRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  为某个人定制某频道分组的权限
 */
@interface NIMQChatAddChannelCategoryMemberRoleParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;
/**
 * 用户id
 */
@property (nonatomic, copy) NSString *accid;

@end


NS_ASSUME_NONNULL_END
