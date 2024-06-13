//
//  NIMQChatGetServerRolesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatServerRole;
/**
 *  查询服务器下身份组列表
 */
@interface NIMQChatGetServerRolesResult : NSObject

/**
 *  身份组列表
 */
@property (nonatomic, copy) NSArray <NIMQChatServerRole *> *serverRoleArray;

/**
 *  是否是本身份组成员的roleId的集合，roleId需要解析成unsigned long long类型
 */
@property (nonatomic, copy) NSSet <NSNumber *> *isMemberSet;

@end

NS_ASSUME_NONNULL_END

