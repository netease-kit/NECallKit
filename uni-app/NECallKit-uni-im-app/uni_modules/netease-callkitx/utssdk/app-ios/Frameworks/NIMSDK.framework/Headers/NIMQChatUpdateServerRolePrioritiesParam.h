
//
//  NIMQChatupdateServerRolePrioritiesParam.h
//  NIMSDK
//
//  Created by Evang on 2022/2/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@class NIMQChatUpdateServerRolePriorityItem;
/**
 *  批量更新服务器身份组优先级入参
 */
@interface NIMQChatupdateServerRolePrioritiesParam : NSObject

@property (nonatomic, assign) unsigned long long serverId;
/**
 * 要更新的身份组优先级数组
 */
@property (nonatomic, copy) NSArray <NIMQChatUpdateServerRolePriorityItem *> *updateItems;

@end


@interface NIMQChatUpdateServerRolePriorityItem : NSObject

/**
 *  服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 身份组id
 */
@property (nonatomic, assign) unsigned long long roleId;
/**
 * 优先级
 */
@property (nonatomic, strong) NSNumber *priority;

@end

NS_ASSUME_NONNULL_END

