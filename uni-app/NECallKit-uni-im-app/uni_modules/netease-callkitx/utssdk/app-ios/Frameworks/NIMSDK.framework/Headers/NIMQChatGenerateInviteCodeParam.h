//
//  NIMQChatGenerateInviteCodeParam.h
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
 *  生成邀请码的参数
 */
@interface NIMQChatGenerateInviteCodeParam : NSObject <NSCopying>

/**
 * 服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 有效期（秒），NSTimeInterval
 */
@property(nullable, nonatomic, copy) NSNumber *ttl;

@end

NS_ASSUME_NONNULL_END
