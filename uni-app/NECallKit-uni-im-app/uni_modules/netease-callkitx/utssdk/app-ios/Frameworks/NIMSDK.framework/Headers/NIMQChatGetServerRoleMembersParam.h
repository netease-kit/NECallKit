//
//  NIMQChatGetServerRoleMembersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询某服务器下某身份组下的成员列表
 */
@interface NIMQChatGetServerRoleMembersParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long roleId;

/**
 * timetag
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 查询的起始accid,第一页时填空串
 */
@property (nonatomic, copy) NSString *accid;

/**
 * 每页个数
 */
@property (nonatomic, assign) NSInteger limit;

@end


NS_ASSUME_NONNULL_END
