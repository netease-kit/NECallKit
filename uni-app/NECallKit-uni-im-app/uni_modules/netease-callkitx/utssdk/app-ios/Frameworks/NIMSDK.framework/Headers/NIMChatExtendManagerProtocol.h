//
//  NIMThreadTalkManagerProtocol.h
//  NIMLib
//
//  Created by He on 2020/3/27.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMChatManagerProtocol.h"

@class NIMMessage;
@class NIMSession;
@class NIMRecentSession;
@class NIMThreadTalkFetchOption;
@class NIMThreadTalkFetchResult;
@class NIMChatExtendBasicInfo;
@class NIMQuickComment;
@class NIMCollectInfo;
@class NIMCollectQueryOptions;
@class NIMAddCollectParams;
@class NIMSyncMessagePinResponse;
@class NIMMessagePinItem;
@class NIMStickTopSessionInfo;
@class NIMSyncStickTopSessionResponse;
@class NIMAddStickTopSessionParams;
@class NIMSyncMessagePinRequest;
@class NIMLoadRecentSessionsOptions;

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取Thread Talk子消息回调
 *
 *  @param error    请求结果
 *  @param result   请求结果数据
 */
typedef void (^NIMThreadTalkFetchMessages) (NSError * _Nullable  error, NIMThreadTalkFetchResult * _Nullable result);

/**
 *  获取Thread Talk子消息回调
 *
 *  @param error    错误结果
 *  @param result   子消息列表
 */
typedef void (^NIMFetchHistoryMessagesByIds) (NSError * _Nullable  error, NSMapTable<NIMChatExtendBasicInfo *, NIMMessage *> * _Nullable result);

/**
 *  完成回调
 *
 *  @param error 错误码
 */
typedef void (^NIMQuickCommentHandler) (NSError * _Nullable error);

/**
 *  本地获取快捷评论结果
 *
 *  @param error 错误结果
 *  @param result 获取结果
 */
typedef void (^NIMGetQuickCommentsByMsgHandler) (NSError * _Nullable error, NSMapTable<NSNumber *, NSArray<NIMQuickComment *> *> * _Nullable result);

/**
 *  批量获取
 *
 *  @param error 结果
 *  @param result 评论列表
 *  @param failedMessages 查询失败的列表

 */
typedef void (^NIMFetchCommentsByMsgsHandler) (NSError * _Nullable  error, NSMapTable<NIMMessage *, NSArray<NIMQuickComment *> * > * _Nullable result, NSArray<NIMMessage *> * _Nullable failedMessages);

/**
 *  读取收藏列表回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param collectInfos 读取的消息列表
 *  @param totalCount 收藏总条数，用来判断是否还有更多
 */
typedef void(^NIMCollectQueryBlock)(NSError * _Nullable error,
                                              NSArray<NIMCollectInfo *> * _Nullable collectInfos,
                                              NSInteger totalCount);

/**
 *  添加收藏回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param collectInfo 添加的收藏
 */
typedef void(^NIMAddCollectBlock)(NSError * _Nullable error, NIMCollectInfo * _Nullable collectInfo);

/**
 *  更新收藏回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param total_removed 删除的数量
 */
typedef void(^NIMRemoveCollectBlock)(NSError * _Nullable error, NSInteger total_removed);

/**
 *  移除收藏回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param collectInfo 更新后的收藏
 */
typedef void(^NIMUpdateCollectBlock)(NSError * _Nullable error, NIMCollectInfo * _Nullable collectInfo);

/**
 *  添加置顶会话回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param newInfo 被添加的置顶会话
 */
typedef void(^NIMAddStickTopSessionCompletion)(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable newInfo);

/**
 *  移除置顶会话回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param removedInfo 被删除的置顶信息
 */
typedef void(^NIMRemoveStickTopSessionCompletion)(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable removedInfo);

/**
 *  更新置顶会话回调block
 *
 *  @param error  错误,如果成功则error为nil
 *  @param updatedInfo 更新后的置顶会话
 */
typedef void(^NIMUpdateStickTopSessionCompletion)(NSError * _Nullable error, NIMStickTopSessionInfo * _Nullable updatedInfo);


/**
 *  本地查找置顶会话回调block
 *
 *  @param infos 所有本地置顶会话信息
 */
typedef void(^NIMLoadStickTopSessionInfosCompletion)(NSError * _Nullable error, NSDictionary<NIMSession*,NIMStickTopSessionInfo *> * _Nullable infos);

/**
 * 添加PIN记录的回调
 *  @param error  错误,如果成功则error为nil
 *  @param item 新增的PIN记录
 */
typedef void(^NIMAddMessagePinCompletion)(NSError * _Nullable error, NIMMessagePinItem * _Nullable item);

/**
 * 移除Pin的回调
 *  @param error  错误,如果成功则error为nil
 *  @param item 被移除的PIN记录
 */
typedef void(^NIMRemoveMessagePinCompletion)(NSError * _Nullable error, NIMMessagePinItem * _Nullable item);

/**
 * 更新PIN记录的回调
 *  @param error  错误,如果成功则error为nil
 *  @param item 被更新的PIN记录
 */
typedef void(^NIMUpdateMessagePinCompletion)(NSError * _Nullable error, NIMMessagePinItem * _Nullable item);

/**
 * 增量更新PIN记录的回调
 *  @param error  错误,如果成功则error为nil
 *  @param response 更新成功后的响应对象
 */
typedef void(^NIMSyncMessagePinCompletion)(NSError * _Nullable error, NIMSyncMessagePinResponse * _Nullable response);

/**
 * 加载PIN记录的回调
 *  @param error  错误,如果成功则error为nil
 *  @param items 更新成功后的所有pin消息
 */
typedef void(^NIMLoadMessagePinsCompletion)(NSError * _Nullable error, NSArray<NIMMessagePinItem *> * _Nullable items);

/**
 * 查找最近会话回调
 * @param recentSessions 最近会话列表
 */
typedef void(^NIMLoadRecentSessionsCompletion)(NSError * _Nullable error, NSArray<NIMRecentSession *> * _Nullable recentSessions);

/**
 *  Thread Talk 回调
 */
@protocol NIMChatExtendManagerDelegate <NSObject>


#pragma mark - 快捷回复
@optional

/**
 *  新增快捷评论
 *
 *  @param comment 评论
 */
- (void)onRecvQuickComment:(NIMQuickComment *)comment;

/**
 *  移除快捷评论
 *
 *  @param comment 被删评论
 */
- (void)onRemoveQuickComment:(NIMQuickComment *)comment;

/**
 * 一条PIN被增加的在线通知
 * @param item 新增的PIN记录
 */
- (void)onNotifyAddMessagePin:(NIMMessagePinItem *)item;

/**
 * 一条PIN被移除的在线通知
 * @param item 被移除的PIN记录
 */
- (void)onNotifyRemoveMessagePin:(NIMMessagePinItem *)item;

/**
 * 一条PIN被更新的在线通知
 * @param item 被更新的PIN记录
 */
- (void)onNotifyUpdateMessagePin:(NIMMessagePinItem *)item;

/**
 * 置顶会话同步完成的在线通知
 * @param response 置顶信息全量同步后的响应对象
 */
- (void)onNotifySyncStickTopSessions:(NIMSyncStickTopSessionResponse *)response;

/**
 * 一条置顶信息被增加的在线通知
 * @param newInfo 新增的置顶信息
 */
- (void)onNotifyAddStickTopSession:(NIMStickTopSessionInfo *)newInfo;

/**
 * 一条置顶信息被移除的在线通知
 * @param removedInfo 被移除的置顶信息
 */
- (void)onNotifyRemoveStickTopSession:(NIMStickTopSessionInfo *)removedInfo;

/**
 * 一条置顶会话被更新的在线通知
 * @param updatedInfo 被更新的置顶信息
 */
- (void)onNotifyUpdateStickTopSession:(NIMStickTopSessionInfo *)updatedInfo;

@end


/**
 *   聊天扩展
 */
@protocol NIMChatExtendManager <NSObject>

#pragma mark - Thread Talk

/**
 *  回复消息
 *
 *  @param message 新生成的消息
 *  @param target  被回复的消息
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)reply:(NIMMessage *)message
           to:(NIMMessage *)target
        error:(NSError * __nullable *)error;

/**
 *  异步回复消息
 *
 *  @param message  新生成的消息
 *  @param target   被回复的消息
 *  @param block    发送完成后的回调，这里的回调完成只表示当前这个函数调用完成，需要后续的回调才能判断消息是否已经发送至服务器
 */
- (void)reply:(NIMMessage *)message
           to:(NIMMessage *)target
   completion:(__nullable NIMChatManagerBlock)block;

/**
 *  本地获取Thread Talk的消息列表
 *
 *  @param  message 父消息
 *  @return 目标message的子消息列表
 */
- (NSArray<NIMMessage *> * _Nullable)subMessages:(NIMMessage *)message;

/**
 *  本地获取Thread Talk的消息列表
 *
 *  @param  message 父消息
 *  @return 目标message的子消息数目
 */
- (NSInteger)subMessagesCount:(NIMMessage *)message;

/**
 *  获取指定消息的Thread Talk子消息
 *
 *  @param info 目标消息
 *  @param option  查询分页选项
 *  @param block   完成回调
 */
- (void)fetchSubMessages:(NIMChatExtendBasicInfo *)info
                  option:(NIMThreadTalkFetchOption * _Nullable)option
              completion:(NIMThreadTalkFetchMessages)block;

/**
 *  获取指定消息的Thread Talk子消息
 *
 *  @param message 目标消息
 *  @param option  查询分页选项
 *  @param block   完成回调
 */
- (void)fetchSubMessagesFrom:(NIMMessage *)message
                      option:(NIMThreadTalkFetchOption * _Nullable)option
                  completion:(NIMThreadTalkFetchMessages)block;


/**
 *  根据MessageId等获取消息
 *
 *  @param infos    请求信息
 *  @param sync     是否同步到本地，注:DB标记状态删除的消息无法被同步覆盖
 *  @param block    完成回调
 */
- (void)fetchHistoryMessages:(NSArray<NIMChatExtendBasicInfo *> *)infos
                    syncToDB:(BOOL)sync
                  completion:(NIMFetchHistoryMessagesByIds)block;


#pragma mark - 快捷回复
/**
 *  发送快捷回复
 *
 *  @param comment      回复内容
 *  @param message      被回复消息
 *  @param completion   完成回调
 */
- (void)addQuickComment:(NIMQuickComment *)comment
              toMessage:(NIMMessage *)message
             completion:(NIMQuickCommentHandler _Nullable)completion;

/**
 *  从服务端删除一条评论
 *
 *  @param comment      目标评论
 *  @param completion   完成回调
 */
- (void)deleteQuickComment:(NIMQuickComment *)comment
                completion:(NIMQuickCommentHandler _Nullable)completion;

/**
 *  批量获取快捷评论
 *
 *  @param messages 目标消息, 最多批量20个
 *  @param completion 完成回调
 */
- (void)fetchQuickComments:(NSArray<NIMMessage *> *)messages
                completion:(NIMFetchCommentsByMsgsHandler)completion;

/**
 *  本地获取消息对应的快捷评论结果
 *
 *  @param message 目标消息
 *  @param completion 完成回调
 */
- (void)quickCommentsByMessage:(NIMMessage *)message
                    completion:(NIMGetQuickCommentsByMsgHandler)completion;


#pragma mark - 收藏
/**
 * 分页查询收藏列表
 * @param option 分页查询选项
 * @param completion 查询完成的回调
 */
- (void)queryCollect:(NIMCollectQueryOptions *)option completion:(nullable NIMCollectQueryBlock)completion;

/**
 * 添加一个收藏
 * @param info 添加收藏的参数，必须字段：type、data、ext
 * @param completion 添加完成的回调
 */
- (void)addCollect:(NIMAddCollectParams *)info completion:(nullable NIMAddCollectBlock)completion;

/**
 * 批量移除收藏
 * @param collectList 批量移除的收藏对象，必须字段：id、createTime
 * @param completion 移除完成的回调
 */
- (void)removeCollect:(NSArray<NIMCollectInfo *> *)collectList completion:(nullable NIMRemoveCollectBlock)completion;

/**
 * 更新收藏ext
 * @param collectInfo 需要更新的收藏对象，需要id、createTime、ext字段，如果ext不传，表示删除ext字段
 */
- (void)updateCollect:(NIMCollectInfo *)collectInfo completion:(nullable NIMUpdateCollectBlock)completion;

#pragma mark - 置顶

/**
 * 添加一条置顶记录
 * @param params 添加置顶的参数
 * @param completion 添加置顶记录完成的回调
 */
- (void)addStickTopSession:(NIMAddStickTopSessionParams *)params completion:(nullable NIMAddStickTopSessionCompletion)completion;

/**
 * 删除一条置顶记录
 * @param info 需要删除的置顶记录
 * @param completion 删除完成的回调
 */
- (void)removeStickTopSession:(NIMStickTopSessionInfo *)info completion:(nullable NIMRemoveStickTopSessionCompletion)completion;

/**
 * 更新一条置顶记录的扩展信息
 * @param info 需要更新的置顶记录
 * @param completion 删除完成的回调
 */
- (void)udpateStickTopSession:(NIMStickTopSessionInfo *)info completion:(nullable NIMUpdateStickTopSessionCompletion)completion;

/**
 * 查找所有的置顶记录
 * @param completion 查找完成的回调
 */
- (void)loadStickTopSessionInfos:(nullable NIMLoadStickTopSessionInfosCompletion)completion;

/**
 * 获取最近会话列表
 * @param options 查询选项（如按照置顶会话排序）
 */
- (void)loadRecentSessionsWithOptions:(NIMLoadRecentSessionsOptions *)options completion:(nullable NIMLoadRecentSessionsCompletion)completion;

/**
 * 根据置顶信息排序最近会话
 * @param recentSessions 需要排序的置顶会话，若传可变数组则进行in place排序
 * @param infos [会话：置顶信息] 映射
 * @return 排序后的最近会话列表，若传如可变数组，则返回其数组本身
 */
- (NSArray<NIMRecentSession *> *)sortRecentSessions:(NSArray<NIMRecentSession *> *)recentSessions withStickTopInfos:(NSDictionary<NIMSession *,NIMStickTopSessionInfo *> *)infos;

/**
 * 查询某个会话的置顶信息
 * @param session 需要查询的会话
 * @return 置顶信息
 */
- (NIMStickTopSessionInfo *)stickTopInfoForSession:(NIMSession *)session;

#pragma mark - Pin

/**
 * 添加一条PIN记录
 * @param item 需要添加的PIN记录
 * @param completion 添加完成的回调
 */
- (void)addMessagePin:(NIMMessagePinItem *)item completion:(nullable NIMAddMessagePinCompletion)completion;

/**
 * 删除一条PIN记录
 * @param item 需要删除的PIN记录
 * @param completion 删除完成的回调
 */
- (void)removeMessagePin:(NIMMessagePinItem *)item completion:(nullable NIMRemoveMessagePinCompletion)completion;

/**
 * 更新一条PIN记录的扩展字段(ext)
 * @param item 需要更新的PIN记录，ext不传为删除
 * @param completion 更新完成的回调
 */
- (void)updateMessagePin:(NIMMessagePinItem *)item completion:(nullable NIMUpdateMessagePinCompletion)completion;

/**
 * 查询全部PIN记录(登录后首次查询该会话会触发一次网络同步)
 * @param session 会话
 * @param completion 加载完成的回调
 */
- (void)loadMessagePinsForSession:(NIMSession *)session completion:(nullable NIMLoadMessagePinsCompletion)completion;

/**
 * 查询某条消息的PIN记录
 * @param message 消息
 * @return 记录
 */
- (NIMMessagePinItem *)pinItemForMessage:(NIMMessage *)message;

#pragma mark - 其他
/**

 *  添加Thread Talk委托
 *
 *  @param delegate 聊天委托
 */
- (void)addDelegate:(id<NIMChatExtendManagerDelegate>)delegate;

/**
 *  移除Thread Talk委托
 *
 *  @param delegate 聊天委托
 */
- (void)removeDelegate:(id<NIMChatExtendManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
