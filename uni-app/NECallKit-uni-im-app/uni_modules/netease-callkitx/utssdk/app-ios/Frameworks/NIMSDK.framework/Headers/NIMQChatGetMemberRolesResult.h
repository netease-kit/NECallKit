//
//  NIMQChatGetMemberRolesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatMemberRole;
/**
 *  查询channel下人的定制权限的回调
 */
@interface NIMQChatGetMemberRolesResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatMemberRole *> *memberRoleArray;

@end

NS_ASSUME_NONNULL_END

