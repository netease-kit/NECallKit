//
//  V2NIMConversationServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMBaseConversation.h"
#import "V2NIMConversationEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMLastMessage;

@class V2NIMConversation;
@class V2NIMConversationGroup;

@class V2NIMConversationOption;
@class V2NIMConversationResult;
@class V2NIMConversationOperationResult;
@class V2NIMConversationUpdate;
@class V2NIMConversationFilter;
@class V2NIMConversationGroupResult;

@protocol V2NIMConversationListener;
@protocol V2NIMConversationGroupListener;

/// 成功接收会话结果回调
typedef void (^V2NIMConversationResultCallback)(V2NIMConversationResult *result);
/// 成功接收会话回调
typedef void (^V2NIMConversationCallback)(V2NIMConversation *conversation);
/// 成功接收会话列表回调
typedef void (^V2NIMConversationListCallback)(NSArray<V2NIMConversation *> *conversationList);
/// 接收会话操作结果列表回调
typedef void (^V2NIMConversationOperationResultListCallback)(NSArray<V2NIMConversationOperationResult *> *resultList);
/// 成功接收未读数回调
typedef void (^V2NIMConversationUnreadCountCallback)(NSInteger unreadCount);
/// 成功接收已读时间戳
typedef void (^V2NIMConversationReadTimeCallback)(NSTimeInterval timestamp);
/// 成功接收标记会话已读时间戳
typedef void (^V2NIMMarkConversationReadCallback)(NSTimeInterval timestamp);

/// 会话协议
@protocol V2NIMConversationService <NSObject>

/**
 *  获取会话列表
 *
 *  @param offset 获取会话偏移量
 *  @param limit 分页拉取数量
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationList:(long long)offset
                      limit:(NSInteger)limit
                    success:(nullable V2NIMConversationResultCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据查询参数获取会话列表
 *
 *  @param offset 获取会话偏移量
 *  @param count 分页拉取数量
 *  @param option 查询参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationListByOption:(long long)offset
                              limit:(NSInteger)limit
                             option:(V2NIMConversationOption *)option
                            success:(nullable V2NIMConversationResultCallback)success
                            failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取会话列表，通过会话id列表
 *
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationListByIds:(NSArray<NSString *> *)conversationIds
                         success:(nullable V2NIMConversationListCallback)success
                         failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取会话
 *
 *  @param conversationId 会话id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversation:(NSString *)conversationId
                success:(nullable V2NIMConversationCallback)success
                failure:(nullable V2NIMFailureCallback)failure;

/**
 *  创建会话
 *
 *  @param conversationId 会话id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)createConversation:(NSString *)conversationId
                   success:(nullable V2NIMConversationCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  删除会话
 *
 *  @param conversationId 会话id
 *  @param clearMessage 是否同步删除会话对应的历史消息
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)deleteConversation:(NSString *)conversationId
              clearMessage:(BOOL)clearMessage
                   success:(nullable V2NIMSuccessCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  批量删除会话
 *
 *  @param conversationIds 会话id列表
 *  @param clearMessage 是否同步删除会话对应的历史消息
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)deleteConversationListByIds:(NSArray<NSString *> *)conversationIds
                       clearMessage:(BOOL)clearMessage
                            success:(nullable V2NIMConversationOperationResultListCallback)success
                            failure:(nullable V2NIMFailureCallback)failure;

/**
 * 查询当前全量置顶的会话列表
 * 排序方式：倒序
 * @param success 查询置顶会话成功回调，结果为置顶的会话列表
 * @param failure 查询置顶会话失败回调
 */
- (void)getStickTopConversationList:(V2NIMConversationListCallback)success
                            failure:(V2NIMFailureCallback)failure;

/**
 *  置顶会话
 *
 *  @param conversationId 会话id
 *  @param stickTop 是否置顶会话
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)stickTopConversation:(NSString *)conversationId
                    stickTop:(BOOL)stickTop
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  静音会话
 *
 *  @param conversationId 会话id
 *  @param mute 是否静音会话
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)muteConversation:(NSString *)conversationId
                    mute:(BOOL)mute
                 success:(nullable V2NIMSuccessCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新会话
 *
 *  @param conversationId 会话id
 *  @param updateInfo 会话更新内容
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateConversation:(NSString *)conversationId
                updateInfo:(V2NIMConversationUpdate *)updateInfo
                   success:(nullable V2NIMSuccessCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新会话本地扩展字段
 *
 *  @param conversationId 会话id
 *  @param localExtension 会话本地扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateConversationLocalExtension:(NSString *)conversationId
                          localExtension:(nullable NSString *)localExtension
                                 success:(nullable V2NIMSuccessCallback)success
                                 failure:(nullable V2NIMFailureCallback)failure;


/**
 *  获取全部会话的总的未读数
 *
 *  @return 全部会话的的总未读数
 */
- (NSInteger)getTotalUnreadCount;

/**
 *  根据会话id列表获取相应的未读数
 *
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getUnreadCountByIds:(NSArray<NSString *> *)conversationIds
                    success:(nullable V2NIMConversationUnreadCountCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据过滤条件获取相应的未读数
 *
 *  @param filter 过滤条件
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getUnreadCountByFilter:(V2NIMConversationFilter *)filter
                       success:(nullable V2NIMConversationUnreadCountCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  清空所有会话的总未读数
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearTotalUnreadCount:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据会话id列表清空相应会话的未读数
 *
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearUnreadCountByIds:(NSArray<NSString *> *)conversationIds
                      success:(nullable V2NIMConversationOperationResultListCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据会话类型列表清空相应会话的未读数
 *
 *  @param conversationTypes 会话类型列表，输入为V2NIMConversationType
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearUnreadCountByTypes:(NSArray<NSNumber *> *)conversationTypes
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据会话分组清空相应会话的未读数
 *
 *  @param groupId 会话分组id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearUnreadCountByGroupId:(NSString *)groupId
                          success:(nullable V2NIMSuccessCallback)success
                          failure:(nullable V2NIMFailureCallback)failure;

/**
 *  订阅指定过滤条件的会话未读数
 *
 *  @param filter 过滤条件
 *  @return 返回nil表示成功，否则返回错误
 */
- (nullable V2NIMError *)subscribeUnreadCountByFilter:(V2NIMConversationFilter *)filter;

/**
 *  取消订阅指定过滤条件的会话未读数
 *
 *  @param filter 过滤条件
 *  @return 返回nil表示成功，否则返回错误
 */
- (nullable V2NIMError *)unsubscribeUnreadCountByFilter:(V2NIMConversationFilter *)filter;

/**
 *  获取会话已读时间戳
 *  @deprecated
 *
 *  @param conversationId 会话id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationReadTime:(NSString *)conversationId
                        success:(nullable V2NIMConversationReadTimeCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  标记会话已读时间戳
 *  @deprecated
 *
 *  @param conversationId 会话id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)markConversationRead:(NSString *)conversationId
                     success:(nullable V2NIMMarkConversationReadCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  添加会话监听
 *
 *  @param listener
 */
- (void)addConversationListener:(id<V2NIMConversationListener>)listener;

/**
 *  移除会话监听
 *
 *  @param listener
 */
- (void)removeConversationListener:(id<V2NIMConversationListener>)listener;

@end

/// 会话回调协议
@protocol V2NIMConversationListener <NSObject>

@optional

/**
 *  同步开始
 */
- (void)onSyncStarted;

/**
 *  同步完成
 */
- (void)onSyncFinished;

/**
 *  同步失败
 *
 *  @param error 错误
 */
- (void)onSyncFailed:(V2NIMError *)error;

/**
 *  会话创建回调
 *
 *  @param conversation 会话
 */
- (void)onConversationCreated:(V2NIMConversation *)conversation;

/**
 *  会话删除回调
 *
 *  @param conversationIds 会话id列表
 */
- (void)onConversationDeleted:(NSArray<NSString *> *)conversationIds;

/**
 *  会话变更回调
 *
 *  @param conversations 会话列表
 */
- (void)onConversationChanged:(NSArray<V2NIMConversation *> *)conversations;

/**
 *  总未读数变更回调
 *
 *  @param unreadCount 未读数
 */
- (void)onTotalUnreadCountChanged:(NSInteger)unreadCount;

/**
 *  过滤器对应的未读数变更回调
 *
 *  @param filter 过滤器
 *  @param unreadCount 未读数
 */
- (void)onUnreadCountChangedByFilter:(V2NIMConversationFilter *)filter
                         unreadCount:(NSInteger)unreadCount;

/**
 *  账号多端登录会话已读时间戳标记通知回调
 *
 *  @param conversationId 会话id
 *  @param readTime 标记的时间戳
 */
- (void)onConversationReadTimeUpdated:(NSString *)conversationId
                             readTime:(NSTimeInterval)readTime;

@end

/// 成功接收会话分组结果回调
typedef void (^V2NIMConversationGroupResultCallback)(V2NIMConversationGroupResult *result);
/// 成功接收会话分组回调
typedef void (^V2NIMConversationGroupCallback)(V2NIMConversationGroup *group);
/// 成功接收会话分组列表回调
typedef void (^V2NIMConversationGroupListCallback)(NSArray<V2NIMConversationGroup *> *groups);

/// 会话分组协议
@protocol V2NIMConversationGroupService <NSObject>

/**
 *  创建会话分组
 *
 *  @param name 分组名
 *  @param serverExtension 服务器扩展字段
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)createConversationGroup:(NSString *)name
                serverExtension:(nullable NSString *)serverExtension
                conversationIds:(nullable NSArray<NSString *> *)conversationIds
                        success:(nullable V2NIMConversationGroupResultCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  删除会话分组
 *
 *  @param groupId 分组id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)deleteConversationGroup:(NSString *)groupId
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新会话分组
 *
 *  @param groupId 分组id
 *  @param name 分组名
 *  @param serverExtension 服务器扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateConversationGroup:(NSString *)groupId
                           name:(nullable NSString *)name
                serverExtension:(nullable NSString *)serverExtension
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  添加会话到分组
 *
 *  @param groupId 分组id
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)addConversationsToGroup:(NSString *)groupId
                conversationIds:(NSArray<NSString *> *)conversationIds
                        success:(nullable V2NIMConversationOperationResultListCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  从会话分组移除会话
 *
 *  @param groupId 分组id
 *  @param conversationIds 会话id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)removeConversationsFromGroup:(NSString *)groupId
                     conversationIds:(NSArray<NSString *> *)conversationIds
                             success:(nullable V2NIMConversationOperationResultListCallback)success
                             failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取会话分组列表
 *
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationGroupList:(nullable V2NIMConversationGroupListCallback)success
                         failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取会话分组
 *
 *  @param groupId 分组Id
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationGroup:(NSString *)groupId
                     success:(nullable V2NIMConversationGroupCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取会话分组列表
 *
 *  @param groupIds 分组Id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getConversationGroupListByIds:(NSArray<NSString *> *)groupIds
                              success:(nullable V2NIMConversationGroupListCallback)success
                              failure:(nullable V2NIMFailureCallback)failure;

/**
 *  添加会话分组监听
 *
 *  @param listener
 */
- (void)addConversationGroupListener:(id<V2NIMConversationGroupListener>)listener;

/**
 *  移除会话分组监听
 *
 *  @param listener
 */
- (void)removeConversationGroupListener:(id<V2NIMConversationGroupListener>)listener;

@end

/// 会话分组回调协议
@protocol V2NIMConversationGroupListener <NSObject>

@optional

/**
 *  会话分组创建回调
 *
 *  @param conversationGroup 会话分组
 */
- (void)onConversationGroupCreated:(V2NIMConversationGroup *)conversationGroup;

/**
 *  会话分组删除回调
 *
 *  @param groupId 分组id
 */
- (void)onConversationGroupDeleted:(NSString *)groupId;

/**
 *  会话分组变更回调
 *
 *  @param conversationGroup 会话分组
 */
- (void)onConversationGroupChanged:(V2NIMConversationGroup *)conversationGroup;

/**
 *  会话分组删除回调
 *
 *  @param groupId 分组id
 *  @param conversations 会话列表
 */
- (void)onConversationsAddedToGroup:(NSString *)groupId
                      conversations:(NSArray<V2NIMConversation *> *)conversations;

/**
 *  会话分组删除回调
 *
 *  @param groupId 分组id
 *  @param conversationIds 会话id列表
 */
- (void)onConversationsRemovedFromGroup:(NSString *)groupId
                        conversationIds:(NSArray<NSString *> *)conversationIds;

@end

/// 会话
@interface V2NIMConversation : NSObject <V2NIMBaseConversation, NSCopying>

/// 会话分组id
@property(nullable,nonatomic,copy,readonly) NSArray<NSString *> *groupIds;

/// 服务端扩展字段1024字节
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

/// 会话上一已读时间点（暨上一次清理未读的时间点）
@property(nonatomic,assign,readonly) NSTimeInterval lastReadTime;

@end

/// 会话分组
@interface V2NIMConversationGroup : NSObject <NSCopying>

/// 会话分组id
@property(nullable,nonatomic,copy,readonly) NSString *groupId;

/// 会话分组名称
@property(nullable,nonatomic,copy,readonly) NSString *name;

/// 服务端扩展字段1024字节
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

/// 会话分组创建时间
@property(nonatomic,assign,readonly) NSTimeInterval createTime;

/// 会话分组更新时间
@property(nonatomic,assign,readonly) NSTimeInterval updateTime;

@end

/// 会话查询相关参数
@interface V2NIMConversationOption : NSObject

/// 指定查询的会话类型数组，空表示不指定，查询所有类型、注意输入为V2NIMConversationType
@property(nullable,nonatomic,copy,readwrite) NSArray<NSNumber *> *conversationTypes;

/// 是否仅查询包含未读的会话。YES：查询包含未读的会话，NO：查询所有会话，默认NO
@property(nonatomic,assign,readwrite) BOOL onlyUnread;

/// 指定查询的会话分组数组，空表示不指定，查询所有分组
@property(nullable,nonatomic,copy,readwrite) NSArray<NSString *> *conversationGroupIds;

@end

/// 获取会话结果
@interface V2NIMConversationResult : NSObject

/// 下次获取偏移量
@property(nonatomic,assign,readonly) long long offset;

/// 数据是否拉取完毕
@property(nonatomic,assign,readonly) BOOL finished;

/// 会话列表
@property(nullable,nonatomic,copy,readonly) NSArray<V2NIMConversation *> *conversationList;

@end

/// 会话操作结果
@interface V2NIMConversationOperationResult : NSObject

/// 会话id
@property(nonatomic,copy,readonly) NSString *conversationId;

/// 操作失败错误，nil表示成功
@property(nonatomic,copy,readonly) V2NIMError *error;

@end

/// 更新会话相关字段
@interface V2NIMConversationUpdate : NSObject

/// 服务端扩展字段1024字节
@property(nullable,nonatomic,copy,readwrite) NSString *serverExtension;

@end

/// 会话过滤器
@interface V2NIMConversationFilter : NSObject <NSCopying>

/// 输入为V2NIMConversationType
@property(nullable,nonatomic,copy,readwrite) NSArray<NSNumber *> *conversationTypes;

/// 
@property(nullable,nonatomic,copy,readwrite) NSString *conversationGroupId;

///
@property(nonatomic,assign,readwrite) BOOL ignoreMuted;

@end

/// 会话分组结果
@interface V2NIMConversationGroupResult : NSObject

/// 会话分组
@property(nullable,nonatomic,copy,readonly) V2NIMConversationGroup *group;

/// 失败的会话操作结果列表
@property(nullable,nonatomic,copy,readonly) NSArray<V2NIMConversationOperationResult *> *failedList;

@end

NS_ASSUME_NONNULL_END
