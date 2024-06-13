//
//  NIMQChatRemoveChannelCategoryRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  删除某频道分组下的某身份组
 */
@interface NIMQChatRemoveChannelCategoryRoleParam : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;

@end


NS_ASSUME_NONNULL_END
