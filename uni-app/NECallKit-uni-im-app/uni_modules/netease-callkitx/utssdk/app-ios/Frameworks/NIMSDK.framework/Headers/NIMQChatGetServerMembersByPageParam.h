//
//  NIMQChatGetServerMembersByPageParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页查询服务器成员信息的参数
 */
@interface NIMQChatGetServerMembersByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 时间戳
 * 拉取不晚于时间戳之前的服务器成员，传0表示拉最新的成员
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 *
 */
@property (nonatomic, assign) NSInteger limit;

@end


NS_ASSUME_NONNULL_END
