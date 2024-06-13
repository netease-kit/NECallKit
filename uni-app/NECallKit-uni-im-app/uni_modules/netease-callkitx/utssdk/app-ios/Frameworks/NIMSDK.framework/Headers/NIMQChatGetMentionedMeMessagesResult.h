//
//  NIMQChatGetMentionedMeMessagesResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

 @class NIMQChatMessage;

/**
 * 分页查询 @ 我的圈组消息的结果
 */
@interface NIMQChatGetMentionedMeMessagesResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 查询游标，下一次查询的起始位置
 */
@property(nullable, nonatomic, copy) NSString *cursor;

/**
 * 圈组消息数组
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatMessage *> *messages;

@end


NS_ASSUME_NONNULL_END


