//
//  NIMQChatGetServerRolesByAccidResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatServerRole;

/**
 *  通过accid查询自定义身份组列表
 */
@interface NIMQChatGetServerRolesByAccidResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatServerRole *> *serverRoles;

@end

NS_ASSUME_NONNULL_END

