//
//  NIMMessageSearchOption.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMMessage;
@class NIMSession;
/**
*  云端消息自定义过滤回调
*
*  @param message 待过滤的消息
*  @discussion 返回YES表示该消息被过滤，不入库不会在历史消息结果中返回；返回NO，表示正常处理该消息。
*/
typedef BOOL(^NIMHistoryMessageFilterBlock)(NIMMessage *message);


/**
 *  搜索顺序
 */
typedef NS_ENUM(NSInteger,NIMMessageSearchOrder) {
    /**
     *  从新消息往旧消息查询 forward
     */
    NIMMessageSearchOrderDesc       =   0,
    
    /**
     *  从旧消息往新消息查询 backward
     */
    NIMMessageSearchOrderAsc        =   1,
};


/**
 *  本地搜索选项
 *  @discussion 搜索条件: 时间在(startTime,endTime) 内(不包含)，类型为 messageTypes （或全类型） ，且匹配 searchContent 或 fromIds 的一定数量 (limit) 消息
 */
@interface NIMMessageSearchOption : NSObject

/**
 *  起始时间,默认为0
 */
@property (nonatomic,assign)    NSTimeInterval startTime;


/**
 *  结束时间,默认为0
 *  @discussion 搜索的结束时间,0 表示最大时间戳
 */
@property (nonatomic,assign)    NSTimeInterval endTime;

/**
 *  检索条数
 *  @discussion 默认100条,设置为0表示无条数限制
 */
@property (nonatomic,assign)    NSUInteger limit;

/**
 *  检索顺序
 *
 *  默认从旧消息往新消息查询
 */
@property (nonatomic,assign)    NIMMessageSearchOrder order;

/**
 *  查询的消息类型
 *  @discusssion 消息类型组合，默认只搜索文本类型, 只有在 allMessageTypes 为 NO 时有效，取值范围为: NIMMessageType 枚举类型
 */
@property (nonatomic,copy)    NSArray<NSNumber *> *messageTypes;

/**
*  查询的消息子类型
*  @discusssion 消息子类型组合
*/
@property (nonatomic,strong)  NSArray<NSNumber *> *messageSubTypes;

/**
 *  全部消息类型
 *  @discussion 默认为 NO
 */
@property (nonatomic,assign)    BOOL allMessageTypes;

/**
 *  检索文本
 */
@property (nullable,nonatomic,copy)      NSString *searchContent;

/**
 *  消息发出者帐号列表
 */
@property (nullable,nonatomic,copy)      NSArray<NSString *> *fromIds;

/**
 * 将搜索文本中的正则特殊字符转义，默认 YES
 */
@property (nonatomic,assign) BOOL   enableContentTransfer;
@end


/**
 *  检索服务器历史消息选项 (服务器)
 */
@interface NIMHistoryMessageSearchOption : NSObject

/**
 *  检索消息起始时间
 *  @discussion 需要检索的起始时间,没有则传入0。
 */
@property (nonatomic,assign)      NSTimeInterval  startTime;

/**
 *  检索条数
 *  @discussion 最大限制100条
 */
@property (nonatomic,assign)      NSUInteger       limit;


/**
 *  检索消息终止时间,此参数对聊天室会话无效。
 *  @discussion 当前最早的时间,没有则传入 0。
 */
@property (nonatomic,assign)      NSTimeInterval  endTime;


/**
 *  检索消息的当前参考消息,返回的消息结果集里不会包含这条消息,此参数对聊天室会话无效。优先级低于下面的serverId
 *  @discussion 传入最早时间,没有则传入nil。
 */
@property (nullable,nonatomic,strong)      NIMMessage      *currentMessage;

/**
 *  检索消息的当前参考消息,返回的消息结果集里不会包含这条serverId对应的消息,此参数对聊天室会话无效。优先级高于 上面currentMessage的serverId
 *  @discussion 传入最早时间,没有则传入nil。
 */
@property (nullable,nonatomic,copy)      NSString      *serverId;


/**
 *  检索顺序。
 */
@property (nonatomic,assign)      NIMMessageSearchOrder             order;

/**
 *  是否需要同步到 db，此参数对聊天室会话无效。
 *  @discussion SDK 删除消息分为两种模式：标记删除和彻底删除（参见 NIMDeleteMessagesOption）。
 *  若消息集在本地被标记删除，则意味着消息仍存在本地，但被打上了特殊的记号，同步后写入 db 会失败。
 *  只有不存在本地的消息才可以通过 sync 标记进行 db 存储
 */
@property (nonatomic,assign)      BOOL            sync;


/**
 *  查询的消息类型
 *  @discusssion 消息类型组合，默认为 nil ，搜索全类型。一旦设置了这个字段，则 sync 字段失效，查询结果不会写入 db，需要通过设置syncMessageTypes来同步 。
 */
@property (nonatomic,copy)    NSArray<NSNumber *> *messageTypes;

/**
*  是否需要同步特定类型到 db，此参数对聊天室会话无效。
*  @discussion SDK 删除消息分为两种模式：标记删除和彻底删除（参见 NIMDeleteMessagesOption）。
*  若消息集在本地被标记删除，则意味着消息仍存在本地，但被打上了特殊的记号，同步后写入 db 会失败。
*  只有不存在本地的消息才可以通过 syncMessageTypes 标记进行 db 存储
*/
@property (nonatomic,assign)      BOOL             syncMessageTypes;

/**
*  自定义消息过滤
*  @discusssion 自定义外部过滤回调方法。返回YES表示消息被过滤，不入库不回调，返回NO，表示消息正常入库和回调
*  回调在内部工作线程，注意不要再该回调中执行阻塞或者耗时操作，防止影响内部的消息处理流程。
*/
@property (nullable,nonatomic,strong)  NIMHistoryMessageFilterBlock customFilter;

/**
 * 同步云端消息到到本地时，如果消息所在的最近会话不存在，是否自动创建。默认为NO。
 */
@property (nonatomic,assign) BOOL createRecentSessionIfNotExists;

@end


/**
 *  服务端消息关键字检索选项
 *  @discussion 搜索条件: 时间在(startTime,endTime) 内(不包含)，类型为 messageTypes （或全类型） ，且匹配 searchContent 或 fromIds 的一定数量 (limit) 消息
 */
@interface NIMMessageServerRetrieveOption : NSObject

/**
 *  起始时间,默认为0
 */
@property (nonatomic,assign)    NSTimeInterval startTime;


/**
 *  结束时间,默认为0
 *  @discussion 搜索的结束时间,0 表示最大时间戳
 */
@property (nonatomic,assign)    NSTimeInterval endTime;

/**
 *  检索条数
 *  @discussion 默认100条,设置为0表示无条数限制,最多100条
 */
@property (nonatomic,assign)    NSUInteger limit;

/**
 *  检索顺序
 */
@property (nonatomic,assign)    NIMMessageSearchOrder order;

/**
 *  关键字
 */
@property (nullable,nonatomic,copy)      NSString *keyword;

@end


/**
 *  服务端消息全量检索选项
 *  @discussion 搜索条件: 时间在(startTime,endTime) 内(不包含)，类型为 messageTypes （或全类型） ，且匹配 searchContent 或 fromIds 的一定数量 (limit) 消息
 */
@interface NIMMessageFullKeywordSearchOption : NSObject

/**
 *  关键字
 */
@property (nullable,nonatomic,copy)      NSString *keyword;

/**
 *  起始时间,默认为0
 */
@property (nonatomic,assign)    NSTimeInterval startTime;


/**
 *  结束时间,默认为0
 *  @discussion 搜索的结束时间,0 表示最大时间戳
 */
@property (nonatomic,assign)    NSTimeInterval endTime;

/**
 *  消息的检索条数
 *  @discussion 消息条数限制
 */
@property (nonatomic,assign)    NSUInteger msgLimit;

/**
 *  会话的检索条数
 *  @discussion 会话条数限制
 */
@property (nonatomic,assign)    NSUInteger sessionLimit;

/**
 * 检索结果的排列顺序
 * @diacussion 如果为true，结果按照升序排列，如果为false，按照时间降序排列
 */
@property (nonatomic, assign) BOOL asc;

/**
 * P2P会话列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *p2pArray;

/**
 * 群列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *teamArray;

/**
 * 发送方列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *senderArray;

/**
 * 消息类型列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *msgTypeArray;

/**
 * 消息子类型列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *msgSubtypeArray;

@end


/**
 *  服务端消息全量检索选项
 *  @discussion 搜索条件: 时间在(startTime,endTime) 内(不包含)，类型为 messageTypes （或全类型） ，且匹配 searchContent 或 fromIds 的一定数量 (limit) 消息
 */
@interface NIMMessageFullKeywordSearchOrderByTimeOption : NSObject

/**
 *  关键字
 */
@property (nullable,nonatomic,copy)      NSString *keyword;

/**
 *  起始时间,默认为0
 */
@property (nonatomic,assign)    NSTimeInterval startTime;


/**
 *  结束时间,默认为0
 *  @discussion 搜索的结束时间,0 表示最大时间戳
 */
@property (nonatomic,assign)    NSTimeInterval endTime;

/**
 *  消息的检索条数
 *  @discussion 消息条数限制
 */
@property (nonatomic,assign)    NSUInteger msgLimit;

/**
 * 检索结果的排列顺序
 * @diacussion 如果为true，结果按照升序排列，如果为false，按照时间降序排列
 */
@property (nonatomic, assign) BOOL asc;

/**
 * P2P会话列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *p2pArray;

/**
 * 群列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *teamArray;

/**
 * 发送方列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *senderArray;

/**
 * 消息类型列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *msgTypeArray;

/**
 * 消息子类型列表
 * @discussion
 */
@property (nullable, nonatomic, copy)   NSArray *msgSubtypeArray;

@end


@interface NIMGetMessagesDynamicallyParam : NSObject <NSCopying>

/**
 *  会话session。
 */
@property (nonatomic, strong)      NIMSession  *session;

/**
 *  检索消息起始时间，
 *  @discussion 需要检索的起始时间,时间段的小端，没有则传入0。
 */
@property (nonatomic, assign)      NSTimeInterval  startTime;

/**
 *  检索条数
 *  @discussion 最大限制100条。0相当于100
 */
@property (nonatomic, assign)      NSUInteger       limit;


/**
 *  检索消息终止时间,此参数对聊天室会话无效。
 *  @discussion 时间段的大端, 没有则传入 0。
 */
@property (nonatomic, assign)      NSTimeInterval  endTime;


/**
 *  检索消息的当前参考消息本地id,返回的消息结果集里不会包含这条msgId对应的消息
 */
@property (nullable, nonatomic, copy)    NSString     *anchorClientId;

/**
 *  检索消息的当前参考消息服务端id,返回的消息结果集里不会包含这条serverId对应的消息
 */
@property (nullable, nonatomic, copy)    NSString     *anchorServerId;

/**
 *  检索顺序。
 */
@property (nonatomic,assign)       NIMMessageSearchOrder    order;


- (NIMGetMessagesDynamicallyParam *) createStandardizedParam;

@end

NS_ASSUME_NONNULL_END
