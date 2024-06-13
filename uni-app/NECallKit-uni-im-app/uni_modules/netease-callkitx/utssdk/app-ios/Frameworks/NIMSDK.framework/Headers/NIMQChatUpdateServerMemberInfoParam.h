//
//  NIMQChatUpdateServerMemberInfoParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  修改他人服务器成员信息
 */
@interface NIMQChatUpdateServerMemberInfoParam : NSObject

@property (nonatomic, assign) unsigned long long  serverId;

@property (nonnull, nonatomic, copy) NSString *accid;

@property (nonatomic, copy) NSString *nick;

@property (nonatomic, copy) NSString *avatar;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;

@end

NS_ASSUME_NONNULL_END
