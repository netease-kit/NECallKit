
//
//  NIMQChatGetServerBanedMembersByPageParam.h
//  NIMSDK
//
//  Created by Evang on 2022/3/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

/**
 *  分页获取封禁服务器成员入参
 */
@interface NIMQChatGetServerBanedMembersByPageParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * timetag 按照封禁时间逆序 传0取当前时间戳
 */
@property (nonatomic, assign) NSTimeInterval  timetag;

/**
 * limit 不传默认100
 */
@property (nonatomic, strong) NSNumber *limit;

@end

NS_ASSUME_NONNULL_END

