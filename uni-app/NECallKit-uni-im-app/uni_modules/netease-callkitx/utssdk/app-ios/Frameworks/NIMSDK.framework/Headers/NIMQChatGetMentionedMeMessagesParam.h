

//
//  NIMQChatGetMentionedMeMessagesParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  分页搜索圈组 @ 我的消息的参数
 */
@interface NIMQChatGetMentionedMeMessagesParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 查询时间范围 currentTime~上次ackTime，可选
 */
@property (nonatomic, assign) NSTimeInterval timetag;

/**
 * 查询数量，可选，默认200
 */
@property (nonatomic, assign) NSInteger  limit;

@end


NS_ASSUME_NONNULL_END


