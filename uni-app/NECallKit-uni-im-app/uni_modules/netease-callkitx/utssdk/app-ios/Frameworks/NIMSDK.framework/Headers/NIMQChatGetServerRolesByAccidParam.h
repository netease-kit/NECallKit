//
//  NIMQChatGetServerRolesByAccidParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  通过accid查询自定义身份组列表
 */
@interface NIMQChatGetServerRolesByAccidParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * accid
 */
@property (nonatomic, copy) NSString *accid;

/**
 * timetag
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 每页个数
 */
@property (nonatomic, assign) NSInteger limit;
@end


NS_ASSUME_NONNULL_END
