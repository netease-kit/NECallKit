//
//  V2NIMLocalConversationServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMBaseConversation.h"

NS_ASSUME_NONNULL_BEGIN
// @class
@class V2NIMLocalConversation;
@class V2NIMLocalConversationFilter;
@class V2NIMLocalConversationOption;
@class V2NIMLocalConversationOperationResult;
@class V2NIMLocalConversationResult;
// @protocol
@protocol V2NIMLocalConversationListener;

/// 获取到本地会话结果回调
typedef void (^V2NIMLocalConversationResultCallback)(V2NIMLocalConversationResult *result);
/// 单条本地会话的回调
typedef void (^V2NIMLocalConversationCallback)(V2NIMLocalConversation *result);
/// 多单条本地会话的回调
typedef void (^V2NIMLocalConversationListCallback)(NSArray<V2NIMLocalConversation *> *result);
/// 操作本地会话结果回调
typedef void (^V2NIMLocalConversationOperationResultListCallback)(NSArray<V2NIMLocalConversationOperationResult *> *result);
/// 成功接收未读数回调
typedef void (^V2NIMLocalConversationUnreadCountCallback)(NSInteger unreadCount);
/// 成功接收已读时间戳
typedef void (^V2NIMLocalConversationReadTimeCallback)(NSTimeInterval timestamp);

/// 本地会话协议
@protocol V2NIMLocalConversationService <NSObject>

/**
 * 获取本地会话列表
 * 本地历史会话数据没有上限，建议分页获取，每次建议最大100
 * 数据从客户端本地获取，会话有相关变更更新SDK内部会同步，抛出相应回调通知上面
 * 可以翻页多次拉取，直到数据拉取完毕， 客户端本地有相应标识标记数据是否拉取完成
 * 翻页：本地会话正好查完的情况下，当次就返回 finished = true；云端会话需要下次才能返回 finished = true
 * 置顶排序最前
 * note：内部实现，服务器排序字段可以预留最高位6位作为排序标志， 置顶使用第一位
 *
 * @param offset 分页偏移，首次传0，后续拉取采用上一次返回的offset
 * @param limit 分页拉取数量，不建议超过100， 内部不做校验，但是数据太大会影响查询时间 小于等于0，默认为100
 * @param success 获取会话列表成功回调
 * @param failure 获取会话失败回调
 */
- (void)getConversationList:(NSInteger)offset
                      limit:(NSInteger)limit
                    success:(V2NIMLocalConversationResultCallback)success
                    failure:(V2NIMFailureCallback)failure;

/**
 * 获取本地会话列表
 * 本地历史会话数据没有上限，建议分页获取，每次建议最大100
 * 数据从客户端本地获取，会话有相关变更更新SDK内部会同步，抛出相应回调通知上面
 * 可以翻页多次拉取，直到数据拉取完毕， 客户端本地有相应标识标记数据是否拉取完成
 * 翻页：本地会话正好查完的情况下，当次就返回 finished = true；云端会话需要下次才能返回 finished = true
 * 置顶排序最前
 * note：内部实现，服务器排序字段可以预留最高位6位作为排序标志， 置顶使用第一位
 *
 * @param offset 分页偏移，首次传0，后续拉取采用上一次返回的offset
 * @param limit 分页拉取数量，不建议超过100， 内部不做校验，但是数据太大会影响查询时间 小于等于0，默认为100
 * @param error 接收错误对象
 *
 *  @return 返回查询结果
 */
- (nullable V2NIMLocalConversationResult *)getConversationList:(NSInteger)offset
                                                limit:(NSInteger)limit
                                                error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 * 获取本地会话列表，可以指定筛选条件，按会话类型，未读等
 * 本地会话数据无上限，建议分页获取，每次建议最大100
 * 数据从客户端本地获取，会话有相关变更更新SDK内部会同步，回调通知上层界面
 * 可以翻页多次拉取，直到数据拉取完毕， 客户端本地有相应标识标记数据是否拉取完成
 *
 * @param offset 分页偏移，首次传0，后续拉取采用上一次返回的offset
 * @param limit 分页拉取数量，不建议超过100， 内部不做校验，但是数据太大会影响查询时间 小于等于0，默认为100
 * @param option 查询参数，具体参见Option定义 所有参数为空则退化为getConversationList
 * @param success 获取会话成功回调
 * @param failure 获取会话失败回调
 */
- (void)getConversationListByOption:(NSInteger)offset
                              limit:(NSInteger)limit
                             option:(nullable V2NIMLocalConversationOption *)option
                            success:(V2NIMLocalConversationResultCallback)success
                            failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话ID获取单条会话
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId
 * @param success 获取会话成功回调
 * @param failure 获取会话失败回调
 */
- (void)getConversation:(NSString *)conversationId
                success:(V2NIMLocalConversationCallback)success
                failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话ID获取单条会话
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId
 * @param error 接收错误对象
 *
 *  @return 返回会话
 */
- (nullable V2NIMLocalConversation *)getConversation:(NSString *)conversationId
                                      error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 * 根据会话ID获取本地会话列表
 * 只返回会话ID存在的会话
 *
 * @param conversationIds 需要查询会话IDS 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param success 获取会话列表成功回调
 * @param failure 获取会话列表失败回调
 */
- (void)getConversationListByIds:(NSArray<NSString *> *)conversationIds
                         success:(V2NIMLocalConversationListCallback)success
                         failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话ID获取本地会话列表
 * 只返回会话ID存在的会话
 *
 * @param conversationIds 需要查询会话IDS 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 *
 * @return 获取会话列表结果
 */
- (nullable NSArray<V2NIMLocalConversation *> *)getConversationListByIds:(NSArray<NSString *> *)conversationId
                                                          error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 * 创建一个空本地会话，默认不需要调用此方法，收发消息会主动触发会话创建
 * 使用场景为需要本地占位空会话的情况下可以调用该方法
 * 如果没有消息收发，该会话只本人可见，幂等接口
 * 需要保证type与targetId存在且合法
 * 当该方法调用后，SDK 会给您抛 onConversationCreated 回调。
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param success 创建会话成功回调
 * @param failure 创建会话失败回调
 */
- (void)createConversation:(NSString *)conversationId
                   success:(V2NIMLocalConversationCallback)success
                   failure:(V2NIMFailureCallback)failure;

/**
 * 创建一个空本地会话，默认不需要调用此方法，收发消息会主动触发会话创建
 * 使用场景为需要本地占位空会话的情况下可以调用该方法
 * 如果没有消息收发，该会话只本人可见，幂等接口
 * 需要保证type与targetId存在且合法
 * 当该方法调用后，SDK 会给您抛 onConversationCreated 回调。
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param success 创建会话成功回调
 * @param failure 创建会话失败回调
 */
- (nullable V2NIMLocalConversation *)createConversation:(NSString *)conversationId
                                                  error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 * 删除本地会话
 * 如果会话ID不存在返回参数错误
 * 包括接收方不存在
 * 发送方不存在
 * 会话类型不存在
 * 删除的会话不存在返回资源不存在错误码
 * 当该方法调用后，SDK 会给您抛 onConversationDeleted 回调
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param clearMessage 是否删除本地会话对应的本地历史消息 true：清空本地历史消息 非云端，仅本地，此处是与云端会话的 deleteConversation 的差异点 注意：如果需要删除远端消息， 请调用消息模块的 clearHistoryMessage false：只删除会话，历史消息保留
 * @param success 删除会话成功回调
 * @param failure 删除会话失败回调
 */
- (void)deleteConversation:(NSString *)conversationId
              clearMessage:(BOOL)clearMessage
                   success:(V2NIMSuccessCallback)success
                   failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话id列表批量删除会话
 * 每次最多删除100条
 * 可以选择是否同步清除历史消息
 * 当该方法调用后，成功删除的会话SDK 会给您抛 onConversationDeleted 回调
 * 返回数据包括每一条会话操作结果
 *
 * @param conversationIds 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param clearMessage 是否同步删除会话对应的历史消息 true：清空本地历史消息 注意：如果需要删除远端消息， 请调用消息模块的 clearHistoryMessage false：只删除会话，历史消息保留
 * @param success 删除会话成功回调，结果为失败的会话ID列表
 * @param failure 删除会话失败回调
 */
- (void)deleteConversationListByIds:(NSArray<NSString *> *)conversationIds
                       clearMessage:(BOOL)clearMessage
                            success:(V2NIMLocalConversationOperationResultListCallback)success
                            failure:(V2NIMFailureCallback)failure;

/**
 * 查询当前全量置顶的会话列表
 * 排序方式：倒序
 * @param success 查询置顶会话成功回调，结果为置顶的会话列表
 * @param failure 查询置顶会话失败回调
 */
- (void)getStickTopConversationList:(V2NIMLocalConversationListCallback)success
                            failure:(V2NIMFailureCallback)failure;

/**
 * 置顶会话
 * 如果会话id不存在返回参数错误
 * 置顶上限100
 * 当该方法调用后，SDK 会给您抛 onConversationChanged 回调。
 * 需要注意的是，stick top 仅更新 sortOrder，不更新 updateTime
 * Stick top 实现对其 V9 的多端置顶功能，单端置顶，多端同步
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param stickTop 是否置顶会话 true：置顶 false：取消置顶
 * @param success 置顶会话成功回调
 * @param failure 置顶会话失败回调
 */
- (void)stickTopConversation:(NSString *)conversationId
                    stickTop:(BOOL)stickTop
                     success:(V2NIMSuccessCallback)success
                     failure:(V2NIMFailureCallback)failure;

/**
 * 更新本地会话
 * 如果会话id不存在返回参数错误
 * 本地扩展字段不会多端同步，web端仅存内存
 * 当该方法调用后，SDK 会给您抛 onConversationChanged 回调。
 *
 * @param conversationId 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param localExtension 更新会话本地扩展字段 参数为null， 表示不更新， 返回参数错误
 * @param success 删除会话成功回调
 * @param failure 删除会话失败回调
 */
- (void)updateConversationLocalExtension:(NSString *)conversationId
                          localExtension:(NSString *)localExtension
                                 success:(V2NIMSuccessCallback)success
                                 failure:(V2NIMFailureCallback)failure;

/**
 * 获取全部本地会话的总的未读数
 * 未读有任何变更均会从回调抛出，SDK 会给您抛 onTotalUnreadCountChanged 回调。
 * @return 全部本地会话的总的未读数
 */
- (NSInteger)getTotalUnreadCount;

/**
 * 根据ID列表获取本地会话的总未读数
 * 回调总未读数为所有合法会话加和后的值
 *
 * @param conversationIds 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误
 * @param success 查询对应未读成功回调
 * @param failure 查询对应未读失败回调
 */
- (void)getUnreadCountByIds:(NSArray<NSString *> *)conversationIds
                    success:(V2NIMLocalConversationUnreadCountCallback)success
                    failure:(V2NIMFailureCallback)failure;

/**
 * 根据过滤参数获取相应的未读信息
 * 多个Fliter如果所有参数内容相同，会去重
 *
 * @param filter 查询参数，具体参见Filter定义 所有参数均不填， 则返回参数错误，请直接调用getTotalUnreadCount方法
 * @param success 查询对应未读成功回调
 * @param failure 查询对应未读失败回调
 */
- (void)getUnreadCountByFilter:(V2NIMLocalConversationFilter *)filter
                       success:(V2NIMLocalConversationUnreadCountCallback)success
                       failure:(V2NIMFailureCallback)failure;

/**
 * 清空所有会话总的未读数
 * 当该方法调用后，SDK 会给您抛 onTotalUnreadCountChanged 回调。
 *
 * @param success 清空所有会话未读成功回调
 * @param failure 清空所有会话未读失败回调
 */
- (void)clearTotalUnreadCount:(V2NIMSuccessCallback)success
                      failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话ID列表清空相应本地会话的未读数
 * 每次限制最多10条
 * 调用该方法后，SDK可能触发onTotalUnreadCountChanged、onUnreadCountChangedByFilter
 *
 * @param conversationIds 会话ID 拼接方式： myAccountID|conversationType|targetId；不能为空，为空直接返回参数错误；每次最多10条
 * @param success 清空对应未读成功回调
 * @param failure 清空对应未读失败回调
 */
- (void)clearUnreadCountByIds:(NSArray<NSString *> *)conversationIds
                      success:(V2NIMLocalConversationOperationResultListCallback)success
                      failure:(V2NIMFailureCallback)failure;

/**
 * 根据会话类型清空本地会话的未读数
 * 回调总未读数为所有合法会话加和后的值
 *
 * @param conversationTypes 需要清理未读的会话类型
 * @param success 清空对应未读成功回调
 * @param failure 清空对应未读失败回调
 */
- (void)clearUnreadCountByTypes:(NSArray<NSNumber *> *)conversationTypes
                        success:(V2NIMSuccessCallback)success
                        failure:(V2NIMFailureCallback)failure;

/**
 * 订阅指定过滤条件的会话未读数变化
 * 当订阅该条件后，该 filter 下的未读数发生变化时，SDK 会给您抛 onUnreadCountChangedByFilter 回调。
 * 可以根据需要注册多个过滤器
 *
 * @param filter 如果所有参数均为空，返回V2NIMError， code： 191004
 *                  如果只有单个参数，则单个参数生效
 *                  如果有多个参数，则多个参数均生效，才会产生相应回调
 *                  filter去重
 */
- (nullable V2NIMError *)subscribeUnreadCountByFilter:(V2NIMLocalConversationFilter *)filter;

/**
 * 取消订阅指定过滤条件的会话未读变化
 *
 * @param filter 对应注册的过滤filter
 */
- (void)unsubscribeUnreadCountByFilter:(V2NIMLocalConversationFilter *)filter;

/**
 * 获取会话已读时间戳
 * 当前只支持P2P, 高级群，超大群
 *
 * @param conversationId 会话ID
 * @param success 查询成功回调
 * @param failure 查询失败回调
 */
- (void)getConversationReadTime:(NSString *)conversationId
                        success:(V2NIMLocalConversationReadTimeCallback)success
                        failure:(V2NIMFailureCallback)failure;

/**
 * 标记会话已读时间戳
 * 当前只支持P2P，高级群， 超大群
 *
 * @param conversationId 会话ID
 * @param success 查询成功回调
 * @param failure 查询失败回调
 */
- (void)markConversationRead:(NSString *)conversationId
                     success:(V2NIMLocalConversationReadTimeCallback)success
                     failure:(V2NIMFailureCallback)failure;

/**
 * 设置当前正在聊天的会话。
 * 注：不传，或者传入为空字符串，代表取消设置。
 *
 * 注2：若设置了某个会话为当前正在聊天，则收到该会话消息所触发的会话变更的未读数不会累加，且此类情况的总未读数也不累加。
 *
 * @param conversationId 会话 id
 */
- (void)setCurrentConversation:(NSString *)conversationId
                         error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 * 添加本地会话监听器
 *
 * @param listener 会话监听回调
 */
- (void)addConversationListener:(id<V2NIMLocalConversationListener>)listener;

/**
 * 反注册会话状态监听器
 *
 * @param listener 移除对应的注册的回调
 */
- (void)removeConversationListener:(id<V2NIMLocalConversationListener>)listener;

@end

/// 本地会话监听回调
@protocol V2NIMLocalConversationListener <NSObject>
@optional

/**
 * 消息云端同步开始回调
 * 建议在回调完成之后操作数据， 如果在此期间操作数据，数据不全，只能操作部分数据
 */
- (void)onSyncStarted;

/**
 * 消息云端同步结束回调
 * 此回调之后可以随意操作相关会话数据
 * 此回调后需要用户重新获取会话列表
 */
- (void)onSyncFinished;

/**
 * 会话云端数据同步失败
 * 此回调之后可以操作会话数据，但是由于同步失败，本地只能操作已有数据，数据可能不全
 * 相关错误恢复后，会逐步按需重建数据
 *
 * @param error 会话数据云端同步失败，可能为如下原因：网络连接断开；服务异常。可以根据相应错误码确定相关错误原因
 */
- (void)onSyncFailed:(V2NIMError *)error;

/**
 * 会话创建回调
 * 主要为主动创建会话回调
 * 多端内容同步变更
 *
 * @param conversation 新创建的本地会话
 */
- (void)onConversationCreated:(V2NIMLocalConversation *)conversation;

/**
 * 会话删除回调
 * 主动删除会话回调
 * 多端内容同步变更
 *
 * @param conversationIds 被删除的会话ID列表，可以根据该ID列表移除界面上展示的会话数据
 */
- (void)onConversationDeleted:(NSArray<NSString *> *)conversationIds;

/**
 * 会话变更回调
 * 会话置顶
 * 会话静音
 * 新消息导致内容变更
 * 多端内容同步变更
 *
 * @param conversationList 相应变更的会话列表
 */
- (void)onConversationChanged:(NSArray<V2NIMLocalConversation *> *)conversationList;

/**
 * 会话总未读数变更
 * 所有导致总的未读数变更均会有此回调
 *
 * @param unreadCount 新的总未读数
 */
- (void)onTotalUnreadCountChanged:(NSInteger)unreadCount;

/**
 * 注册了subscribeUnreadCountByFilter 监听后，会抛出该回调
 * 根据不同Filter，回调对应的内容
 *
 * @param filter 订阅注册的相关Filter
 * @param unreadCount 对应Fliter过滤条件得出的未读数
 */
- (void)onUnreadCountChangedByFilter:(V2NIMLocalConversationFilter *)filter
                         unreadCount:(NSInteger)unreadCount;

/**
 * 账号多端登录会话已读时间戳标记通知
 * 账号A登录设备D1, D2,  D1会话已读时间戳标记，同步到D2成员
 *
 * @param conversationId 同步标记的会话ID
 * @param readTime 标记的时间戳
 */
- (void)onConversationReadTimeUpdated:(NSString *)conversationId
                             readTime:(NSTimeInterval)readTime;

@end

/// 会话
@interface V2NIMLocalConversation : NSObject <V2NIMBaseConversation>

@end

@interface V2NIMLocalConversationResult: NSObject
/**
 * 下一次拉取偏移量
 */
@property(nonatomic, assign, readonly) NSInteger offset;

/// 数据是否拉取完毕：
/// YES：拉取完毕
/// NO：未拉取完毕，可以继续拉取
@property(nonatomic, assign, readonly) BOOL finished;

/// 本地会话列表
@property(nonatomic, strong, readonly) NSArray<V2NIMLocalConversation *> *conversationList;

@end

@interface V2NIMLocalConversationOption : NSObject

/// 查询指定会话类型, empty: 不限制会话类型
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *conversationTypes;

/// NO：查询所有会话 YES：查询包含未读的会话
@property(nonatomic, assign) BOOL onlyUnread;

@end

@interface V2NIMLocalConversationFilter : NSObject

/// 过滤指定会话类型, empty: 不限制会话类型
@property(nonatomic, strong, nullable) NSArray<NSNumber *> *conversationTypes;

/// 过滤免打扰的会话类型
@property(nonatomic, assign) BOOL ignoreMuted;

@end

@interface V2NIMLocalConversationOperationResult : NSObject

/// 会话ID 拼接方式： myAccountID|conversationType|otherId
@property(nonatomic, copy, readonly) NSString *conversationId;

/// 成功error为空 失败根据code区分
@property(nonatomic, strong, readonly) V2NIMError *error;

@end

NS_ASSUME_NONNULL_END
