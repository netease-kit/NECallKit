//
//  NIMQChatRejectServerInviteParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  拒绝邀请的参数
 */
@interface NIMQChatRejectServerInviteParam : NSObject <NSCopying>
/**
 * 圈组服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 邀请对象的账号数组
 */
@property (nonnull, nonatomic, copy) NSString * accid;

/**
 * 附言（最长5000）
 */
@property (nullable, nonatomic, copy) NSString *postscript;

/**
 * 邀请ID
 */
@property (nonatomic, assign) unsigned long long requestId;
@end


NS_ASSUME_NONNULL_END
