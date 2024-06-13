//
//  NIMQChatGetMessageHistoryByIdsParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessageServerIdInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  从服务端按ID查询历史消息的参数类型
 */
@interface NIMQChatGetMessageHistoryByIdsParam : NSObject

/**
 * 圈组服务器ID
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 圈组频道ID
 */
@property(nonatomic, assign) unsigned long long channelId;

/**
 * 圈组频道消息id数组
 *  @discussion 仅填充NIMQChatMessageRefer中serverID和timestamp
 */
@property(nonatomic, strong) NSArray<NIMQChatMessageServerIdInfo *> *ids;

@end



NS_ASSUME_NONNULL_END
