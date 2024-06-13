

//
//  NIMQChatCheckPermissionsResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询是否有某些权限响应结果
 */
@interface NIMQChatCheckPermissionsResult : NSObject

/**
 *  权限字典
 *  key 为 @[NIMQChatPermissionType], value 为 @[NIMQChatPermissionStatus]
 */
@property (nonatomic, copy) NSDictionary <NSNumber *, NSNumber *> *permissions;


@end


NS_ASSUME_NONNULL_END


