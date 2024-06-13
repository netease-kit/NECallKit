
//
//  NIMQChatUpdateServerMemberBanParam.h
//  NIMSDK
//
//  Created by Evang on 2022/3/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  封禁解封服务器成员入参
 */
@interface NIMQChatUpdateServerMemberBanParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 目标用户accid
 */
@property (nonatomic, copy) NSString *targetAccid;

/**
 * 自定义扩展
 */
@property (nonatomic, copy) NSString *custom;

@end

NS_ASSUME_NONNULL_END

