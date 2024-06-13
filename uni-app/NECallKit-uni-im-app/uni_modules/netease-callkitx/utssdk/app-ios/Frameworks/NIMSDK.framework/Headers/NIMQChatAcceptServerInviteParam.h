//
//  NIMQChatAcceptServerInviteParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  接受邀请的参数
 */
@interface NIMQChatAcceptServerInviteParam : NSObject <NSCopying>

/**
 * 接受加入的服务器Id，必填
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 发起邀请者的账号，必填
 */
@property (nonnull, nonatomic, copy) NSString * accid;

/**
 * 邀请ID
 */
@property (nonatomic, assign) unsigned long long requestId;
@end


NS_ASSUME_NONNULL_END
