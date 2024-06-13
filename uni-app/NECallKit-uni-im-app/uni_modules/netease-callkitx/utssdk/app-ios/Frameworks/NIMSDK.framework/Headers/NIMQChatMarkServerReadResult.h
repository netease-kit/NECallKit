

//
//  NIMQChatMarkServerReadResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 设置服务器下消息已读的结果
 */
@interface NIMQChatMarkServerReadResult : NSObject

/**
 * 设置成功的服务器ID 数组，元素为 服务器ID 的 NSNumber 包装
 */
@property (nonatomic, copy) NSArray <NSNumber *> *successServerIds;

/**
 * 设置失败的服务器ID 数组，元素为 服务器ID 的 NSNumber 包装
 */
@property (nonatomic, copy) NSArray <NSNumber *> *failServerIds;

/**
 * 清空未读的服务器时间戳，这个时间戳之前的频道消息都认为是已读
 */
@property (nonatomic, assign) NSTimeInterval ackTimestamp;


@end


NS_ASSUME_NONNULL_END


