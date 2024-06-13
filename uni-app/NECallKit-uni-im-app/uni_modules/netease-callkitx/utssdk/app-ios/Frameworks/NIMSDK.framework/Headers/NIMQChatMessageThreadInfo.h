//
//  NIMQChatMessageThreadInfo.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 圈组消息Thread信息
 */
@interface NIMQChatMessageThreadInfo : NSObject <NSCopying>

/**
 * 总回复数
 */
@property (nonatomic, assign) NSUInteger messageCount;

/**
 * 最后一条消息的时间戳
 */
@property (nonatomic, assign) NSTimeInterval lastMessageTimestamp;

@end

NS_ASSUME_NONNULL_END
