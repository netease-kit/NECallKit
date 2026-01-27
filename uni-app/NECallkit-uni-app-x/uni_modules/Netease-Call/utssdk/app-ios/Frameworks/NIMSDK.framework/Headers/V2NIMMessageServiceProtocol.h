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
@class V2NIMCloudMessageListOption;
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
@class V2NIMMessageSearchExParams;
@class V2NIMMessageSearchResult;
@class V2NIMMessageDeletedNotification;
@class V2NIMClearHistoryNotification;
@class V2NIMVoiceToTextParams;
@class V2NIMModifyMessageParams;
@class V2NIMModifyMessageResult;
@class V2NIMCollectionListResult;
@class V2NIMMessageListResult;
@class V2NIMMessageAIStreamStopParams;
@class V2NIMMessageAIRegenParams;
@class V2NIMUpdateLocalMessageParams;
@class V2NIMImportMessagesToLocalOption;

@protocol V2NIMMessageListener;
@class V2NIMThreadMessageListOption;
@class V2NIMThreadMessageListResult;
@protocol V2NIMMessageCustomAttachmentParser;
@protocol V2NIMMessageFilter;

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
/// 查询历史消息Ex成功回调
typedef void(^V2NIMGetMessageListExSuccess)(V2NIMMessageListResult *result);
/// 从云端查询消息成功回调
typedef void(^V2NIMGetCloudMessageListSuccess)(V2NIMMessageListResult *result);
/// 检索返回结果回调
typedef void(^V2NIMMessageSearchResultCallback)(V2NIMMessageSearchResult *result);
/// 修改消息成功回调
typedef void(^V2NIMModifyMessageSuccess)(V2NIMModifyMessageResult *result);
/// 获取快捷评论成功回调
typedef void(^V2NIMGetQuickCommentListSuccess)(NSDictionary<NSString *, NSArray<V2NIMMessageQuickComment *> * > *result);
/// 插入一条本地消息成功回调
typedef void(^V2NIMInertMessagSuccess)(V2NIMMessage *result);
/// 更新本地扩展
typedef void(^V2NIMUpdateLocalExtensionSuccess)(V2NIMMessage *result);
/// 更新本地消息
typedef void(^V2NIMUpdateLocalMessageSuccess)(V2NIMMessage *message);
/// 语音转文字成功回调
typedef void(^V2NIMTranslateSuccess)(NSString *result);
/// 添加一个收藏成功回调
typedef void(^V2NIMCollectionSuccess)(V2NIMCollection *result);
/// 移除相关收藏成功回调
typedef void(^V2NIMRemoveCollectionSuccess)(int count);
/// 获取收藏信息成功回调
typedef void(^V2NIMGetCollectionListSuccess)(NSArray <V2NIMCollection *> *result);
/// 获取收藏信息Ex成功回调
typedef void(^V2NIMGetCollectionListExSuccess)(V2NIMCollectionListResult *result);
/// 获取 pin 消息列表成功回调
typedef void(^V2NIMGetPinListSuccess)(NSArray <V2NIMMessagePin *> *result);
/// 查询thread聊天云端消息列表的回调
typedef void(^V2NIMGetThreadMessageListSuccess)(V2NIMThreadMessageListResult *result);
/// 本地查询thread聊天消息列表的回调
typedef void(^V2NIMGetLocalThreadMessageListSuccess)(V2NIMThreadMessageListResult *result);
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
              params:(nullable V2NIMSendMessageParams *)params
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
 *  查询历史消息
 *  分页接口，每次默认50条，可以根据参数组合查询各种类型
 *
 *  @discussion 同步接口只支持查询本地数据（忽略V2NIMMessageListOption中的onlyQueryLocal参数）

 *  @param option 查询消息配置选项
 *  @param error 接收错误对象
 *
 *  @return 返回历史消息
 */
- (nullable NSArray<V2NIMMessage *> *)getMessageList:(V2NIMMessageListOption *)option
                                      error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;
/**
 *  查询历史消息
 *  分页接口，每次默认50条，可以根据参数组合查询各种类型
 *
 *  @param option 查询消息配置选项
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getMessageListEx:(V2NIMMessageListOption *)option
               success:(nullable V2NIMGetMessageListExSuccess)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 * 从云端拉取消息接口
 * 分页接口，每次默认50条，可以根据参数组合查询各种类型
 *
 *  @param option 查询消息配置选项
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getCloudMessageList:(V2NIMCloudMessageListOption *)option
                    success:(nullable V2NIMGetCloudMessageListSuccess)success
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
 *  根据ID列表查询消息
 *  只查询本地数据库
 *
 *  @param messageClientIds 需要查询的消息客户端ID列表
 *  @param conversationId 会话ID，指定会话ID在兼容性条件下可加速查询，建议提供准确值 消息所在会话的ID。强烈建议填写。如果填写了，则只查询该会话的消息。
 *  @param success 查询成功回调
 *  @param failure 查询失败回调
 */
- (void)getMessageListByIds:(NSArray<NSString *> *)messageClientIds
             conversationId:(NSString *)conversationId
                    success:(nullable V2NIMGetMessageListSuccess)success
                    failure:(nullable V2NIMFailureCallback)failure;
/**
 *  根据ID列表查询消息
 *  只查询本地数据库
 *
 *  @param messageClientIds 需要查询的消息客户端ID列表
 *  @param conversationId 会话ID，指定会话ID在兼容性条件下可加速查询，建议提供准确值 消息所在会话的ID。强烈建议填写。如果填写了，则只查询该会话的消息。如果不填写，则查询所有会话的消息，有性能风险。
 *  @param error 接收错误对象
 *
 *  @return 返回历史消息
 */
- (nullable NSArray<V2NIMMessage *> *)getMessageListByIds:(NSArray<NSString *> *)messageClientIds
                                           conversationId:(nullable NSString *)conversationId
                                                    error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;
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
 * 查询thread聊天云端消息列表
 * 建议查询getLocalThreadMessageList， 本地消息已经完全同步，减少网络请求， 以及避免触发请求频控
 *
 * @param threadMessageListOption thread消息查询选项
 * @param success 搜索成功的回调
 * @param failure 搜索失败的回调
 */
- (void)getThreadMessageList:(V2NIMThreadMessageListOption *)threadMessageListOption
                     success:(nullable V2NIMGetThreadMessageListSuccess)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 * 本地查询thread聊天消息列表
 * 如果消息已经删除， 回复数， 回复列表不包括已删除消息
 *
 * @param messageRefer 需要查询的消息引用， 如果该消息为跟消息，则参数为当前消息；否则需要获取当前消息的跟消息作为输入参数查询；否则查询失败
 * @param success 搜索成功的回调
 * @param failure 搜索失败的回调
 */
- (void)getLocalThreadMessageList:(V2NIMMessageRefer *)messageRefer
                          success:(nullable V2NIMGetLocalThreadMessageListSuccess)success
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
 *  清空历史消息
 *  仅清空会话漫游消息， 单次传递最多50个会话ID
 *
 *  @param conversationIds 会话ID列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)clearRoamingMessage:(NSArray *)conversationIds
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
 * 更新消息
 * 可更新字段：subType， text， attachment，localExtension，更新规则如下：
 *
 *  @param params 相关参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateLocalMessage:(V2NIMMessage *)message
                    params:(V2NIMUpdateLocalMessageParams *)params
                   success:(nullable V2NIMUpdateLocalMessageSuccess)success
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
 * 批量导入本地消息， 该消息不会发送
 * 不做消息类型限制
 * 插入后表现
 *      如果本地没有会话， 则需要生成会话，消息删除后， 会话不联动删除
 *      如果本地已经有会话， 需要变更会话的最后一条消息
 *      是最后一条消息且删除， 需要变更会话的最后一条消息， 往前回溯上一条消息
 *      全部消息聚合到最后一次状态进行会话变更触发
 *      若消息客户端 ID 为空，则生成 UUID，默认支持用户构造消息时候传入msgClientID
 *      批量导入的消息不变更未读
 *      该消息不会多端同步，只是本端显示
 *      插入消息默认成功
 */
- (void)importMessagesToLocal:(NSArray<V2NIMMessage *> *)messages
                       option:(V2NIMImportMessagesToLocalOption *)option
                      success:(nullable V2NIMSuccessCallback)success
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
* 按条件分页获取收藏信息Ex
*
* @param option 查询参数
* @param success 成功回调
* @param failure 失败回调
*/

- (void)getCollectionListExByOption:(V2NIMCollectionOption *)option
                          success:(V2NIMGetCollectionListExSuccess)success
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
 * 搜索云端消息
 *
 * @param params  消息检索参数
 * @param success 消息检索成功回调
 * @param failure 消息检索失败回调
 */
- (void)searchCloudMessagesEx:(V2NIMMessageSearchExParams *)params
                      success:(nullable V2NIMMessageSearchResultCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
* 检索本地消息
*
* @param params 消息检索参数
* @param success 成功回调
* @param failure 失败回调
*/
- (void)searchLocalMessages:(V2NIMMessageSearchExParams *)params
                    success:(nullable V2NIMMessageSearchResultCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 * 更新消息接口
 * 可更新字段：subType， text， attachment， serverExtension， 消息类型不允许变更、文件类型不可更新attachment
 * 更新时可以配置反垃圾，反垃圾配置可以和原消息不一致
 */
-(void)modifyMessage:(V2NIMMessage *)message
              params:(V2NIMModifyMessageParams *)params
             success:(nullable V2NIMModifyMessageSuccess)success
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
 *  停止传输消息的进度 (发送/接受附件)
 */
- (void)stopAIStreamMessage:(V2NIMMessage *)message
                     params:(V2NIMMessageAIStreamStopParams *)params
                    success:(nullable V2NIMSuccessCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 * 重新输出数字人消息
 *
 * @param message 需要重新输出的数字人消息
 * @param params 确定重新输出的操作类型
 */
- (void)regenAIMessage:(V2NIMMessage *)message
                params:(V2NIMMessageAIRegenParams *)params
               success:(nullable V2NIMSuccessCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 * 消息过滤器，云端会话的最后一条消息不受该过滤器控制
 */
- (void)setMessageFilter:(nullable id<V2NIMMessageFilter>)filter;

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

@optional
/**
 * 本端发送消息状态回调
 *
 * 来源： 发送消息， 插入消息
 */
- (void)onSendMessage:(V2NIMMessage *)message;
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
 * 更新消息在线同步通知
 * 更新消息多端同步通知
 * 更新消息漫游通知
 * - Parameter messages: 被修改的消息列表
 */
- (void)onReceiveMessagesModified:(NSArray <V2NIMMessage *>*)messages;
/**
 * 消息撤回回调
 * - Parameter revokeNotifications: 消息撤回通知数据
 */
- (void)onMessageRevokeNotifications:(NSArray <V2NIMMessageRevokeNotification *> *)revokeNotifications;
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
