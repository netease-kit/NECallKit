
//
//  NIMQChatGetChannelCategoryMemberRolesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannelCategoryMemberRole;
/**
 *  查询频道分组中个人的定制权限的回调
 */
@interface NIMQChatGetChannelCategoryMemberRolesResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatChannelCategoryMemberRole *> *memberRoleArray;

@end

NS_ASSUME_NONNULL_END

