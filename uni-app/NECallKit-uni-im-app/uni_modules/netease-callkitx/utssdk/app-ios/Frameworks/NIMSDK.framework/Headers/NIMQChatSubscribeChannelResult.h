//
//  NIMQChatSubscribeChannelResult.h
//  NIMLib
//
//  Created by Evang on 2022/6/9.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannelIdInfo;
/**
 * 订阅频道结果
 */
@interface NIMQChatSubscribeChannelResult : NSObject
/**
 * 订阅失败的频道信息
 */
@property (nonatomic, copy) NSArray <NIMQChatChannelIdInfo *> *faildChannels;

@end

NS_ASSUME_NONNULL_END
