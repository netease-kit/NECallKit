//
//  NIMQChatUpdateMyMemberInfoParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerMember;

/**
 *  更新服务器成员
 */
@interface NIMQChatUpdateMyMemberInfoParam : NSObject

@property (nonatomic, assign) unsigned long long  serverId;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *custom;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;

@end


NS_ASSUME_NONNULL_END
