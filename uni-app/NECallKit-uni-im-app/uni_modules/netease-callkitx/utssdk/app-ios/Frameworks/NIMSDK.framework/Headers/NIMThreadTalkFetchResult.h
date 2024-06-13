//
//  NIMThreadTalkFetchResult.h
//  NIMLib
//
//  Created by He on 2020/4/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取Thread Talk 接口
 */
@interface NIMThreadTalkFetchResult : NSObject

/**
 *  获取Thread message
 */
@property (nonatomic,strong) NIMMessage *message;
/**
 *  获取Thread 子消息
 */
@property (nonatomic,strong) NSArray *subMessages;
/**
 * 总共的消息数
 */
@property (nonatomic,assign) int64_t total;

/**
 *  Thread聊天里最后一条消息的时间戳, 单位: 秒
 */
@property (nonatomic,assign) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
