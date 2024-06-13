//
//  NIMQChatKickServerMembersParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  踢出服务器成员的参数
 */
@interface NIMQChatKickServerMembersParam : NSObject
/**
 * 圈组服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 踢出对象的账号数组
 */
@property (nonnull, nonatomic, copy) NSArray<NSString *> * accids;
@end


NS_ASSUME_NONNULL_END
