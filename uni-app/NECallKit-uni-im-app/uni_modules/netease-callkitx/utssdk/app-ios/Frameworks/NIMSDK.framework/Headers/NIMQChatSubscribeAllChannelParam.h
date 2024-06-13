

//
//  NIMQChatSubscribeAllChannelParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  订阅服务器下所有频道的参数
 */
@interface NIMQChatSubscribeAllChannelParam : NSObject

/**
 * 订阅类型，只支持一下三种类型
 * NIMQChatSubscribeTypeChannelMsg = 1,
 * NIMQChatSubscribeTypeChannelMsgUnreadCount = 2,
 * NIMQChatSubscribeTypeChannelMsgUnreadStatus = 3,
 */
@property (nonatomic, assign) NIMQChatSubscribeType subscribeType;

/**
 * 服务器id 数组，元素为 serverId 的NSNumber 包装
 */
@property (nonatomic, copy) NSArray<NSNumber *> *serverIds;


@end


NS_ASSUME_NONNULL_END


