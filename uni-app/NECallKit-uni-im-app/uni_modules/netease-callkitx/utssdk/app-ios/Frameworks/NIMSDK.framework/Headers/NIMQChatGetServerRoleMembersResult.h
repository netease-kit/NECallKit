//
//  NIMQChatGetServerRoleMembersResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerRoleMember;
/**
 *  查询某服务器下某身份组下的成员列表
 */
@interface NIMQChatGetServerRoleMembersResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatServerRoleMember *> *memberArray;

@end

NS_ASSUME_NONNULL_END

