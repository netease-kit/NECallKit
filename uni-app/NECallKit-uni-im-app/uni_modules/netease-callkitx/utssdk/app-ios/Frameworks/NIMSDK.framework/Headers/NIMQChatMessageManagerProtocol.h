//
//  NIMQChatMessageManagerProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatMessage;
@class NIMSession;

@class NIMQChatSendSystemNotificationParam;
@class NIMQChatSendSystemNotificationResult;
@class NIMQChatReceiveSystemNotificationResult;
@class NIMQChatUpdateSystemNotificationParam;
@class NIMQChatUpdateSystemNotificationResult;
@class NIMQChatSystemNotificationUpdateResult;
@class NIMQChatMarkSystemNotificationsReadParam;

@class NIMQChatGetMessageHistoryParam;
@class NIMQChatGetMessageHistoryByIdsParam;
@class NIMQChatMessageServerIdInfo;
@class NIMQChatGetMessageHistoryResult;
@class NIMQChatGetMessageCacheParam;
@class NIMQChatGetMessageCacheResult;
@class NIMQChatUpdateMessageParam;
@class NIMQChatRevokeMessageParam;
@class NIMQChatDeleteMessageParam;
@class NIMQChatUpdateMessageResult;
@class NIMQChatUpdateMessageEvent;

@class NIMQChatMarkMessageReadParam;
@class NIMQChatUnreadInfoChangedEvent;
@class NIMQChatResendSystemNotificationParam;
@class NIMQChatMessageTypingEvent;
@class NIMQChatGetLastMessageOfChannelsParam;
@class NIMQChatGetLastMessageOfChannelsResult;
@class NIMQChatServerUnreadInfo;
@class NIMQChatSearchMsgByPageParam;
@class NIMQChatSearchMsgByPageResult;
@class NIMQChatGetMentionedMeMessagesParam;
@class NIMQChatGetMentionedMeMessagesResult;
@class NIMQChatMarkServerReadResult;
@class NIMQChatAreMentionedMeMessagesParam;
@class NIMQChatAreMentionedMeMessagesResult;

/**
 * 发送自定义通知消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSendSystemNotificationHandler)(NSError *__nullable error, NIMQChatSendSystemNotificationResult *__nullable result);

/**
 * 拉取聊天消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetMessageHistoryHandler)(NSError *__nullable error, NIMQChatGetMessageHistoryResult *__nullable result);

/**
 * 更新圈组消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateMessageHandler)(NSError *__nullable error, NIMQChatUpdateMessageResult *__nullable result);

/**
 * 更新系统通知的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatUpdateSystemNotificationHandler)(NSError *__nullable error, NIMQChatUpdateSystemNotificationResult *__nullable result);

/**
 * 拉取缓存消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetMessageCacheHandler)(NSError *__nullable error, NIMQChatGetMessageCacheResult *__nullable result);

/**
 * 发送消息正在输入事件的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSendMessageTypingEventHandler)(NSError *__nullable error, NIMQChatMessageTypingEvent *__nullable result);

/**
 * 批量查询频道最后一条消息的回调
 *
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetLastMessageOfChannelsHandler)(NSError *__nullable error, NIMQChatGetLastMessageOfChannelsResult *__nullable result);

/**
 * 分页搜索圈组消息的回调
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatSearchMsgByPageHandler)(NSError *__nullable error, NIMQChatSearchMsgByPageResult *__nullable result);

/**
 * 分页搜索圈组 @ 我的消息的回调
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatGetMentionedMeMessagesHandler)(NSError *__nullable error, NIMQChatGetMentionedMeMessagesResult *__nullable result);

/**
 * 批量查询消息是否 @ 当前用户的回调
 * @param error 错误信息
 * @param result 回调结果
 */
typedef void(^NIMQChatAreMentionedMeMessagesHandler)(NSError *__nullable error, NIMQChatAreMentionedMeMessagesResult *__nullable result);



/**
 *   圈组消息管理器回调
 */
@protocol NIMQChatMessageManagerDelegate <NSObject>

@optional

/**
 *  即将发送消息回调
 *  @discussion 因为发消息之前可能会有个准备过程,所以需要在收到这个回调时才将消息加入到 Datasource 中
 *  @param message 当前发送的消息
 */
- (void)willSendMessage:(NIMQChatMessage *)message;


/**
 *  上传资源文件成功的回调
 *  @discussion 对于需要上传资源的消息(图片，视频，音频等)，SDK 将在上传资源成功后通过这个接口进行回调，上层可以在收到该回调后进行推送信息的重新配置 (APNS payload)
 *  @param urlString 当前消息资源获得的 url 地址
 *  @param message 当前发送的消息
 */
- (void)uploadAttachmentSuccess:(NSString *)urlString
                     forMessage:(NIMQChatMessage *)message;

/**
 *  发送消息进度回调
 *
 *  @param message  当前发送的消息
 *  @param progress 进度
 */
- (void)sendMessage:(NIMQChatMessage *)message
           progress:(float)progress;


/**
 *  发送消息完成回调
 *
 *  @param message 当前发送的消息
 *  @param error   失败原因,如果发送成功则error为nil
 */
- (void)sendMessage:(NIMQChatMessage *)message
    didCompleteWithError:(nullable NSError *)error;

/**
 *  收取消息附件回调
 *  @param message  当前收取的消息
 *  @param progress 进度
 *  @discussion 附件包括:图片,视频的缩略图,语音文件
 */
- (void)fetchMessageAttachment:(NIMQChatMessage *)message
                      progress:(float)progress;


/**
 *  收取消息附件完成回调
 *
 *  @param message 当前收取的消息
 *  @param error   错误返回,如果收取成功,error为nil
 */
- (void)fetchMessageAttachment:(NIMQChatMessage *)message
          didCompleteWithError:(nullable NSError *)error;

/**
 *  收到消息回调
 *
 *  @param messages 消息列表,内部为NIMQChatMessage
 */
- (void)onRecvMessages:(NSArray<NIMQChatMessage *> *)messages;

/**
 * 圈组消息更新事件回调
 *
 * @param event 事件详情
 */
- (void)onMessageUpdate:(NIMQChatUpdateMessageEvent *)event;

/**
 * 圈组未读信息变更事件回调(频道)
 *
 * @param event 事件详情
 */
- (void)unreadInfoChanged:(NIMQChatUnreadInfoChangedEvent *)event;

/**
 * 圈组服务器未读信息变更事件回调
 *
 * @param serverUnreadInfoDic 事件详情, key为@(serverId)（服务器ID的NSNumber），value 为NIMQChatServerUnreadInfo
 */
- (void)serverUnreadInfoChanged:(NSDictionary <NSNumber *, NIMQChatServerUnreadInfo *> *)serverUnreadInfoDic;

/**
 * 圈组系统通知接收事件回调
 *
 * @param result 结果详情
 */
- (void)onRecvSystemNotification:(NIMQChatReceiveSystemNotificationResult *)result;

/**
 * 圈组类消息typing事件回调
 *
 * @param result 结果详情
 */
- (void)onRecvTypingEvent:(NIMQChatMessageTypingEvent *)event;

/**
 * 圈组系统通知更新事件回调
 *
 * @param result 结果详情
 */
- (void)onSystemNotificationUpdate:(NIMQChatSystemNotificationUpdateResult *)result;



@end

/**
 *  圈组消息管理器
 */
@protocol NIMQChatMessageManager <NSObject>

/**
 *  发送消息
 *
 *  @param message 消息
 *  @param session 接受方
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)sendMessage:(NIMQChatMessage *)message
          toSession:(NIMSession *)session
              error:(NSError * __nullable *)error;

/**
 *  异步发送消息
 *
 *  @param message 消息
 *  @param session 接收方
 *  @param completion 发送完成后的回调，这里的回调完成只表示当前这个函数调用完成，需要后续的回调才能判断消息是否已经发送至服务器
 */
- (void)sendMessage:(NIMQChatMessage *)message
          toSession:(NIMSession *)session
         completion:(nullable NIMQChatHandler)completion;

/**
 *  取消正在发送的消息
 *
 *  @param message 目标消息
 *  @return 是否调用成功
 */
- (BOOL)cancelSendingMessage:(NIMQChatMessage *)message;

/**
 *  重发消息
 *
 *  @param message 重发消息
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)resendMessage:(NIMQChatMessage *)message
                error:(NSError * __nullable *)error;

/**
 *  生成转发消息
 *  得到转发消息后，开发者需自己再调用sendForwardMessage:toSession:error: 进行发送， 和 直接调用forwardMessage:toSession:error:效果一样，但是这样可以得到转发消息的进度方法回调和是否转发成功方法回调
 *
 *  @param message 要转发的消息
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 生成的需要转发的消息
 */
- (nullable NIMQChatMessage *)makeForwardMessage:(NIMQChatMessage *)message
                                           error:(NSError * __nullable *)error;

/**
 *  发送生成的转发消息
 *
 *  @param message 转发的消息
 *  @param session 接受方
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)sendForwardMessage:(NIMQChatMessage *)message
                 toSession:(NIMSession *)session
                     error:(NSError * __nullable *)error;

/**
 *  转发消息
 *
 *  @param message 消息
 *  @param session 接收方
 *  @param error   错误 如果在准备发送消息阶段发生错误,这个error会被填充相应的信息
 *
 *  @return 是否调用成功,这里返回的 result 只是表示当前这个函数调用是否成功,需要后续的回调才能够判断消息是否已经发送至服务器
 */
- (BOOL)forwardMessage:(NIMQChatMessage *)message
             toSession:(NIMSession *)session
                 error:(NSError * __nullable *)error;

/**
 *  消息是否正在传输 (发送/接受附件)
 *
 *  @param message 消息
 *
 *  @return 是否正在传输
 */
- (BOOL)messageInTransport:(NIMQChatMessage *)message;

/**
 *  传输消息的进度 (发送/接受附件)
 *
 *  @param message 消息
 *
 *  @return 正在传输的消息进度,如果消息不在传输,则返回0
 */
- (float)messageTransportProgress:(NIMQChatMessage *)message;

/**
 *  收取消息附件
 *
 *  @param message 需要收取附件的消息
 *  @param error   错误
 *
 *  @return 是否调用成功
 *  @discussion 附件包括：图片消息的图片缩略图，视频消息的视频缩略图，音频消息的音频文件，文件消息的文件以及自定义消息中的自定义文件
 */
- (BOOL)fetchMessageAttachment:(NIMQChatMessage *)message
                         error:(NSError * __nullable *)error;

/**
 *  取消收取消息附件
 *
 *  @param message 需要取消收取附件的消息
 *
 *  @discussion 附件包括：图片消息的图片缩略图，视频消息的视频缩略图，音频消息的音频文件，文件消息的文件以及自定义消息中的自定义文件
 */
- (void)cancelFetchingMessageAttachment:(NIMQChatMessage *)message;

/**
 * 更新圈组消息
 * @discussion 支持文本，服务器扩展，自定义消息状态
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)updateMessage:(NIMQChatUpdateMessageParam *)param
           completion:(nullable NIMQChatUpdateMessageHandler)completion;

/**
 * 撤回圈组消息
 * @discussion
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)revokeMessage:(NIMQChatRevokeMessageParam *)param
           completion:(nullable NIMQChatUpdateMessageHandler)completion;

/**
 * 删除圈组消息
 * @discussion
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)deleteMessage:(NIMQChatDeleteMessageParam *)param
           completion:(nullable NIMQChatUpdateMessageHandler)completion;

/**
 * 标记消息已读
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)markMessageRead:(NIMQChatMarkMessageReadParam *)param
             completion:(nullable NIMQChatHandler)completion;

/**
 * 从服务端查询历史消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getMessageHistory:(NIMQChatGetMessageHistoryParam *)param
               completion:(nullable NIMQChatGetMessageHistoryHandler)completion;

/**
 * 从服务端按ID查询历史消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getMessageHistoryByIds:(NIMQChatGetMessageHistoryByIdsParam *)param
                    completion:(nullable NIMQChatGetMessageHistoryHandler)completion;

/**
 * 发送自定义系统通知
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)sendSystemNotification:(NIMQChatSendSystemNotificationParam *)param
                    completion:(nullable NIMQChatSendSystemNotificationHandler)completion;

/**
 * 重发自定义系统通知
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)resendSystemNotification:(NIMQChatResendSystemNotificationParam *)param
                    completion:(nullable NIMQChatSendSystemNotificationHandler)completion;

/**
 * 更新系统通知（可以更新状态、也可以更新内容）
 */
- (void)updateSystemNotification:(NIMQChatUpdateSystemNotificationParam *)param
             completion:(nullable NIMQChatUpdateSystemNotificationHandler)completion;

/**
 * 标记系统通知已读
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)markSystemNotificationsRead:(NIMQChatMarkSystemNotificationsReadParam *)param
                         completion:(nullable NIMQChatHandler)completion;

/**
 * 发送正在输入等自定义事件
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)sendMessageTypingEvent:(NIMQChatMessageTypingEvent *)param
                         completion:(nullable NIMQChatSendMessageTypingEventHandler)completion;

/**
 * 从本地缓存查询消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getMessageCache:(NIMQChatGetMessageCacheParam *)param
             completion:(nullable NIMQChatGetMessageCacheHandler)completion;

/**
 * 批量查询频道最后一条消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getLastMessageOfChannels:(NIMQChatGetLastMessageOfChannelsParam *)param
                      completion:(nullable NIMQChatGetLastMessageOfChannelsHandler)completion;

/**
 * 搜索圈组消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)searchMsgByPage:(NIMQChatSearchMsgByPageParam *)param
                      completion:(nullable NIMQChatSearchMsgByPageHandler)completion;

/**
 * 搜索圈组 @ 我的消息
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)getMentionedMeMessages:(NIMQChatGetMentionedMeMessagesParam *)param
                      completion:(nullable NIMQChatGetMentionedMeMessagesHandler)completion;


/**
 * 批量查询消息是否 @ 当前用户
 *
 * @param param 传入参数
 * @param completion 结果回调
 */
- (void)areMentionedMeMessages:(NIMQChatAreMentionedMeMessagesParam *)param
                      completion:(nullable NIMQChatAreMentionedMeMessagesHandler)completion;

/**
 * 清理消息本地缓存
 */
- (void)clearMessageCache;

/**
 *  添加通知对象
 *
 *  @param delegate 通知对象
 */
- (void)addDelegate:(id<NIMQChatMessageManagerDelegate>)delegate;

/**
 *  移除通知对象
 *
 *  @param delegate 通知对象
 */
- (void)removeDelegate:(id<NIMQChatMessageManagerDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
