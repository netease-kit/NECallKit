//
//  NIMQChatSubscribeParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@class NIMQChatChannelIdInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  订阅服务器参数
 */
@interface NIMQChatSubscribeServerParam : NSObject
/**
 * 订阅类型
 */
@property (nonatomic, assign) NIMQChatSubscribeType subscribeType;
/**
 * 操作类型
 */
@property (nonatomic, assign) NIMQChatSubscribeOperationType operationType;
/**
 * 操作的对象：server列表
 */
@property (nonnull, nonatomic, copy) NSArray<NSNumber*> *targets;

@end

/**
 *  订阅频道参数
 */
@interface NIMQChatSubscribeChannelParam : NSObject
/**
 * 订阅类型
 */
@property (nonatomic, assign) NIMQChatSubscribeType subscribeType;
/**
 * 操作类型
 */
@property (nonatomic, assign) NIMQChatSubscribeOperationType operationType;
/**
 * 操作的对象：频道ID列表
 */
@property (nonnull, nonatomic, copy) NSArray<NIMQChatChannelIdInfo *> *targets;

@end

NS_ASSUME_NONNULL_END
