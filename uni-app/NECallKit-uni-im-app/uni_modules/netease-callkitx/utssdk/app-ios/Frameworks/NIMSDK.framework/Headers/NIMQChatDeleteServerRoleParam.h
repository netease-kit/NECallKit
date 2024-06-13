//
//  NIMQChatDeleteServerRoleParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  删除服务器身份组参数
 */
@interface NIMQChatDeleteServerRoleParam : NSObject
/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
@end


NS_ASSUME_NONNULL_END
