//
//  NIMQChatGetLastMessageOfChannelsParam.h
//  NIMSDK
//
//  Created by Evang on 2022/5/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 批量获取频道最后一条消息的入参 
@interface NIMQChatGetLastMessageOfChannelsParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 频道id数组： [@(channelId)]
 */
@property (nonatomic, copy) NSArray <NSNumber *> *channelIds;


@end

NS_ASSUME_NONNULL_END
