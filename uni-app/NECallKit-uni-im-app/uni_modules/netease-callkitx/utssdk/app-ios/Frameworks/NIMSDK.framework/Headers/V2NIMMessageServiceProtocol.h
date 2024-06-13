//
//  V2NIMMessageServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMMessageEnum.h"
#import "V2NIMConversationEnum.h"

@class V2NIMMessage;
@class V2NIMMessagePushConfig;
@class V2NIMMessageAntispamConfig;
@class V2NIMMessageConfig;
@class V2NIMMessageRouteConfig;
@class V2NIMSendMessageParams;
@class V2NIMSendMessageResult;
@class V2NIMMessageRobotConfig;
@class V2NIMMessageListOption;
@class V2NIMClearHistoryMessageOption;
@class V2NIMMessageRevokeParams;
@class V2NIMTeamMessageReadReceipt;
@class V2NIMMessageRevokeNotification;
@class V2NIMMessagePinNotification;
@class V2NIMStorageScene;
@class V2NIMMessageQuickCommentPushConfig;
@class V2NIMMessagePin;
@class V2NIMMessageQuickComment;
@class V2NIMP2PMessageReadReceipt;
@class V2NIMCollection;
@class V2NIMAddCollectionParams;
@class V2NIMCollectionOption;
@class V2NIMMessageQuickCommentNotification;
@class V2NIMTeamMessageReadReceiptDetail;
@class V2NIMMessageRefer;
@class V2NIMMessageSearchParams;
@class V2NIMMessageDeletedNotification;
@class V2NIMClearHistoryNotification;
@class V2NIMVoiceToTextParams;

@protocol V2NIMMessageListener;

NS_ASSUME_NONNULL_BEGIN

/// 发送消息成功回调
typedef void (^V2NIMSendMessageSuccess)(V2NIMSendMessageResult *result);
/// 获取群消息已读回执状态成功回调
typedef void(^V2NIMTeamReadReceiptSuccess)(NSArray <V2NIMTeamMessageReadReceipt *> *readReceipts);
/// 获取群消息已读回执状态详情成功回调
typedef void(^V2NIMTeamReadReceiptDetailSuccess)(V2NIMTeamMessageReadReceiptDetail *detail);
/// 查询点对点消息已读回执成功回调
typedef void(^V2NIMP2PReadReceiptSuccess)(V2NIMP2PMessageReadReceipt *receipt);
/// 查询历史消息成功回调
typedef void(^V2NIMGetMessageListSuccess)(NSArray <V2NIMMessage *> *result);
/// 获取快捷评论成功回调
typedef void(^V2NIMGetQuickCommentListSuccess)(NSDictionary<NSString *, NSArray<V2NIMMessageQuickComment *> * > *result);
/// 插入一条本地消息成功回调
typedef void(^V2NIMInertMessagSuccess)(V2NIMMessage *result);
/// 更新本地扩展
typedef void(^V2NIMUpdateLocalExtensionSuccess)(V2NIMMessage *result);
/// 语音转文字成功回调
typedef void(^V2NIMTranslateSuccess)(NSString *result);
/// 添加一个收藏成功回调
typedef void(^V2NIMCollectionSuccess)(V2NIMCollection *result);
/// 移除相关收藏成功回调
typedef void(^V2NIMRemoveCollectionSuccess)(int count);
/// 获取收藏信息成功回调
typedef void(^V2NIMGetCollectionListSuccess)(NSArray <V2NIMCollection *> *result);
/// 获取 pin 消息列表成功回调
typedef void(^V2NIMGetPinListSuccess)(NSArray <V2NIMMessagePin *> *result);

/// 消息服务协议
@protocol V2NIMMessageService <NSObject>

/**
 *  发送消息到会话
 *
 *  @param message 需要发送的消息体
 *  @param conversationId 会话Id
 *  @param params 发送消息相关配置参数
 *  @param success  成功回调
 *  @param failure  失败回调
 *  @param progress 进度回调
 */
- (void)sendMessage:(V2NIMMessage *)message
     conversationId:(NSString *)conversationId
             params:(nullable V2NIMSendMessageParams *)params
            success:(nullable V2NIMSendMessageSuccess)success
            failure:(nullable V2NIMFailureCallback)failure
           progress:(nullable V2NIMProgressCallback)progress;

/**
 *  发送消息到会话
 *
 *  @param message 需要发送的消息体
 *  @param replyMessage 被回复的消息
 *  @param params 发送消息相关配置参数
 *  @param success  成功回调
 *  @param failure  失败回调
 *  @param progress 进度回调
 */

- (void)replyMessage:(V2NIMMessage *)message
        replyMessage:(V2NIMMessage *)replyMessage
              params:(V2NIMSendMessageParams *)params
             success:(nullable V2NIMSendMessageSuccess)success
             failure:(nullable V2NIMFailureCallback)failure
            progress:(nullable V2NIMProgressCallback)progress;

/**
 *  撤回消息
 *  只能撤回已经发送成功的消息
 *
 *  @param message 要撤回的消息
 *  @param revokeParams 撤回消息相关参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)revokeMessage:(V2NIMMessage *)message
         revokeParams:(V2NIMMessageRevokeParams *)revokeParams
              success:(nullable V2NIMSuccessCallback)success
              failure:(nullable V2NIMFailureCallback)failure;
/**
 *  查询历史消息
 *  分页接口，每次默认50条，可以根据参数组合查询各种类型
 *
 *  @param option 查询消息配置选项
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMessageList:(V2NIMMessageListOption *)option
               success:(nullable V2NIMGetMessageListSuccess)success
               failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据ID列表查询消息
 *  只查询本地数据库
 *
 *  @param messageClientIds 需要查询的消息客户端ID列表
 *  @param success 查询成功回调
 *  @param failure 查询失败回调
 */
- (void)getMessageListByIds:(NSArray<NSString *> *)messageClientIds
                    success:(nullable V2NIMGetMessageListSuccess)success
                    failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据MessageRefer列表查询消息
 *
 *  @param messageRefers 需要查询的消息Refer列表
 *  @param success 查询成功回调
 *  @param failure 查询失败回调
 */
- (void)getMessageListByRefers:(NSArray<V2NIMMessageRefer *> *)messageRefers
                       success:(nullable V2NIMGetMessageListSuccess)success
                       failure:(nullable V2NIMFailureCallback)failure;
/**
 *  删除消息
 *  如果消息未发送成功,则只删除本地消息
 *
 *  @param message 需要删除的消息
 *  @param success 成功回调
 *  @param onlyDeleteLocal 是否只删除本地消息
 *      true：只删除本地，本地会将该消息标记为删除,getMessage会过滤该消息，界面不展示，卸载重装会再次显示
 *      fasle：同时删除云端
 *  @param failure 失败回调
 */
- (void)deleteMessage:(V2NIMMessage *)message
      serverExtension:(NSString *)serverExtension
      onlyDeleteLocal:(BOOL)onlyDeleteLocal
              success:(nullable V2NIMSuccessCallback)success
              failure:(nullable V2NIMFailureCallback)failure;
/**
 *  批量删除消息
 *  如果单条消息未发送成功， 则只删除本地消息
 *  每次50条, 不能跨会话删除,所有消息都属于同一个会话
 *  删除本地消息不会多端同步，删除云端会多端同步
 *
 *  @param messages 需要删除的消息列表
 *  @param onlyDeleteLocal 是否只删除本地消息
 *      true：只删除本地，本地会将该消息标记为删除， getHistoryMessage会过滤该消息，界面不展示，卸载重装会再次显示
 *      fasle：同时删除云端
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)deleteMessages:(NSArray<V2NIMMessage *> *)messages
       serverExtension:(NSString *)serverExtension
       onlyDeleteLocal:(BOOL)onlyDeleteLocal
               success:(nullable V2NIMSuccessCallback)success
               failure:(nullable V2NIMFailureCallback)failure;
/**
 *  清空历史消息
 *  同步删除本地消息，云端消息
 *  会话不会被删除
 *
 *  @param option 清空消息配置选项
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearHistoryMessage:(V2NIMClearHistoryMessageOption *)option
                    success:(nullable V2NIMSuccessCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;
/**
 *  更新消息本地扩展字段
 *
 *  @param message 需要被更新的消息体
 *  @param localExtension 扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateMessageLocalExtension:(V2NIMMessage *)message
                     localExtension:(NSString *)localExtension
                            success:(nullable V2NIMUpdateLocalExtensionSuccess)success
                            failure:(nullable V2NIMFailureCallback)failure;

/**
 * 插入一条本地消息， 该消息不会发送
 * 该消息不会多端同步，只是本端显示
 * 插入成功后， SDK会抛出回调
 *
 * @param message 需要插入的消息体
 * @param conversationId 会话 ID
 * @param senderId 消息发送者账号
 * @param createTime 指定插入消息时间
 * @param success 成功回调
 * @param failure 失败回调
 */

- (void)insertMessageToLocal:(V2NIMMessage *)message
              conversationId:(NSString *)conversationId
                    senderId:(NSString*)senderId
                  createTime:(NSTimeInterval)createTime
                     success:(nullable V2NIMInertMessagSuccess)success
                     failure:(nullable V2NIMFailureCallback)failure;
/**
 *  Pin一条消息
 *
 *  @param message 需要被pin的消息体
 *  @param serverExtension 扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)pinMessage:(V2NIMMessage *)message
   serverExtension:(NSString *)serverExtension
           success:(nullable V2NIMSuccessCallback)success
           failure:(nullable V2NIMFailureCallback)failure;
/**
 *  取消一条Pin消息
 *
 *  @param messageRefer 需要被unpin的消息体
 *  @param serverExtension 扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)unpinMessage:(V2NIMMessageRefer *)messageRefer
     serverExtension:(NSString *)serverExtension
             success:(nullable V2NIMSuccessCallback)success
             failure:(nullable V2NIMFailureCallback)failure;
/**
 *  更新一条Pin消息
 *
 *  @param message 需要被更新pin的消息体
 *  @param serverExtension 扩展字段
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updatePinMessage:(V2NIMMessage *)message
         serverExtension:(NSString *)serverExtension
                 success:(nullable V2NIMSuccessCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;
/**
* 获取 pin 消息列表
* @param conversationId 会话 ID
* @param success 发送消息成功回调
* @param failure 发送消息失败回调
*/
- (void)getPinnedMessageList:(NSString *)conversationId
                     success:(nullable V2NIMGetPinListSuccess)success
                     failure:(nullable V2NIMFailureCallback)failure;
/**
* 添加快捷评论
* @param message 被快捷评论的消息
* @param index 快捷评论映射标识符可以自定义映射关系，例如 表情回复： 可以本地构造映射关系， 1：笑脸  2：大笑， 当前读取到对应的index后，界面展示可以替换对应的表情 还可以应用于其他场景， 文本快捷回复等
* @param serverExtension 扩展字段， 最大8个字符
* @param pushConfig 快捷评论推送配置
* @param success 成功回调
* @param failure 失败回调
*/
- (void)addQuickComment:(V2NIMMessage *)message
                  index:(NSInteger)index
        serverExtension:(NSString *)serverExtension
             pushConfig:(V2NIMMessageQuickCommentPushConfig *)pushConfig
                success:(V2NIMSuccessCallback)success
                failure:(V2NIMFailureCallback)failure;
/**
* 移除快捷评论
* @param message 被快捷评论的消息
* @param index 快捷评论索引
* @param serverExtension 扩展字段， 最大8个字符
* @param success 成功回调
* @param failure 失败回调
*/
- (void)removeQuickComment:(V2NIMMessageRefer *)messageRefer
                     index:(NSInteger)index
           serverExtension:(NSString *)serverExtension
                   success:(V2NIMSuccessCallback)success
                   failure:(V2NIMFailureCallback)failure;
/**
* 获取快捷评论
* @param messages 被快捷评论的消息
* @param success 成功回调
* @param failure 失败回调
*/
- (void)getQuickCommentList:(NSArray <V2NIMMessage *> *)messages
                    success:(V2NIMGetQuickCommentListSuccess)success
                    failure:(V2NIMFailureCallback)failure;
/**
* 添加一个收藏
* 可以收藏消息， 也可以收藏其他自定义内容
* 后续可能会移动到另外单独服务中， 它与消息不绑定
* @param params 添加收藏相关参数
* @param success 成功回调
* @param failure 失败回调
*/

- (void)addCollection:(V2NIMAddCollectionParams *)params
              success:(V2NIMCollectionSuccess)success
              failure:(V2NIMFailureCallback)failure;
/**
* 移除相关收藏
* @param collections 需要移除的相关收藏
* @param success 成功回调
* @param failure 失败回调
*/
- (void)removeCollections:(NSArray <V2NIMCollection *> *)collections
                  success:(V2NIMRemoveCollectionSuccess)success
                  failure:(V2NIMFailureCallback)failure;
/**
* 更新收藏扩展字段
* @param collection 需要更新的收藏信息
* @param serverExtension 为空， 表示移除扩展字段, 否则更新为新扩展字段
* @param success 成功回调
* @param failure 失败回调
*/
- (void)updateCollectionExtension:(V2NIMCollection *)collection
                  serverExtension:(NSString *)serverExtension
                          success:(V2NIMCollectionSuccess)success
                         failure:(V2NIMFailureCallback)failure;
/**
* 按条件分页获取收藏信息
*
* @param option 查询参数
* @param success 成功回调
* @param failure 失败回调
*/

- (void)getCollectionListByOption:(V2NIMCollectionOption *)option
                          success:(V2NIMGetCollectionListSuccess)success
                          failure:(V2NIMFailureCallback)failure;


/**
* 发送消息已读回执
*
* @param messages 需要发送已读回执的消息
* @param success 成功回调
* @param failure 失败回调
*/
- (void)sendP2PMessageReceipt:(V2NIMMessage*)messages
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;
/**
* 查询点对点消息已读回执
*
* @param conversationId 需要发送已读回执的消息
* @param success 成功回调
* @param failure 失败回调
*/
- (void)getP2PMessageReceipt:(NSString*)conversationId
                     success:(nullable V2NIMP2PReadReceiptSuccess)success
                     failure:(nullable V2NIMFailureCallback)failure;
/**
* 查询点对点消息是否对方已读 内部判断逻辑为： 消息时间小于对方已读回执时间都为true
*
* @param message 需要发送已读回执的消息
*/
- (BOOL)isPeerRead:(V2NIMMessage *)message;
/**
 *  发送群消息已读回执
 *  所有消息必须属于同一个会话
 *
 *  @param messages 需要发送已读回执的消息列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)sendTeamMessageReceipts:(NSArray<V2NIMMessage *> *)messages
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;
/**
* 获取群消息已读回执状态
*
* @param messages 需要查询已读回执状态的消息
* @param success 获取群消息已读回执成功回调
* @param failure 获取群消息已读回执失败回调
*/
- (void)getTeamMessageReceipts:(NSArray<V2NIMMessage *> *)messages
                       success:(nullable V2NIMTeamReadReceiptSuccess)success
                       failure:(nullable V2NIMFailureCallback)failure;
/**
* 获取群消息已读回执状态详情
*
* @param message 需要查询已读回执状态的消息
* @param memberAccountIds 查找指定的账号列表已读未读
* @param success 获取群消息已读回执成功回调
* @param failure 获取群消息已读回执失败回调
*/
- (void)getTeamMessageReceiptDetail:(V2NIMMessage *)message
                    memberAccountIds:(NSSet*)memberAccountIds
                             success:(nullable V2NIMTeamReadReceiptDetailSuccess)success
                             failure:(nullable V2NIMFailureCallback)failure;
/**
* 语音转文字
*
* @param params 语音转文字参数
* @param success 转换成功回调
* @param failure 转换失败回调
*/
- (void)voiceToText:(V2NIMVoiceToTextParams *)params
            success:(nullable V2NIMTranslateSuccess)success
            failure:(nullable V2NIMFailureCallback)failure;
/**
* 取消文件类附件上传，只有文件类消息可以调用该接口
* 如果文件已经上传成功，则取消失败
* 如果取消成功， 则对应消息文件上传状态会变成
*
* @param message 需要取消附件上传的消息体
* @param success 发送消息成功回调
* @param failure 发送消息失败回调
*/
- (void)cancelMessageAttachmentUpload:(V2NIMMessage *)message
                              success:(nullable V2NIMSuccessCallback)success
                              failure:(nullable V2NIMFailureCallback)failure;
/**
* 搜索云端消息
*
* @param params 消息检索参数
* @param success 成功回调
* @param failure 失败回调
*/
- (void)searchCloudMessages:(V2NIMMessageSearchParams *)params
                    success:(nullable V2NIMGetMessageListSuccess)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
* 消息监听器
*
* @param listener 消息监听回调
*/
- (void)addMessageListener:(id<V2NIMMessageListener>)listener;

/**
* 反注册消息状态监听器
*
* @param listener 消息监听回调
*/
- (void)removeMessageListener:(id<V2NIMMessageListener>)listener;

@end

/**
* 消息监听回调
*
*/
@protocol V2NIMMessageListener <NSObject>
/**
 * 收到一条新消息
 *
 * - Parameter message: 收到的消息内容
 */
- (void)onReceiveMessages:(NSArray <V2NIMMessage *> *)messages;
/**
 * 点对点已读回执
 *
 * - Parameter readReceipts: 消息已读回执列表
 */
- (void)onReceiveP2PMessageReadReceipts:(NSArray <V2NIMP2PMessageReadReceipt *>*)readReceipts;
/**
 * 群已读回执
 * - Parameter readReceipts: 消息已读回执列表
 */
- (void)onReceiveTeamMessageReadReceipts:(NSArray <V2NIMTeamMessageReadReceipt *>*)readReceipts;
/**
 * 消息撤回回调
 * - Parameter revokeNotification: 描述消息撤回通知数据
 */
- (void)onMessageRevokeNotifications:(V2NIMMessageRevokeNotification *)revokeNotification;
/**
 * 消息pin状态回调通知
 * - Parameter pinNotification: 消息pin状态变化通知数据
 */
- (void)onMessagePinNotification:(V2NIMMessagePinNotification *)pinNotification;
/**
 * 消息评论状态回调
 * - Parameter notification: 快捷评论通知数据
 */
- (void)onMessageQuickCommentNotification:(V2NIMMessageQuickCommentNotification *)notification;
/**
 * 消息被删除通知
 * - Parameter notification: 被删除的消息列表
 */
- (void)onMessageDeletedNotifications:(NSArray<V2NIMMessageDeletedNotification *> *)messageDeletedNotification;
/**
 * 消息被删除通知
 * - Parameter notification: 被删除的消息列表
 */
- (void)onClearHistoryNotifications:(NSArray<V2NIMClearHistoryNotification *> *)clearHistoryNotification;

@end



NS_ASSUME_NONNULL_END
