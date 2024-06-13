

//
//  NIMQChatCheckPermissionsParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询自己是否有某些权限入参
 */
@interface NIMQChatCheckPermissionsParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 频道ID
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 权限列表
 *  元素为  NIMQChatPermissionType 的NSNumber 包装
 */
@property (nonatomic, copy) NSArray <NSNumber *> *permissions;



@end


NS_ASSUME_NONNULL_END


