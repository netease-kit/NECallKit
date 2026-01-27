//
//  NIMSDK.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2017年 Netease. All rights reserved.
//

/**
 *  平台相关定义
 */
#import "NIMPlatform.h"

/**
 *  全局枚举和结构体定义
 */
#import "NIMGlobalDefs.h"

/**
 *  配置项
 */
#import "NIMSDKOption.h"
#import "NIMSDKConfig.h"
#import "NIMEncryptionConfig.h"
#import "NIMAsymEncryptionOption.h"

/**
 *  会话相关定义
 */
#import "NIMSession.h"
#import "NIMRecentSession.h"
#import "NIMMessageSearchOption.h"
#import "NIMIncompleteSessionInfo.h"
#import "NIMMessagesInSessionOption.h"

/**
 *  用户定义
 */
#import "NIMUser.h"
#import "NIMUserSearchOption.h"

/**
 *  群相关定义
 */
#import "NIMTeamDefs.h"
#import "NIMTeam.h"
#import "NIMTeamMember.h"
#import "NIMCreateTeamOption.h"
#import "NIMCreateTeamExOption.h"
#import "NIMTeamManagerDelegate.h"
#import "NIMTeamFetchMemberOption.h"
#import "NIMTeamSearchOption.h"
#import "NIMTeamMemberSearchOption.h"
#import "NIMTeamMemberSearchResult.h"

/**
 *  聊天室相关定义
 */
#import "NIMChatroom.h"
#import "NIMChatroomEnterRequest.h"
#import "NIMMessageChatroomExtension.h"
#import "NIMChatroomMember.h"
#import "NIMChatroomMemberRequest.h"
#import "NIMChatroomTagRequest.h"
#import "NIMChatroomUpdateRequest.h"
#import "NIMChatroomQueueRequest.h"
#import "NIMChatroomBeKickedResult.h"
#import "NIMChatroomCdnTrackInfo.h"
#import "NIMGetMessagesByTagsParam.h"
#import "NIMChatroomTagsUpdateEvent.h"

/**
 *  消息定义
 */
#import "NIMMessage.h"
#import "NIMAddEmptyRecentSessionBySessionOption.h"
#import "NIMSystemNotification.h"
#import "NIMRevokeMessageNotification.h"
#import "NIMDeleteMessagesOption.h"
#import "NIMDeleteMessageOption.h"
#import "NIMBroadcastMessage.h"
#import "NIMImportedRecentSession.h"
#import "NIMClearMessagesOption.h"
#import "NIMDeleteRecentSessionOption.h"
#import "NIMBatchDeleteMessagesOption.h"
#import "NIMRevokeMessageOption.h"
#import "NIMSessionDeleteAllRemoteMessagesOptions.h"
#import "NIMSessionDeleteAllRemoteMessagesInfo.h"
#import "NIMMessageRobotInfo.h"
#import "NIMMessageAIConfig.h"
#import "NIMMessageSetting.h"
#import "NIMMessageApnsMemberOption.h"
#import "NIMMessageReceipt.h"
#import "NIMMessageStreamConfig.h"
#import "NIMTeamMessageReceipt.h"
#import "NIMTeamMessageReceiptDetail.h"
#import "NIMAntiSpamOption.h"

#import "NIMImageObject.h"
#import "NIMAudioObject.h"
#import "NIMVideoObject.h"
#import "NIMFileObject.h"
#import "NIMLocationObject.h"
#import "NIMTipObject.h"
#import "NIMRobotObject.h"
#import "NIMRtcCallRecordObject.h"
#import "NIMNotificationObject.h"
#import "NIMMessageObjectProtocol.h"
#import "NIMCustomObject.h"

#import "NIMNotificationContent.h"
#import "NIMTeamNotificationContent.h"
#import "NIMSuperTeamNotificationContent.h"
#import "NIMChatroomNotificationContent.h"
#import "NIMNetCallNotificationContent.h"
#import "NIMUnsupportedNotificationContent.h"
#import "NIMCustomSystemNotificationSetting.h"

/**
 *  推送定义
 */
#import "NIMPushNotificationSetting.h"

/**
 *  登录定义
 */
#import "NIMLoginClient.h"
#import "NIMLoginKickoutResult.h"

/**
 *  文档转码信息
 */
#import "NIMDocTranscodingInfo.h"

/**
 *  事件订阅
 */
#import "NIMSubscribeEvent.h"
#import "NIMSubscribeRequest.h"
#import "NIMSubscribeOnlineInfo.h"
#import "NIMSubscribeResult.h"

/**
 *  智能机器人
 */
#import "NIMRobot.h"

/**
 *  缓存管理
 */
#import "NIMCacheQuery.h"

/**
 *  通用音视频信令
 */
#import "NIMSignalingMemberInfo.h"
#import "NIMSignalingRequest.h"
#import "NIMSignalingResponse.h"

/**
 *  各个对外接口协议定义
 */
#import "NIMLoginManagerProtocol.h"
#import "NIMChatManagerProtocol.h"
#import "NIMConversationManagerProtocol.h"
#import "NIMMediaManagerProtocol.h"
#import "NIMUserManagerProtocol.h"
#import "NIMTeamManagerProtocol.h"
#import "NIMSuperTeamManagerProtocol.h"
#import "NIMSystemNotificationManagerProtocol.h"
#import "NIMApnsManagerProtocol.h"
#import "NIMResourceManagerProtocol.h"
#import "NIMChatroomManagerProtocol.h"
#import "NIMDocTranscodingManagerProtocol.h"
#import "NIMEventSubscribeManagerProtocol.h"
#import "NIMRobotManagerProtocol.h"
#import "NIMRedPacketManagerProtocol.h"
#import "NIMBroadcastManagerProtocol.h"
#import "NIMAntispamManagerProtocol.h"
#import "NIMSignalManagerProtocol.h"
#import "NIMPassThroughManagerProtocol.h"
#import "NIMChatExtendManagerProtocol.h"
#import "NIMIndexManagerProtocol.h"
#import "NIMQChatManagerProtocol.h"
#import "NIMQChatApnsManagerProtocol.h"
#import "NIMQChatServerManagerProtocol.h"
#import "NIMQChatChannelManagerProtocol.h"
#import "NIMQChatRoleManagerProtocol.h"
#import "NIMQChatMessageManagerProtocol.h"
#import "NIMQChatMessageExtendManagerProtocol.h"
#import "NIMQChatRTCChannelManagerProtocol.h"
#import "NIMCustomizedAPIManagerProtocol.h"
#import "NIMSystemStateProtocol.h"
#import "NIMAIManagerProtocol.h"

/**
 *  V2接口协议定义
 */
#import "V2NIMLoginServiceProtocol.h"
#import "V2NIMMessageServiceProtocol.h"
#import "V2NIMStorageServiceProtocol.h"
#import "V2NIMNotificationServiceProtocol.h"
#import "V2NIMConversationServiceProtocol.h"
#import "V2NIMTeamServiceProtocol.h"
#import "V2NIMNotificationServiceProtocol.h"
#import "V2NIMSettingServiceProtocol.h"
#import "V2NIMUserServiceProtocol.h"
#import "V2NIMFriendServiceProtocol.h"
#import "V2NIMChatroomServiceProtocol.h"
#import "V2NIMAIServiceProtocol.h"
#import "V2NIMSignallingServiceProtocol.h"
#import "V2NIMSubscriptionServiceProtocol.h"
#import "V2NIMPassthroughServiceProtocol.h"
#import "V2NIMLocalConversationServiceProtocol.h"
#import "V2NIMApnsServiceProtocol.h"
#import "V2NIMStatisticsServiceProtocol.h"

/**
 *  SDK业务类
 */
#import "NIMServerSetting.h"
#import "NIMSDKHeader.h"

/**
 * 数据库
 */
#import "NIMDatabaseException.h"

/**
 *  资源
 */
#import "NIMResourceExtraInfo.h"

/**
 *  透传代理定义
 */
#import "NIMPassThroughOption.h"

/**
 *  Thread Talk & 快捷回复
 */
#import "NIMThreadTalkFetchOption.h"
#import "NIMChatExtendBasicInfo.h"
#import "NIMQuickComment.h"
#import "NIMThreadTalkFetchResult.h"

/**
 * 收藏
 */
#import "NIMCollectInfo.h"
#import "NIMCollectQueryOptions.h"
#import "NIMAddCollectParams.h"

/**
 * 置顶会话
 */
#import "NIMStickTopSessionInfo.h"
#import "NIMAddStickTopSessionParams.h"
#import "NIMSyncStickTopSessionResponse.h"
#import "NIMLoadRecentSessionsOptions.h"

/**
 * PIN
 */
#import "NIMMessagePinItem.h"
#import "NIMSyncMessagePinRequest.h"
#import "NIMSyncMessagePinResponse.h"

/**
 * 圈组
 */
#import "NIMQChatConfig.h"
#import "NIMQChatOption.h"
#import "NIMQChatAPIDefs.h"

/**
 * 其他
 */
#import "NIMRedPacketRequest.h"
#import "NIMGenericTypeAPIDefine.h"

/**
* 日志
*/
# import "NIMLogDesensitizationConfig.h"

/**
 *  V2 Base
 */
#import "V2NIMError.h"
#import "V2NIMBase.h"

/**
 *  V2 Common
 */
#import "V2NIMSDKOption.h"
#import "V2NIMAntispamConfig.h"
#import "V2NIMLocationInfo.h"
#import "V2NIMSize.h"
#import "V2NIMRouteConfig.h"

/**
 *  V2 Conversation
 */
#import "V2NIMConversationEnum.h"
#import "V2NIMConversationIdUtil.h"
#import "V2NIMLastMessage.h"

/**
 *  V2 Message
 */
#import "V2NIMMessage.h"
#import "V2NIMMessage+V1API.h"
#import "V2NIMMessageAttachment.h"
#import "V2NIMMessageAttachmentCreator.h"
#import "V2NIMMessageRefer.h"
#import "V2NIMMessageCreator.h"
#import "V2NIMMessageEnum.h"
#import "V2NIMMessageFilter.h"
#import "V2NIMIndex.h"
#import "V2NIMMessagePinNotification.h"
#import "V2NIMMessageRevokeNotification.h"
#import "V2NIMMessageRevokeParams.h"
#import "V2NIMMessageSearchParam.h"
#import "V2NIMNotificationAntispamConfig.h"
#import "V2NIMNotificationConfig.h"
#import "V2NIMNotificationPushConfig.h"
#import "V2NIMNotificationRouteConfig.h"
#import "V2NIMP2PMessageReadReceipt.h"
#import "V2NIMSendCustomNotificationParams.h"
#import "V2NIMTeamMessageReadReceipt.h"
#import "V2NIMMessageQuickCommentPushConfig.h"
#import "V2NIMAddCollectionParams.h"
#import "V2NIMCollection.h"
#import "V2NIMMessageQuickComment.h"
#import "V2NIMMessagePin.h"
#import "V2NIMCollectionOption.h"
#import "V2NIMMessageQuickCommentNotification.h"
#import "V2NIMMessageSearchParams.h"
#import "V2NIMMessageSearchExParams.h"
#import "V2NIMMessageSearchResult.h"
#import "V2NIMMessageDeletedNotification.h"
#import "V2NIMClearHistoryNotification.h"
#import "V2NIMCustomNotification.h"
#import "V2NIMBroadcastNotification.h"
#import "V2NIMVoiceToTextParams.h"
#import "V2NIMTeamMessageReadReceiptDetail.h"
#import "V2NIMThreadMessageListResult.h"
#import "V2NIMThreadMessageListOption.h"
#import "V2NIMModifyMessageParams.h"
#import "V2NIMModifyMessageResult.h"
#import "V2NIMCollectionListResult.h"
#import "V2NIMMessageListResult.h"
/**
 * V2 Chatroom
 */
#import "V2NIMChatroomMessage.h"
#import "V2NIMChatroomNotificationAttachment.h"
#import "V2NIMChatroomMessageCreator.h"
#import "V2NIMChatroomCdnTrackInfo.h"

/**
 * V2 信令
 */
#import "V2NIMSignallingRequest.h"

/**
 * V2 Storage
 */
#import "V2NIMDownloadMessageAttachmentParams.h"
#import "V2NIMGetMediaResourceInfoResult.h"

/**
 *  V2 Util
 */
#import "V2NIMClientAntispamUtil.h"
#import "V2NIMClientAntispamResult.h"
#import "V2NIMMessageConverter.h"
#import "V2NIMStorageUtil.h"
#import "DataStructureConverter.h"
