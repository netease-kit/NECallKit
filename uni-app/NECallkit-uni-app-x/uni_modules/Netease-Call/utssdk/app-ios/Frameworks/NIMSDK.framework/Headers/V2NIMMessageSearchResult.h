//
//  V2NIMMessageSearchResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessage;
@class V2NIMMessageSearchItem;
@class V2NIMMessageIndex;

NS_ASSUME_NONNULL_BEGIN

///  检索返回结果
@interface V2NIMMessageSearchResult : NSObject

/// 满足检索条件的所有消息数量
@property (nonatomic,assign,readonly) NSInteger count;

/// 单个会话的返回结果：如果查询会话id不会空， 则返回items会对应会话按指定条数检索出来的消息。如果会话id为空，则为每一个会话检索出来的内容。单个items查出的消息按从新到旧排序。多个会话的返回结果：按每个会话的最新消息从新到旧排序
@property (nonatomic,strong,readonly) NSArray<V2NIMMessageSearchItem *> *items;

/// 下次请求的token，两次查询参数必须一致
@property (nonatomic,strong,nullable,readonly) NSString *nextPageToken;

/// 是否还有数据
@property (nonatomic,assign,readonly) BOOL hasMore;

@end

/// 消息检索单条会话的返回结果
@interface V2NIMMessageSearchItem : NSObject

/// 会话id
@property (nonatomic,strong,readonly) NSString *conversationId;
/// 返回的消息列表
@property (nonatomic,strong,readonly) NSArray<V2NIMMessage *> *messages;
/// 返回的消息索引列表
@property (nonatomic,strong,readonly) NSArray<V2NIMMessageIndex *> *messageIndexes;
/// 单个会话的返回数量
@property (nonatomic,assign,readonly) NSInteger count;

@end

NS_ASSUME_NONNULL_END
