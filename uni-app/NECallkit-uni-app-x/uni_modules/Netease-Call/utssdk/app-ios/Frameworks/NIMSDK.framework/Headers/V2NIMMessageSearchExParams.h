//
//  V2NIMMessageSearchExParams.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMBase.h"
#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

/// 消息方向
typedef NS_ENUM(NSInteger, V2NIMSearchDirection) {
    V2NIM_SEARCH_DIRECTION_BACKWARD                 = 0,  ///< 表示时间从新到老查询
    V2NIM_SEARCH_DIRECTION_FORWARD                  = 1,  ///< 表示时间从老到新查询
};

/// 消息检索策略
typedef NS_ENUM(NSInteger, V2NIMSearchStrategy) {
    V2NIM_SEARCH_STRATEGY_SQL_LIKE                  = 0,  ///< 表示基于SQL模糊查询（LIKE）
    V2NIM_SEARCH_STRATEGY_FTS                       = 1,  ///< 表示基于全文检索（FULL_TEXT_SEARCH）
};

/// 消息检索参数
@interface V2NIMMessageSearchExParams : NSObject

/// 搜索 “全部会话” 还是搜索 “指定的会话” conversationId 为空（nil），搜索全部会话；conversationId 不为空，搜索指定会话。
@property (nonatomic,strong,nullable) NSString *conversationId;

/// 最多支持 5 个。当消息发送者以及消息类型均未指定时，必须设置关键字列表；否则，关键字列表可以为空。nil 和count==0 都表示为空
@property (nonatomic,strong,nullable) NSArray<NSString *> *keywordList;
/// 是否对关键字进行分词，默认值NO
@property (nonatomic,assign) BOOL tokenize;
/// 指定关键字列表匹配类型。可设置为 “或” 关系搜索，或 “与” 关系搜索。取值分别为 V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR 和 V2NIM_SEARCH_KEYWORD_MATH_TYPE_AND。默认为 “或” 关系搜索。
@property (nonatomic,assign) V2NIMSearchKeywordMathType keywordMatchType;
/// 消息检索的策略， 仅客户端生效。默认值V2NIM_SEARCH_STRATEGY_FTS，V2NIM_SEARCH_STRATEGY_SQL_LIKE仅当指定conversationId参数时有效
@property (nonatomic,assign) V2NIMSearchStrategy strategy;

/// 指定 accountId 发送的消息。最多支持 5 个。超过返回参数错误， accountid默认只检查数量， 不检查是否重复。nil 和count==0 都表示没有指定人数
@property (nonatomic,strong,nullable) NSArray<NSString *> *senderAccountIds;
/// 根据消息类型检索消息，为nil或空列表， 则表示查询所有消息类型。关键字不为空时， 不支持检索通知类消息。非文本消息，只检索对应检索字段，如果检索字段为空则该消息不回被检索到
@property (nonatomic,strong,nullable) NSArray<NSNumber *> *messageTypes;
/// 根据消息子类型检索消息，为nil或空列表， 则表示查询所有消息子类型。关键字不为空时，非文本消息，只检索对应检索字段，如果检索字段为空则该消息不回被检索到
@property (nonatomic,strong,nullable) NSArray<NSNumber *> *messageSubtypes;

/// 搜索的起始时间点，UTC 时间戳，单位：毫秒。默认为0。 当direction == V2NIM_SEARCH_DIRECTION_BACKWARD时：如果值为0，表示从当前时间开始。
@property (nonatomic,assign) int64_t searchStartTime;
/// 搜索的时间跨度，UTC 时间戳，单位：毫秒（24 x 60 x 60 x 1000 代表一天）。 默认为 0。当值为0时，表示最大时间跨度。1. 当direction == V2NIM_SEARCH_DIRECTION_BACKWARD时： 结束时间确定为searchStartTime - searchTimePeriod（最小为0）。1. 当direction == V2NIM_SEARCH_DIRECTION_FORWARD时： 结束时间确定为searchStartTime + searchTimePeriod（最大为MAX INT64）。
@property (nonatomic,assign) int64_t searchTimePeriod;

/// 检索方向，默认值V2NIM_SEARCH_DIRECTION_BACKWARD
@property (nonatomic,assign) V2NIMSearchDirection direction;

/// 只返回索引，默认值NO
@property (nonatomic,assign) BOOL onlyIndex;

/// 搜索的数量。最大100
@property (nonatomic,assign) NSInteger limit;
/// 搜索的起始位置，第一次填写空字符串，续拉时填写上一次返回的 V2NIMMessageSearchResult 中的 nextPageToken。两次查询参数必须一致
@property (nonatomic,strong,nullable) NSString *pageToken;

@end

NS_ASSUME_NONNULL_END
