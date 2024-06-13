//
//  NIMIndexManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2021 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;
@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  索引类型
 */
typedef NS_ENUM(NSInteger, NIMIndexType) {
    /**
     *  消息文本
     */
    NIMIndexTypeMsgText = 0,

    /**
     *  自定义索引类型起始
     */
    NIMIndexTypeCustomBase = 100,
};

/**
 *  索引文本
 */
@interface NIMIndexText : NSObject

/**
 *  索引文本
 */
@property (nonatomic, copy)     NSString *text;

/**
 *  索引类型
 */
@property (nonatomic, assign)   NSInteger type;

@end

/**
 *  消息索引记录结构
 */
@interface NIMMsgIndexRecord : NSObject<NSCopying>

/**
 *  消息ID
 */
@property (nullable, nonatomic, copy) NSString * messageId;

/**
 *  索引文本
 */
@property (nullable, nonatomic, copy) NSString * indexText;

/**
 *  索引类型
 */
@property (nonatomic, assign) NSInteger indexType;

/**
 *  会话
 */
@property (nonatomic, copy) NIMSession * session;

/**
 *  时间
 */
@property (nonatomic, assign) NSTimeInterval timestamp;

/**
 *  消息
 */
@property (nullable, nonatomic) NIMMessage * message;

@end

typedef NS_ENUM(NSInteger, NIMMsgIndexTimeOrder) {
    /**
     *  消息时间从新往旧
     */
    NIMMsgIndexTimeOrderDesc = 0,
    
    /**
     *  消息时间从旧往新
     */
    NIMMsgIndexTimeOrderAsc = 1,
};

@interface NIMMsgIndexQueryOption : NSObject

/**
 *  起始时间,默认为0
 */
@property (nonatomic, assign)               NSTimeInterval startTime;

/**
 *  结束时间,默认为0
 *  @discussion 搜索的结束时间,0 表示最大时间戳
 */
@property (nonatomic, assign)               NSTimeInterval endTime;

/**
 *  检索顺序
 */
@property (nonatomic, assign)               NIMMsgIndexTimeOrder timeOrder;

/**
 *  检索条数
 */
@property (nonatomic, assign)               NSUInteger limit;

@end

/**
 *  在消息索引结果基础上查询消息 Block
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMMsgIndexQueryMsgBlock)(NSError * __nullable error);

@interface NIMMsgIndexQueryResult : NSObject

/**
 *  不包含任何结果
 */
@property (nonatomic, readonly) BOOL empty;

/**
 *  排序的会话列表
 */
@property (nonatomic, nullable, readonly) NSArray<NIMSession *> * sessions;

/**
 *  分会话索引记录
 */
@property (nonatomic, nullable, readonly) NSDictionary<NIMSession *, NSArray<NIMMsgIndexRecord *> *> * records;

/**
 *  是否包含消息
 */
@property (nonatomic, readonly) BOOL withMesssage;

/**
 *  分会话索引记录
 *
 *  @param session    指定会话
 *  @discussion
 */
- (NSArray<NIMMessage *> *)messages:(nonnull NIMSession *)session;

/**
 *  查询结果中的消息数量
 *
 *  @param session    指定会话，不传表示所有
 *  @discussion
 */
- (NSUInteger)messageCount:(nullable NIMSession *)session;

/**
 *  查询消息
 *
 *  @param session    指定会话，不传表示所有
 *  @param completion 完成回调
 *  @discussion 消息结果记录在查询结果中
 */
- (void)queryMessage:(nullable NIMSession *)session
          completion:(nullable NIMMsgIndexQueryMsgBlock)completion;

@end

/**
 *  消息索引生成委托
 */
@protocol NIMMsgIndexProduceDelegate <NSObject>

@optional

- (nullable NSString *)produceText:(NIMMessage *)message;

- (nullable NSArray<NIMIndexText *> *)produceTexts:(NIMMessage *)message;

@end

/**
 *  同步消息索引 Block
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMSyncMsgIndexBlock)(NSError * __nullable error);

/**
 *  查询消息索引 Block
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMQueryMsgIndexBlock)(NSError * __nullable error, NIMMsgIndexQueryResult * __nullable result);

/**
 *  重置消息索引 Block
 *
 *  @param error 错误信息,如果成功,error 为 nil
 */
typedef void(^NIMResetMsgIndexBlock)(NSError * __nullable error);

/**
 *  索引委托
 */
@protocol NIMIndexManagerDelegate <NSObject>

@optional

@end

/**
 *  索引协议
 */
@protocol NIMIndexManager <NSObject>

/**
 *  同步消息索引
 *
 *  @param old    同步方向，YES往老方向，NO往新方向
 *  @param session    指定会话，不传表示所有
 *  @param completion 完成回调
 *  @discussion 老方向和新方向不代表消息产生时间，而是指存入本地的时间
 */
- (void)syncMsgIndex:(BOOL)old
             session:(nullable NIMSession *)session
          completion:(nullable NIMSyncMsgIndexBlock)completion;

/**
 *  查询消息索引
 *
 *  @param text    查询文本
 *  @param session    指定会话，不传表示所有
 *  @param option    查询选项
 *  @param withMesssage 是否查询消息
 *  @param completion 完成回调
 *  @discussion 老方向和新方向不代表消息产生时间，而是指存入本地的时间
 */
- (void)queryMsgIndex:(nonnull NSString *)text
              session:(nullable NIMSession *)session
               option:(nullable NIMMsgIndexQueryOption *)option
          withMessage:(BOOL)withMessage
           completion:(nullable NIMQueryMsgIndexBlock)completion;

/**
 *  重置消息索引
 *
 *  @param completion 完成回调
 */
- (void)resetMsgIndex:(nullable NIMResetMsgIndexBlock)completion;

/**
 *  添加索引委托
 *
 *  @param delegate 检索委托
 */
- (void)addDelegate:(id<NIMIndexManagerDelegate>)delegate;

/**
 *  移除索引委托
 *
 *  @param delegate 检索委托
 */
- (void)removeDelegate:(id<NIMIndexManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
