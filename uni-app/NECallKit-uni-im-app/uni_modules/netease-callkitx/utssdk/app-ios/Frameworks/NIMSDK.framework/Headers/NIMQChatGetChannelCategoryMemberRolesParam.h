//
//  NIMQChatGetChannelCategoryMemberRolesParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询频道分组中个人的定制权限
 */
@interface NIMQChatGetChannelCategoryMemberRolesParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long  categoryId;

/**
 * timetag
 */
@property (nonatomic, assign) NSTimeInterval timeTag;

/**
 * 每页个数
 */
@property (nonatomic, strong) NSNumber *limit;

@end


NS_ASSUME_NONNULL_END
