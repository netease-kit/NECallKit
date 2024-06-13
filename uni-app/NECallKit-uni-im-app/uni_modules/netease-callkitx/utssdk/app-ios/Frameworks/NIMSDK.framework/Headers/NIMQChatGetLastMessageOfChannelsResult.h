//
//  NIMQChatGetLastMessageOfChannelsResult.h
//  NIMSDK
//
//  Created by Evang on 2022/5/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatMessage;
NS_ASSUME_NONNULL_BEGIN

// 批量获取频道最后一条消息的结果
@interface NIMQChatGetLastMessageOfChannelsResult : NSObject

/**
 * 字典形式，channelId对应最后一条消息，[@(channelId): NIMQChatMessage]
 */
@property (nonatomic, strong) NSDictionary<NSNumber *, NIMQChatMessage *> *lastMessageOfChannelDic;

@end

NS_ASSUME_NONNULL_END
