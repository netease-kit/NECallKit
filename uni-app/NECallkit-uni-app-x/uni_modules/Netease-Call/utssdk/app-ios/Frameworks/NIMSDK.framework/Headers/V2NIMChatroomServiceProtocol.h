//
//  V2NIMChatroomServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMLoginServiceProtocol.h"
#import "V2NIMMessageEnum.h"

@protocol V2NIMMessageCustomAttachmentParser;

NS_ASSUME_NONNULL_BEGIN

@class V2NIMChatroomInfo;
@class V2NIMChatroomMember;

@class V2NIMChatroomLoginOption;
@class V2NIMRouteConfig;
@class V2NIMChatroomKickedInfo;

@class V2NIMChatroomTagConfig;
@class V2NIMChatroomLocationConfig;
@class V2NIMChatroomEnterParams;
@class V2NIMChatroomEnterResult;

@protocol V2NIMChatroomClientListener;
@protocol V2NIMChatroomService;
@protocol V2NIMChatroomListener;
@protocol V2NIMChatroomQueueService;
@protocol V2NIMChatroomQueueListener;

@protocol V2NIMChatroomTokenProvider;
@protocol V2NIMChatroomLoginExtensionProvider;
@protocol V2NIMChatroomLinkProvider;
@protocol V2NIMStorageService;

@class V2NIMChatroomMemberQueryOption;
@class V2NIMChatroomMemberListResult;
@class V2NIMChatroomMemberRoleUpdateParams;
@class V2NIMChatroomUpdateParams;
@class V2NIMChatroomSelfMemberUpdateParams;
@class V2NIMChatroomTagsUpdateParams;
@class V2NIMChatroomTagMemberOption;
@class V2NIMChatroomTagTempChatBannedParams;

@class V2NIMAntispamConfig;
@class V2NIMLocationInfo;
@class V2NIMChatroomMessage;
@class V2NIMChatroomMessageConfig;
@class V2NIMSendChatroomMessageParams;
@class V2NIMMessageRouteConfig;
@class V2NIMMessageAntispamConfig;
@class V2NIMClientAntispamResult;
@class V2NIMSendChatroomMessageResult;
@class V2NIMChatroomMessageListOption;
@class V2NIMChatroomTagMessageOption;
@class V2NIMChatroomQueueOfferParams;
@class V2NIMChatroomQueueElement;

typedef NS_ENUM(NSInteger, V2NIMChatroomStatus) {
    V2NIM_CHATROOM_STATUS_DISCONNECTED                     = 0,  ///<聊天室断开连接
    V2NIM_CHATROOM_STATUS_WAITING                          = 1,  ///<聊天室等待重连
    V2NIM_CHATROOM_STATUS_CONNECTING                       = 2,  ///<聊天室连接过程中
    V2NIM_CHATROOM_STATUS_CONNECTED                        = 3,  ///<聊天室已连接
    V2NIM_CHATROOM_STATUS_ENTERING                         = 4,  ///<聊天室进入中
    V2NIM_CHATROOM_STATUS_ENTERED                          = 5,  ///<聊天室已进入
    V2NIM_CHATROOM_STATUS_EXITED                           = 6,  ///<聊天室已退出
};

typedef NS_ENUM(NSInteger, V2NIMChatroomQueueLevelMode) {
    V2NIM_CHATROOM_QUEUE_LEVEL_MODE_ANY = 0, ///< 所有人都有权限操作
    V2NIM_CHATROOM_QUEUE_LEVEL_MODE_MANAGER = 1, ///< 只有创建者/管理员才能操作
};

typedef NS_ENUM(NSInteger, V2NIMChatroomMemberRole) {
    V2NIM_CHATROOM_MEMBER_ROLE_NORMAL = 0, ///< 普通成员
    V2NIM_CHATROOM_MEMBER_ROLE_CREATOR = 1, ///< 创建者
    V2NIM_CHATROOM_MEMBER_ROLE_MANAGER = 2, ///< 管理员
    V2NIM_CHATROOM_MEMBER_ROLE_NORMAL_GUEST = 3, ///< 普通游客
    V2NIM_CHATROOM_MEMBER_ROLE_ANONYMOUS_GUEST = 4, ///< 匿名游客
    V2NIM_CHATROOM_MEMBER_ROLE_VIRTUAL = 5, ///< 虚构用户

};

/// 被踢出聊天室的原因
typedef NS_ENUM(NSInteger, V2NIMChatroomKickedReason) {
    V2NIM_CHATROOM_KICKED_REASON_UNKNOWN                       = -1,  ///< 未知
    V2NIM_CHATROOM_KICKED_REASON_CHATROOM_INVALID              = 1, ///< 聊天室解散
    V2NIM_CHATROOM_KICKED_REASON_BY_MANAGER                    = 2, ///< 被管理员踢出
    V2NIM_CHATROOM_KICKED_REASON_BY_CONFLICT_LOGIN             = 3, ///< 多端被踢
    V2NIM_CHATROOM_KICKED_REASON_SILENTLY                      = 4, ///< 静默被踢
    V2NIM_CHATROOM_KICKED_REASON_BE_BLOCKED                    = 5, ///< 加黑被踢
};

/// 成功接收进入聊天室结果回调
typedef void (^V2NIMChatroomEnterResultCallback)(V2NIMChatroomEnterResult *result);
/// 成功接收发送聊天室消息回调
typedef void (^V2NIMSendChatroomMessageSuccess)(V2NIMSendChatroomMessageResult *result);
/// 成功接收获取查询历史消息回调
typedef void (^V2NIMChatroomMessageListCallback)(NSArray<V2NIMChatroomMessage *> *messages);
/// 成功接收发送聊天室消息回调
typedef void (^V2NIMChatroomMemberListCallback)(NSArray<V2NIMChatroomMember *> *members);
/// 成功接收成员个数回调
typedef void (^V2NIMChatroomMemberCountCallback)(NSInteger memberCount);
/// 成功接收聊天室成员列表结果回调
typedef void (^V2NIMChatroomMemberListResultCallback)(V2NIMChatroomMemberListResult *result);
/// 成功接收取出头元素或者指定的元素结果回调
typedef void (^V2NIMChatroomQueuePollResultCallback)(V2NIMChatroomQueueElement *result);
/// 成功接收排序列出所有元素结果回调
typedef void (^V2NIMChatroomQueueListResultCallback)(NSArray<V2NIMChatroomQueueElement *> *result);
/// 成功接收查看队头元素结果回调
typedef void (^V2NIMChatroomQueuePeekResultCallback)(V2NIMChatroomQueueElement *result);
/// 成功接收批量更新队列元素结果回调
typedef void (^V2NIMChatroomQueueBatchUpdateResultCallback)(NSArray<NSString *> *result);

/// 聊天室实例
@interface V2NIMChatroomClient : NSObject

/**
 *  构造一个新的聊天室实例
 *
 *  @return 聊天室实例
 */
+ (instancetype)newInstance;

/**
 *  销毁指定聊天室实例
 *
 *  @param instanceId 聊天室实例ID
 */
+ (void)destroyInstance:(NSInteger)instanceId;

/**
 *  获取聊天室实例
 *
 *  @param instanceId 聊天室实例ID
 *
 *  @return 聊天室实例
 */
+ (instancetype)getInstance:(NSInteger)instanceId;

/**
 *  获取当前已经存在的聊天室实例列表
 *
 *  @return 聊天室实例列表
 */
+ (NSArray<V2NIMChatroomClient *> *)getInstanceList;

/**
 *  销毁当前的所有聊天室实例
 */
+ (void)destroyAll;

/**
 *  获取实例ID
 *
 *  @return 聊天室实例ID
 */
- (NSInteger)getInstanceId;

/**
 *  进入聊天室
 *
 *  @param roomId 聊天室ID
 *  @param enterParams 进入聊天室相关参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)enter:(NSString *)roomId
  enterParams:(V2NIMChatroomEnterParams *)enterParams
      success:(nullable V2NIMChatroomEnterResultCallback)success
      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  退出聊天室
 */
- (void)exit;

/**
 *  获取聊天室信息
 *
 *  @return 聊天室信息
 */
- (V2NIMChatroomInfo *)getChatroomInfo;

/**
 *  获取聊天室服务
 *
 *  @return 聊天室服务
 */
- (id<V2NIMChatroomService>)getChatroomService;

/**
 *  获取聊天室队列服务
 *
 *  @return 聊天室队列服务
 */
- (id<V2NIMChatroomQueueService>)getChatroomQueueService;

/**
 *  获取聊天室存储服务
 *
 *  @return 聊天室存储服务
 */
- (id<V2NIMStorageService>)getStorageService;

/**
 *  添加聊天室实例监听
 *
 *  @param listener 聊天室监听
 */
- (void)addChatroomClientListener:(id<V2NIMChatroomClientListener>)listener;

/**
 *  移除聊天室实例监听
 *
 *  @param listener 聊天室监听
 */
- (void)removeChatroomClientListener:(id<V2NIMChatroomClientListener>)listener;

@end

/// 聊天室实例监听回调协议
@protocol V2NIMChatroomClientListener <NSObject>

@optional

/**
 *  聊天室状态
 *
 *  @param status 状态
 *  @param error 错误信息
 */
- (void)onChatroomStatus:(V2NIMChatroomStatus)status
                   error:(nullable V2NIMError *)error;

/**
 *  进入聊天室
 */
- (void)onChatroomEntered;

/**
 *  退出聊天室
 *
 *  @param error 错误信息
 */
- (void)onChatroomExited:(nullable V2NIMError *)error;

/**
 *  自己被踢出聊天室
 *
 *  @param kickedInfo 被踢出的详细信息
 */
- (void)onChatroomKicked:(V2NIMChatroomKickedInfo *)kickedInfo;

@end

/// 聊天室协议
@protocol V2NIMChatroomService <NSObject>

/**
 * 发送消息接口
 * 消息对象可以调用V2NIMChatroomMessageCreator.createXXXMessage接口来创建
 * @param message 需要发送的消息体, 由聊天室消息创建工具类(V2NIMChatroomMessageCreator)创建
 * @param param 发送消息相关配置参数
 * @param success 发送消息成功回调
 * @param failure 发送消息失败回调
 * @param progress 发送消息进度回调
 *                  主要运用于文件类消息，回调文件发送进度
 */
- (void)sendMessage:(V2NIMChatroomMessage *)message
             params:(V2NIMSendChatroomMessageParams*)params
            success:(nullable V2NIMSendChatroomMessageSuccess)success
            failure:(nullable V2NIMFailureCallback)failure
           progress:(nullable V2NIMProgressCallback)progress;

/**
 * 取消文件类附件上传，只有文件类消息可以调用该接口
 * 如果文件已经上传成功，则取消失败
 * 如果取消成功， 则对应消息文件上传状态会变成V2NIMMessageAttachmentUploadState.V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_FAILED，同时消息会发送失败
 *
 * @param message 需要取消附件上传的消息体
 * @param success 取消成功回调
 * @param failure 取消失败回调
 */
- (void)cancelMessageAttachmentUpload:(V2NIMChatroomMessage *)message
                              success:(nullable V2NIMSuccessCallback)success
                              failure:(nullable V2NIMFailureCallback)failure;

/**
 * 查询历史消息
 *
 * @param option 获取聊天室消息列表查询参数
 * @param success 获取列表失败的回调
 * @param failure 获取列表失败的回调
 */
- (void)getMessageList:(V2NIMChatroomMessageListOption *)option
               success:(nullable V2NIMChatroomMessageListCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 * 根据标签查询消息列表
 *
 * @param option 查询参数
 * @param success 获取列表成功的回调
 * @param failure 获取列表失败的回调
 */
- (void)getMessageListByTag:(V2NIMChatroomTagMessageOption *)option
               success:(nullable V2NIMChatroomMessageListCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据账号列表查询成员信息
 *
 *  @param accountIds 账号id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMemberByIds:(NSArray<NSString *> *)accountIds
               success:(nullable V2NIMChatroomMemberListCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 *  分页获取聊天室成员列表
 *
 *  @param queryOption 查询参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMemberListByOption:(V2NIMChatroomMemberQueryOption *)queryOption
                      success:(nullable V2NIMChatroomMemberListResultCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新聊天室成员角色
 *
 *  @param accountId 账号id
 *  @param updateParams 更新参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateMemberRole:(NSString *)accountId
            updateParams:(V2NIMChatroomMemberRoleUpdateParams *)updateParams
                 success:(nullable V2NIMSuccessCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置聊天室成员黑名单状态
 *
 *  @param accountId 账号id
 *  @param blocked 黑名单状态
 *  @param notificationExtension 本次操作生成的通知中的扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setMemberBlockedStatus:(NSString *)accountId
                       blocked:(BOOL)blocked
         notificationExtension:(nullable NSString *)notificationExtension
                       success:(nullable V2NIMSuccessCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置成员禁言状态
 *
 *  @param accountId 账号id
 *  @param chatBanned 禁言状态
 *  @param notificationExtension 本次操作生成的通知中的扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setMemberChatBannedStatus:(NSString *)accountId
                       chatBanned:(BOOL)chatBanned
            notificationExtension:(nullable NSString *)notificationExtension
                          success:(nullable V2NIMSuccessCallback)success
                          failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置成员临时禁言状态
 *
 *  @param accountId 账号id
 *  @param tempChatBannedDuration 设置临时禁言时长（单位秒）
 *  @param notificationEnabled 是否需要通知
 *  @param notificationExtension 本次操作生成的通知中的扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 *
 *  @discussion tempChatBannedDuration 最大可设置为30天，如果取消临时禁言状态，设置为0
 */
- (void)setMemberTempChatBanned:(NSString *)accountId
         tempChatBannedDuration:(NSInteger)tempChatBannedDuration
            notificationEnabled:(BOOL)notificationEnabled
          notificationExtension:(nullable NSString *)notificationExtension
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新聊天室信息
 *
 *  @param updateParams 更新参数
 *  @param antispamConfig 更新参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateChatroomInfo:(V2NIMChatroomUpdateParams *)updateParams
            antispamConfig:(nullable V2NIMAntispamConfig *)antispamConfig
                   success:(nullable V2NIMSuccessCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新自己在聊天室的成员信息
 *
 *  @param updateParams 更新参数
 *  @param antispamConfig 更新参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateSelfMemberInfo:(V2NIMChatroomSelfMemberUpdateParams *)updateParams
              antispamConfig:(nullable V2NIMAntispamConfig *)antispamConfig
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  踢出聊天室成员
 *
 *  @param accountId 账号id
 *  @param notificationExtension 本次操作生成的通知中的扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)kickMember:(NSString *)accountId
notificationExtension:(nullable NSString *)notificationExtension
           success:(nullable V2NIMSuccessCallback)success
           failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新坐标信息
 *
 *  @param locationConfig 更新坐标信息参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateChatroomLocationInfo:(V2NIMChatroomLocationConfig *)locationConfig
                           success:(nullable V2NIMSuccessCallback)success
                           failure:(nullable V2NIMFailureCallback)failure;

/**
 *  更新聊天室tag信息
 *
 *  @param updateParams tags更新的参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateChatroomTags:(V2NIMChatroomTagsUpdateParams *)updateParams
                   success:(nullable V2NIMSuccessCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;

/**
 *  按聊天室标签临时禁言
 *
 *  @param params 设置标签禁言的参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setTempChatBannedByTag:(V2NIMChatroomTagTempChatBannedParams *)params
                       success:(nullable V2NIMSuccessCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  查询某个标签下的成员人数
 *
 *  @param tag 标签
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMemberCountByTag:(NSString *)tag
                    success:(nullable V2NIMChatroomMemberCountCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据tag查询聊天室成员列表
 *
 *  @param option 根据tag查询成员的参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMemberListByTag:(V2NIMChatroomTagMemberOption *)option
                   success:(nullable V2NIMChatroomMemberListResultCallback)success
                   failure:(nullable V2NIMFailureCallback)failure;


/**
 * 注册自定义消息附件解析器，解析自定义消息类型为100的附件
 * 可以注册多个， 后注册的优先级高，优先派发， 一旦被处理，则不继续派发
 * 如果同一个类型多个解析均可以解析，则优先级高的先解析， 解析后直接返回
 * 按需注册，不需要时及时反注册
 */
- (void)registerCustomAttachmentParser:(id<V2NIMMessageCustomAttachmentParser>)parser;


/**
 * 反注册自定义消息附件解析器，解析自定义消息类型为100的附件
 */
- (void)unregisterCustomAttachmentParser:(id<V2NIMMessageCustomAttachmentParser>)parser;

/**
 *  添加聊天室监听
 *
 *  @param listener 聊天室监听
 */
- (void)addChatroomListener:(id<V2NIMChatroomListener>)listener;

/**
 *  移除聊天室监听
 *
 *  @param listener 聊天室监听
 */
- (void)removeChatroomListener:(id<V2NIMChatroomListener>)listener;

@end

/// 聊天室回调协议
@protocol V2NIMChatroomListener <NSObject>

@optional

/**
 * 本端发送消息状态回调
 *
 * 来源： 发送消息， 插入消息
 */
- (void)onSendMessage:(V2NIMChatroomMessage *)message;

/**
 * 收到新消息
 *
 * @param messages 收到的消息内容
 * @see V2NIMChatroomMessage
 */
- (void)onReceiveMessages:(NSArray *)messages;

/**
 *  聊天室成员进入
 *
 *  @param member 聊天室成员
 */
- (void)onChatroomMemberEnter:(V2NIMChatroomMember *)member;

/**
 *  聊天室成员退出
 *
 *  @param accountId 聊天室成员账号id
 */
- (void)onChatroomMemberExit:(NSString *)accountId;

/**
 *  聊天室成员退出
 *
 *  @param previousRole 之前的角色类型
 *  @param member 当前的成员信息
 */
- (void)onChatroomMemberRoleUpdated:(V2NIMChatroomMemberRole)previousRole
                             member:(V2NIMChatroomMember *)member;

/**
 *  成员信息更新
 *
 *  @param member 聊天室成员
 */
- (void)onChatroomMemberInfoUpdated:(V2NIMChatroomMember *)member;

/**
 *  自己的禁言状态变更
 *
 *  @param chatBanned 禁言状态
 */
- (void)onSelfChatBannedUpdated:(BOOL)chatBanned;

/**
 *  自己的临时禁言状态变更
 *
 *  @param tempChatBanned 临时禁言状态
 *  @param tempChatBannedDuration 临时禁言时长
 */
- (void)onSelfTempChatBannedUpdated:(BOOL)tempChatBanned
             tempChatBannedDuration:(NSInteger)tempChatBannedDuration;

/**
 *  聊天室信息已更新
 *
 *  @param chatroomInfo 更新后的聊天室信息
 */
- (void)onChatroomInfoUpdated:(V2NIMChatroomInfo *)chatroomInfo;

/**
 *  聊天室整体禁言状态更新
 *
 *  @param chatBanned 禁言状态
 */
- (void)onChatroomChatBannedUpdated:(BOOL)chatBanned;

/**
 *  消息撤回
 *
 *  @param messageClientId 被撤回消息的客户端id
 *  @param messageTime 被撤回消息的时间
 */
- (void)onMessageRevokedNotification:(NSString *)messageClientId
                         messageTime:(NSTimeInterval)messageTime;

/**
 *  更新角色标签
 *
 *  @param tags 更新后的标签
 */
- (void)onChatroomTagsUpdated:(NSArray<NSString *> *)tags;

@end

@protocol V2NIMChatroomQueueService <NSObject>

/**
 * 聊天室队列新增或更新元素
 * @param offerParams 新增或更新元素参数
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queueOffer:(V2NIMChatroomQueueOfferParams *)offerParams
           success:(V2NIMSuccessCallback)success
           failure:(V2NIMFailureCallback)failure;

/**
 * 取出头元素或者指定的元素
 * 仅管理员和创建者可以操作
 * @param elementKey
 *           如果为空表示取出头元素
 *           如果不为空， 取出指定的元素
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queuePoll:(nullable NSString *)elementKey
          success:(V2NIMChatroomQueuePollResultCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 排序列出所有元素
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queueList:(V2NIMChatroomQueueListResultCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 查看队头元素， 不删除
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queuePeek:(V2NIMChatroomQueuePeekResultCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 清空队列
 * 仅管理员/创建者可以操作
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queueDrop:(V2NIMSuccessCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 初始化队列
 * @param size 初始化队列的长度
 *             长度限制： 0~1000， 超过返回参数错误
 *             可以对现有队列做此操作，修改现有队列的长度上限；
 *             当前队列如果已经超过了新的限制，元素不会减少，但是新元素无法增加
 * @param success 操作成功的回调
 * @param failure 操作失败的回调
 */
- (void)queueInit:(NSInteger)size
          success:(V2NIMSuccessCallback)success
          failure:(V2NIMFailureCallback)failure;

/**
 * 批量更新队列元素
 * @param keyValues 批量更新元素
 *                   size为空， size==0， size>100， 返回参数错误
 *                   key:长度限制：128字节
 *                   value：长度限制：4096字节
 * @param notificationEnabled 是否发送广播通知,317,默认为true
 * @param notificationExtension 本次操作生成的通知中的扩展字段，长度限制：2048字节
 * @param success 操作成功的回调，返回不存在的元素key列表
 * @param failure 操作失败的回调
 */
- (void)queueBatchUpdate:(NSArray<V2NIMChatroomQueueElement *> *)elements
     notificationEnabled:(BOOL)notificationEnabled
   notificationExtension:(nullable NSString *)notificationExtension
                 success:(V2NIMChatroomQueueBatchUpdateResultCallback)success
                 failure:(V2NIMFailureCallback)failure;

/**
 * 添加聊天室队列监听器
 * @param listener 聊天室队列监听器
 */
- (void)addQueueListener:(id<V2NIMChatroomQueueListener>)listener;

/**
 * 移除聊天室队列监听器
 * @param listener 聊天室队列监听器
 */
- (void)removeQueueListener:(id<V2NIMChatroomQueueListener>)listener;

@end

@protocol V2NIMChatroomQueueListener <NSObject>

@optional

/**
 * 聊天室新增队列元素
 * @param keyValues 新增的队列内容。
 */
- (void)onChatroomQueueOffered:(V2NIMChatroomQueueElement *)element;

/**
 * 聊天室移除队列元素
 * @param keyValues 移除的队列内容。
 */
- (void)onChatroomQueuePolled:(V2NIMChatroomQueueElement *)element;

/**
 * 聊天室清空队列元素
 */
- (void)onChatroomQueueDropped;

/**
 * 聊天室清理部分队列元素
 * @param keyValues 清理的队列内容
 */
- (void)onChatroomQueuePartCleared:(NSArray<V2NIMChatroomQueueElement *> *)elements;

/**
 * 聊天室批量更新队列元素
 * @param keyValues 更新的队列内容
 */
- (void)onChatroomQueueBatchUpdated:(NSArray<V2NIMChatroomQueueElement *> *)elements;

/**
 * 聊天室批量添加队列元素
 * @param keyValues 批量添加队列元素
 */
- (void)onChatroomQueueBatchOffered:(NSArray<V2NIMChatroomQueueElement *> *)elements;

@end


@protocol V2NIMChatroomLinkProvider <NSObject>

- (nullable NSArray<NSString *> *)getLinkAddress:(NSString *)roomId
                                       accountId:(NSString *)accountId;

@end

@protocol V2NIMChatroomTokenProvider <NSObject>

- (nullable NSString *)getToken:(NSString *)roomId
                      accountId:(NSString *)accountId;

@end

@protocol V2NIMChatroomLoginExtensionProvider <NSObject>

- (nullable NSString *)getLoginExtension:(NSString *)roomId
                               accountId:(NSString *)accountId;

@end

/// 聊天室信息
@interface V2NIMChatroomInfo : NSObject <NSCopying>
@property (nonatomic, strong, readonly) NSString *roomId; ///< 聊天室ID
@property (nonatomic, strong, readonly) NSString *roomName; ///< 聊天室名称
@property (nonatomic, strong, readonly) NSString *announcement; ///< 聊天室公告
@property (nonatomic, strong, readonly) NSString *liveUrl; ///< 视频直播拉流地址
@property (nonatomic, assign, readonly) BOOL isValidRoom; ///< 聊天室是否有效
@property (nonatomic, strong, readonly) NSString *serverExtension; ///< 聊天室扩展字段
@property (nonatomic, assign, readonly) V2NIMChatroomQueueLevelMode queueLevelMode; ///< 聊天室队列操作权限模式
@property (nonatomic, strong, readonly) NSString *creatorAccountId; ///< 聊天室创建者账号ID
@property (nonatomic, assign, readonly) NSInteger onlineUserCount; ///< 聊天室当前在线用户数量
@property (nonatomic, assign, readonly) BOOL chatBanned; ///< 聊天室禁言状态
@end

/// 聊天室成员信息
@interface V2NIMChatroomMember : NSObject <NSCopying>
@property (nullable,nonatomic,strong,readonly) NSString *roomId; ///< 聊天室ID。实际是一个long类型数据
@property (nullable,nonatomic,strong,readonly) NSString *accountId; ///< 成员账号ID。
@property (nonatomic,assign,readonly) V2NIMChatroomMemberRole memberRole; ///< 聊天室成员角色类型。普通成员--0; 创建者--1; 管理员--2; 普通游客--3; 匿名游客--4; 虚构用户---5
@property (nonatomic,assign,readonly) NSInteger memberLevel; ///< 成员等级， 大于等于0表示开发者可以自定义的级别。
@property (nullable,nonatomic,strong,readonly) NSString *roomNick; ///< 进入聊天室后显示的昵称。
@property (nullable,nonatomic,strong,readonly) NSString *roomAvatar; ///< 进入聊天室后显示的头像。
@property (nullable,nonatomic,strong,readonly) NSString *serverExtension; ///< 成员扩展字段。长度限制： 2048字节
@property (nonatomic,assign,readonly) BOOL isOnline; ///< 用户是否在线。普通成员， 创建者，管理员有在线离线状态; 其他的成员只有在线状态
@property (nonatomic,assign,readonly) BOOL blocked; ///< 是否在黑名单列表中。
@property (nonatomic,assign,readonly) BOOL chatBanned; ///< 是否禁言。
@property (nonatomic,assign,readonly) BOOL tempChatBanned; ///< 是否临时禁言。
@property (nonatomic,assign,readonly) NSInteger tempChatBannedDuration; ///< 临时禁言的时长。单位： 秒
@property (nullable,nonatomic,strong,readonly) NSArray<NSString *> *tags; ///< 登录标签
@property (nullable,nonatomic,strong,readonly) NSString *notifyTargetTags; ///< 登录登出通知标签， 标签表达式。https://doc.commsease.com/messaging/docs/TMxOTI0MDA?platform=android#%E6%A0%87%E7%AD%BE%E8%A1%A8%E8%BE%BE%E5%BC%8F
@property (nonatomic,assign,readonly) NSTimeInterval enterTime; ///< 用户进入聊天室的时间点。对应离线成员该字段为null， 前端界面显示为0
@property (nonatomic,assign,readonly) NSTimeInterval updateTime; ///< 普通成员， 创建者， 管理员的记录更新时间。
@property (nonatomic,assign,readonly) BOOL valid; ///< 记录是否有效
@property (nullable,nonatomic,strong,readonly) NSArray *multiEnterInfo; ///< 多端登录信息，同一个账号可以登录多个终端，多个终端同时在线。元素类型： V2NIMChatroomEnterInfo
@end

@interface V2NIMChatroomEnterInfo: NSObject <NSCopying>
@property (nullable,nonatomic,strong,readonly) NSString *roomNick; ///< 进入聊天室后显示的昵称。
@property (nullable,nonatomic,strong,readonly) NSString *roomAvatar; ///< 进入聊天室后显示的头像。
@property (nonatomic,assign,readonly) NSTimeInterval enterTime; ///< 用户进入聊天室的时间点。对应离线成员该字段为null， 前端界面显示为0
@property (nonatomic,assign,readonly) NSInteger clientType; ///< 进入的终端类型。
@end

/// 聊天室登录相关配置参数
@interface V2NIMChatroomLoginOption : NSObject

/// 认证类型
@property(nonatomic,assign,readwrite) V2NIMLoginAuthType authType;

/// 提供token
@property(nullable,nonatomic,strong,readwrite) id<V2NIMChatroomTokenProvider> tokenProvider;

/// 提供登录扩展信息
@property(nullable,nonatomic,strong,readwrite) id<V2NIMChatroomLoginExtensionProvider> loginExtensionProvider;

/// 抄送环境相关参数
@property(nullable,nonatomic,strong) V2NIMRouteConfig *routeConfig;

@end

/// 被踢出聊天室信息
@interface V2NIMChatroomKickedInfo : NSObject

/// 被踢原因
@property(nonatomic,assign,readonly) V2NIMChatroomKickedReason kickedReason;
/// 被踢原因扩展字段
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

@end

/// 聊天室标签配置
@interface V2NIMChatroomTagConfig : NSObject

/// 登录标签
@property(nullable,nonatomic,copy,readwrite) NSArray<NSString *> *tags;
/// 登录登出通知标签， 标签表达式
@property(nullable,nonatomic,copy,readwrite) NSString *notifyTargetTags;

@end

/// 进入聊天室空间坐标信息配置
@interface V2NIMChatroomLocationConfig : NSObject

/// 空间坐标信息
@property(nullable,nonatomic,copy,readwrite) V2NIMLocationInfo *locationInfo;
/// 订阅的消息的距离
@property(nonatomic,assign,readwrite) double distance;

@end

/// 加入聊天室相关参数
@interface V2NIMChatroomEnterParams : NSObject

/// 是否是匿名模式
@property(nonatomic,assign,readwrite) BOOL anonymousMode;
/// 账号id
@property(nullable,nonatomic,copy,readwrite) NSString *accountId;
/// 静态token
@property(nullable,nonatomic,copy,readwrite) NSString *token;
/// 进入聊天室后显示的昵称
@property(nullable,nonatomic,copy,readwrite) NSString *roomNick;
/// 进入聊天室后显示的头像
@property(nullable,nonatomic,copy,readwrite) NSString *roomAvatar;
/// 超时
@property(nonatomic,assign,readwrite) NSInteger timeout;
/// 聊天室登录相关信息
@property(nonatomic,copy,readwrite) V2NIMChatroomLoginOption *loginOption;
/// 提供聊天室link回调
@property(nonatomic,strong,readwrite) id<V2NIMChatroomLinkProvider> linkProvider;
/// 启用LBS，默认NO
@property (nonatomic,assign) BOOL enableLbs;
/// 用户扩展字段，建议使用json格式
@property(nullable,nonatomic,copy,readwrite) NSString *serverExtension;
/// 通知扩展字段，进入聊天室通知开发者扩展字段
@property(nullable,nonatomic,copy,readwrite) NSString *notificationExtension;
/// 进入聊天室标签信息配置
@property(nullable,nonatomic,strong,readwrite) V2NIMChatroomTagConfig *tagConfig;
/// 进入聊天室空间位置信息配置
@property(nullable,nonatomic,strong,readwrite) V2NIMChatroomLocationConfig *locationConfig;
/// 用户资料反垃圾检测
@property(nullable,nonatomic,strong,readwrite) V2NIMAntispamConfig *antispamConfig;

@end

/// 进入聊天室结果
@interface V2NIMChatroomEnterResult : NSObject

/// 聊天室信息
@property(nonatomic,copy,readonly) V2NIMChatroomInfo *chatroom;

/// 聊天室成员信息（自己）
@property(nonatomic,copy,readonly) V2NIMChatroomMember *selfMember;

@end

@interface V2NIMChatroomMemberQueryOption: NSObject <NSCopying>
/// 需要查询的成员类型，如果列表为空，表示查询所有类型的成员。
/// @see V2NIMChatroomMemberRole
@property (nullable, nonatomic, strong) NSArray *memberRoles;
/// 是否只返回黑名单成员
/// - true：只返回黑名单成员
/// - false：所有成员
@property (nonatomic, assign) BOOL onlyBlocked;
/// 是否只返回禁言用户
/// - true：只返回禁言用户
/// - false：返回所有用户
@property (nonatomic, assign) BOOL onlyChatBanned;
/// 是否只查询在线成员，只针对固定成员生效，其他类型成员只有在线状态
/// - true：只返回在线成员
/// - false：全部成员
@property (nonatomic, assign) BOOL onlyOnline;
/// 偏移量
/// - 首次传""，后续查询传前一次返回的pageToken
@property (nullable, nonatomic, copy) NSString *pageToken;
/// 一次查询的最大数量
@property (nonatomic, assign) NSInteger limit;
@end

@interface V2NIMChatroomMemberListResult: NSObject<NSCopying>
/// 下一次查询的偏移量
@property (nonnull, nonatomic, copy, readonly) NSString *pageToken;
/// 数据是否拉取完毕
/// - true：拉取完毕
/// - false：未拉取完毕，可以继续拉取
@property (nonatomic, assign, readonly) BOOL finished;
/// 拉取的成员列表
@property (nonnull, nonatomic, copy, readonly) NSArray *memberList;
@end

@interface V2NIMChatroomMessageListOption: NSObject
/// 消息查询方向，如果其它参数都不填
/// - DESC: 按时间从大到小查询
/// - ASC: 按时间从小到大查询
@property (nonatomic, assign) V2NIMQueryDirection direction;
/// 根据消息类型查询会话，为null或空列表，则表示查询所有消息类型
/// 仅支持 0:文本，1:图片，2:语音，3:视频，4:地理位置，5:通知，6:文件，10:提示，11:Robot，100:自定义，其它为非法参数
/// @see V2NIMMessageType
@property (nullable, nonatomic, strong) NSArray *messageTypes;
/// 消息查询开始时间，首次传0，单位秒
@property (nonatomic, assign) NSTimeInterval beginTime;
/// 最大值200，不做强制校验
@property (nonatomic, assign) NSInteger limit;
@end

@interface V2NIMChatroomMemberRoleUpdateParams: NSObject
/// 设置的成员角色
///     可以将普通游客、普通成员设置为管理员，只能创建者操作
///     可以将普通游客设置为普通成员，管理员和创建者均可操作
///     可以将普通成员设置为普通游客，管理员和创建者均可操作
///     可以将管理员设置为普通成员或普通游客，只能创建者操作
/// 不能操作虚构用户和匿名游客，设置直接报错
@property (nonatomic, assign) V2NIMChatroomMemberRole memberRole;
/// 设置用户等级
@property (nonatomic, assign) NSInteger memberLevel;
/// 本次操作生成的通知中的扩展字段
@property (nullable, nonatomic, copy) NSString *notificationExtension;
@end

@interface V2NIMChatroomUpdateParams: NSObject
/// 聊天室名称，为空表示不更新，不能为空串""，返回参数错误
@property (nullable, nonatomic, copy) NSString *roomName;
/// 聊天室公告，为空表示不更新
@property (nullable, nonatomic, copy) NSString *announcement;
/// 聊天室直播地址，为空表示不更新
@property (nullable, nonatomic, copy) NSString *liveUrl;
/// 聊天室扩展字段，为空表示不更新，长度限制：4096字节
@property (nullable, nonatomic, copy) NSString *serverExtension;
/// 是否需要通知
@property (nonatomic, assign) BOOL notificationEnabled;
/// 本次操作生成的通知中的扩展字段
@property (nullable, nonatomic, copy) NSString *notificationExtension;
@end

@interface V2NIMChatroomSelfMemberUpdateParams: NSObject
/// 聊天室显示的昵称
/// - 为空表示不更新
/// - 不能为空串"", 返回参数错误
@property (nullable, nonatomic, copy) NSString *roomNick;
/// 头像
/// - 为空表示不更新
@property (nullable, nonatomic, copy) NSString *roomAvatar;
/// 成员扩展字段
/// - 为空表示不更新
/// - 长度限制：2048字节
@property (nullable, nonatomic, copy) NSString *serverExtension;
/// 是否需要通知
@property (nonatomic, assign) BOOL notificationEnabled;
/// 本次操作生成的通知中的扩展字段
@property (nullable, nonatomic, copy) NSString *notificationExtension;
/// 更新信息持久化，只针对固定成员身份生效
@property (nonatomic, assign) BOOL persistence;
@end

@interface V2NIMChatroomQueuOfferParams: NSObject
/// 元素的唯一key
/// - 长度限制：128字节
/// - 如果队列key不存在，则追加到队尾，否则更新相应元素
@property (nonnull, nonatomic, copy) NSString *elementKey;
/// 元素的值
/// - 长度限制：4096字节
@property (nonnull, nonatomic, copy) NSString *elementValue;
/// 元素是否瞬态的
/// - true：当前元素所属的成员退出或者掉线时，同步删除元素
/// - false：元素保留
@property (nonatomic, assign) BOOL transient;
/// 元素属于的账号，默认为当前操作者
/// - 管理员操作，可以指定元素属于的合法账号
@property (nullable, nonatomic, copy) NSString *elemOwnerAccountId;
@end

@interface V2NIMChatroomTagTempChatBannedParams: NSObject
/// 禁言的tag
@property (nonnull, nonatomic, copy) NSString *targetTag;
/// 消息的目标标签表达式，标签表达式
/// - https://doc.commsease.com/messaging/docs/TMxOTI0MDA?platform=android#%E6%A0%87%E7%AD%BE%E8%A1%A8%E8%BE%BE%E5%BC%8F
@property (nonnull, nonatomic, copy) NSString *notifyTargetTags;
/// 禁言时长
/// - 单位：秒
/// - 设置为0，表示取消
@property (nonatomic, assign) NSUInteger duration;
/// 是否需要通知
@property (nonatomic, assign) BOOL notificationEnabled;
/// 本次操作生成的通知中的扩展字段
@property (nullable, nonatomic, copy) NSString *notificationExtension;
@end

@interface V2NIMChatroomTagsUpdateParams: NSObject
/// 标签
@property (nullable, nonatomic, copy) NSArray<NSString *> *tags;
/// 消息的目标标签表达式，标签表达式
/// - https://doc.commsease.com/messaging/docs/TMxOTI0MDA?platform=android#%E6%A0%87%E7%AD%BE%E8%A1%A8%E8%BE%BE%E5%BC%8F
/// 更新标签的通知的目标标签，是一个标签表达式，同时也会改变该连接掉线时的通知对象，见TagCalculator和TagPattern，如果不传，则会删除老的notifyTargetTags
@property (nullable, nonatomic, copy) NSString *notifyTargetTags;
/// 是否需要通知
@property (nonatomic, assign) BOOL notificationEnabled;
/// 本次操作生成的通知中的扩展字段
@property (nullable, nonatomic, copy) NSString *notificationExtension;
@end

@interface V2NIMChatroomTagMemberOption: NSObject
/// 查询的tag
@property (nonnull, nonatomic, copy) NSString *tag;
/// 偏移量
@property (nonatomic, copy) NSString *pageToken;
/// 每次查询条数，默认100
/// - 必须大于0，小于等于0报参数错误
@property (nonatomic, assign) NSInteger limit;
@end

@interface V2NIMChatroomTagMessageOption: NSObject
/// 查询的tags，为空或者size为0，返回参数错误
@property (nonnull, nonatomic, strong) NSArray *tags;
/// 根据消息类型查询会话，为null或空列表，则表示查询所有消息类型
@property (nullable, nonatomic, strong) NSArray *messageTypes;
/// 消息查询开始时间，小于等于endTime
/// 默认从0开始查询
@property (nonatomic, assign) NSTimeInterval beginTime;
/// 消息查询结束时间
/// 默认当前时间
@property (nonatomic, assign) NSTimeInterval endTime;
/// 每次查询条数，默认100
/// 必须大于0，小于等于0报参数错误
@property (nonatomic, assign) NSInteger limit;
/// 消息查询方向，如果其他参数都不填
/// - DESC: 按时间从大到小查询
/// - ASC: 按时间从小到大查询
@property (nonatomic, assign) V2NIMQueryDirection direction;
@end

/// 聊天室队列新增或者更新队列元素参数
@interface V2NIMChatroomQueueOfferParams: NSObject
/**
 * 元素的唯一key
 * 长度限制：128字节
 * 如果队列key不存在，则追加到队尾，否则更新相应元素
 */
@property (nonatomic, copy) NSString *elementKey;

/**
 * 元素的值
 * 长度限制：4096字节
 */
@property (nonatomic, copy) NSString *elementValue;

/**
 * 元素是否瞬态的
 * YES：当前元素所属的成员退出或者掉线时，同步删除元素
 * NO：元素保留
 * 默认值：NO
 */
@property (nonatomic, assign) BOOL transient;

/**
 * 元素属于的账号
 * 默认为当前操作者
 * 管理员操作时可以设置
 */
@property (nullable, nonatomic, copy) NSString *elementOwnerAccountId;
@end

@interface V2NIMChatroomQueueElement : NSObject
/**
 * 队列元素的Key
 */
@property (nonatomic, copy) NSString *key;
/**
 * 队列元素的Value
 */
@property (nonatomic, copy) NSString *value;
/**
 * 该元素所属于的账号
 */
@property (nonatomic, copy, nullable) NSString *accountId;
/**
 * 该元素所属于的账号的昵称
 */
@property (nonatomic, copy, nullable) NSString *nick;
/**
 * 其他的扩展字段
 */
@property (nonatomic, copy, nullable) NSString *extension;

@end
NS_ASSUME_NONNULL_END
