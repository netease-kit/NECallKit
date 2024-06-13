//
//  NIMQChatAddServerRoleMembersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  将某些人加入某服务器身份组
 */
@interface NIMQChatAddServerRoleMembersParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 用户accids
 */
@property (nonnull, nonatomic, copy) NSArray <NSString *> *accountArray;

@end


NS_ASSUME_NONNULL_END
