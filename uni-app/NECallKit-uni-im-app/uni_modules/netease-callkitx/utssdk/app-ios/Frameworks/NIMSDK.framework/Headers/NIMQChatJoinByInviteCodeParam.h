//
//  NIMQChatRevokeMessageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;
@class NIMQChatUpdateParam;

NS_ASSUME_NONNULL_BEGIN

/**
 *  通过邀请码加入服务器的参数
 */
@interface NIMQChatJoinByInviteCodeParam : NSObject <NSCopying>

/**
* 服务器ID
*/
@property(nonatomic, assign) unsigned long long serverId;
/**
 * 邀请码
 */
@property(nullable, nonatomic, copy) NSString* inviteCode;
/**
 * 附言
 */
@property(nullable, nonatomic, copy) NSString* postscript;

@end

NS_ASSUME_NONNULL_END
