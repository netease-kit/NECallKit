//
//  NIMQChatPermissionStatusInfo.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN


@interface NIMQChatPermissionStatusInfo : NSObject<NSCopying>
/**
 * 自定义权限
 */
@property (nonatomic, assign) NSInteger customType;
/**
 * 权限(预制权限)
 */
@property (nonatomic, assign) NIMQChatPermissionType type; NS_DEPRECATED_IOS(9_0_0, 9_5_0, "use customType");
/**
 * 权限状态
 */
@property (nonatomic, assign) NIMQChatPermissionStatus status;

@end

NS_ASSUME_NONNULL_END
