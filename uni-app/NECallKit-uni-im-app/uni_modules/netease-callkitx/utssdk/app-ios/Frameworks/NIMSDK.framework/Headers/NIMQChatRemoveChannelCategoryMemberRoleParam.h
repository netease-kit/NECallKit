//
//  NIMQChatRemoveChannelCategoryMemberRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  删除频道分组下某人的定制权限
 */
@interface NIMQChatRemoveChannelCategoryMemberRoleParam : NSObject

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
