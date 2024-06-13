//
//  NIMQChatSendSystemNotificationResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  生成邀请码的回调类型
 */
@interface NIMQChatGenerateInviteCodeResult : NSObject <NSCopying>
/**
 * 服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;
/**
 * 唯一标识
 */
@property(nonatomic, assign) long requestId;
/**
 * 邀请码
 */
@property(nullable, nonatomic, copy) NSString *inviteCode;
/**
 * 过期时间戳（秒）
 */
@property(nonatomic, assign) NSTimeInterval expireTime;
@end


NS_ASSUME_NONNULL_END
