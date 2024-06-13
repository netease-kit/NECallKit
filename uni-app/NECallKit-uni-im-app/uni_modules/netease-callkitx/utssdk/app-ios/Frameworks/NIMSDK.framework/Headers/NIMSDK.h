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

/**
 *  会话相关定义
 */
#import "NIMSession.h"
#import "NIMRecentSession.h"
#import "NIMMessageSearchOption.h"
#import "NIMIncompleteSessionInfo.h"


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
#import "NIMQChatMessage.h"
#import "NIMQChatMessageRefer.h"
#import "NIMQChatMessageThreadInfo.h"
#import "NIMQChatServer.h"
#import "NIMQChatServerMember.h"
#import "NIMQChatChannelMember.h"
#import "NIMQChatChannel.h"
#import "NIMQChatChannelIdInfo.h"
#import "NIMQChatServerRole.h"
#import "NIMQChatServerRoleMember.h"
#import "NIMQChatChannelRole.h"
#import "NIMQChatMemberRole.h"
#import "NIMQChatPermissionStatusInfo.h"
#import "NIMQChatSystemNotification.h"
#import "NIMQChatSystemNotificationAttachmentProtocol.h"
#import "NIMQChatSystemNotificationSetting.h"
#import "NIMQChatUnreadInfo.h"
#import "NIMQChatMessageQuickCommentInfo.h"
/**
 * 圈组登录
 */
#import "NIMQChatLoginParam.h"
#import "NIMQChatLoginResult.h"
#import "NIMQChatOnlineStatusResult.h"

/**
 * 圈组服务器
 */
#import "NIMQChatCreateServerParam.h"
#import "NIMQChatCreateServerResult.h"
#import "NIMQChatDeleteServerParam.h"
#import "NIMQChatUpdateServerParam.h"
#import "NIMQChatUpdateServerResult.h"
#import "NIMQChatGetServersByPageParam.h"
#import "NIMQChatGetServersByPageResult.h"
#import "NIMQChatGetServersParam.h"
#import "NIMQChatGetServersResult.h"
#import "NIMQChatSearchServerByPageParam.h"
#import "NIMQChatSearchServerByPageResult.h"

#import "NIMQChatGetServerMembersByPageParam.h"
#import "NIMQChatGetServerMembersParam.h"
#import "NIMQChatGetServerMembersResult.h"
#import "NIMQChatUpdateServerMemberInfoParam.h"
#import "NIMQChatUpdateMyMemberInfoParam.h"

#import "NIMQChatApplyServerJoinParam.h"
#import "NIMQChatInviteServerMembersParam.h"
#import "NIMQChatAcceptServerApplyParam.h"
#import "NIMQChatAcceptServerInviteParam.h"
#import "NIMQChatRejectServerApplyParam.h"
#import "NIMQChatRejectServerInviteParam.h"
#import "NIMQChatLeaveServerParam.h"
#import "NIMQChatKickServerMembersParam.h"
#import "NIMQChatGetServerMemberListByPageResult.h"
#import "NIMQChatSearchServerMemberByPageParam.h"
#import "NIMQChatSearchServerChannelMemberParam.h"
#import "NIMQChatSearchServerChannelMemberResult.h"
#import "NIMQChatSearchServerMemberByPageResult.h"
#import "NIMQChatUpdateServerMemberBanParam.h"
#import "NIMQChatGetServerBanedMembersByPageParam.h"
#import "NIMQChatGetServerBanedMembersByPageResult.h"
#import "NIMQChatInviteServerMembersResult.h"
#import "NIMQChatSubsribeServerResult.h"
#import "NIMQChatServerUnreadInfo.h"
#import "NIMQChatGenerateInviteCodeParam.h"
#import "NIMQChatGenerateInviteCodeResult.h"
#import "NIMQChatJoinByInviteCodeParam.h"
#import "NIMQChatGetInviteApplyRecordOfServerParam.h"
#import "NIMQChatGetInviteApplyHistoryByServerResult.h"
#import "NIMQChatGetInviteApplyRecordOfSelfParam.h"
#import "NIMQChatGetInviteApplyHistorySelfResult.h"
#import "NIMQChatInviteApplyHistoryRecord.h"
#import "NIMQChatApplyServerJoinResult.h"
#import "NIMQChatSubscribeServerAsVisitorParam.h"
#import "NIMQChatSubscribeServerAsVisitorResult.h"
#import "NIMQChatEnterServerAsVisitorParam.h"
#import "NIMQChatEnterServerAsVisitorResult.h"
#import "NIMQChatLeaveServerAsVisitorParam.h"
#import "NIMQChatLeaveServerAsVisitorResult.h"

/**
 * 圈组频道
 */
#import "NIMQChatCreateChannelParam.h"
#import "NIMQChatCreateChannelResult.h"
#import "NIMQChatDeleteChannelParam.h"
#import "NIMQChatUpdateChannelParam.h"
#import "NIMQChatGetChannelsByPageParam.h"
#import "NIMQChatGetChannelsParam.h"
#import "NIMQChatGetChannelsResult.h"
#import "NIMQChatGetChannelsByPageResult.h"
#import "NIMQChatSearchChannelByPageParam.h"
#import "NIMQChatSearchChannelByPageResult.h"
#import "NIMQChatGetChannelUnreadInfosParam.h"
#import "NIMQChatGetChannelUnreadInfosResult.h"
#import "NIMQChatGetChannelMembersByPageParam.h"
#import "NIMQChatGetChannelBlackWhiteRolesByPageParam.h"
#import "NIMQChatGetChannelBlackWhiteMembersByPageParam.h"
#import "NIMQChatUpdateChannelBlackWhiteMembersParam.h"
#import "NIMQChatUpdateChannelBlackWhiteMembersInfo.h"
#import "NIMQChatUpdateChannelBlackWhiteRoleParam.h"
#import "NIMQChatUpdateChannelBlackWhiteRoleInfo.h"
#import "NIMQChatGetChannelMembersByPageResult.h"
#import "NIMQChatGetChannelBlackWhiteRolesByPageResult.h"
#import "NIMQChatGetChannelBlackWhiteMembersByPageResult.h"
#import "NIMQChatGetExistingChannelBlackWhiteMembersParam.h"
#import "NIMQChatGetExistingChannelBlackWhiteRolesParam.h"
#import "NIMQChatGetExistingChannelBlackWhiteRolesResult.h"
#import "NIMQChatGetExistingChannelBlackWhiteMembersResult.h"
#import "NIMQChatUpdateChannelCategoryBlackWhiteMemberInfo.h"
#import "NIMQChatUpdateChannelCategoryBlackWhiteRoleInfo.h"
#import "NIMQChatSubscribeChannelResult.h"
#import "NIMQChatSubscribeChannelAsVisitorParam.h"
#import "NIMQChatSubscribeChannelAsVisitorResult.h"
/**
 * 多媒体频道
 */
#import "NIMQChatRTCChannelInfo.h"
#import "NIMQChatRTCChannelOnlineMember.h"
#import "NIMQChatRTCUpdateChannelInfoParam.h"
#import "NIMQChatRequestTokenResult.h"

/**
 * 圈组分组
 */
#import "NIMQChatChannelCategory.h"
#import "NIMQChatChannelCategoryIdInfo.h"
#import "NIMQChatCreateChannelCategoryParam.h"
#import "NIMQChatDeleteChannelCategoryParam.h"
#import "NIMQChatUpdateChannelCategoryParam.h"
#import "NIMQChatGetChannelCategoriesParam.h"
#import "NIMQChatGetChannelCategoriesResult.h"

#import "NIMQChatGetChannelCategoryBlackWhiteRolesByPageParam.h"
#import "NIMQChatGetChannelCategoryBlackWhiteMembersByPageParam.h"
#import "NIMQChatUpdateChannelCategoryBlackWhiteMembersParam.h"
#import "NIMQChatUpdateChannelCategoryBlackWhiteRoleParam.h"
#import "NIMQChatGetChannelCategoryBlackWhiteRolesByPageResult.h"
#import "NIMQChatGetChannelCategoryBlackWhiteMembersByPageResult.h"
#import "NIMQChatGetExistingChannelCategoryBlackWhiteMembersParam.h"
#import "NIMQChatGetExistingChannelCategoryBlackWhiteRolesParam.h"
#import "NIMQChatGetExistingChannelCategoryBlackWhiteRolesResult.h"
#import "NIMQChatGetExistingChannelCategoryBlackWhiteMembersResult.h"
#import "NIMQChatGetCategoriesInServerByPageParam.h"
#import "NIMQChatGetCategoriesInServerByPageResult.h"
#import "NIMQChatGetChannelsInCategoryByPageParam.h"
#import "NIMQChatGetChannelsInCategoryByPageResult.h"
#import "NIMQChatUpdateCategoryInfoOfChannelParam.h"
/**
 * 圈组身份组
 */
#import "NIMQChatCreateServerRoleParam.h"
#import "NIMQChatDeleteServerRoleParam.h"
#import "NIMQChatUpdateServerRoleParam.h"
#import "NIMQChatGetServerRolesParam.h"
#import "NIMQChatAddChannelRoleParam.h"
#import "NIMQChatRemoveChannelRoleParam.h"
#import "NIMQChatUpdateChannelRoleParam.h"
#import "NIMQChatGetChannelRolesParam.h"
#import "NIMQChatAddMemberRoleParam.h"
#import "NIMQChatRemoveMemberRoleParam.h"
#import "NIMQChatUpdateMemberRoleParam.h"
#import "NIMQChatGetMemberRolesParam.h"
#import "NIMQChatAddServerRoleMembersParam.h"
#import "NIMQChatRemoveServerRoleMemberParam.h"
#import "NIMQChatGetServerRoleMembersParam.h"
#import "NIMQChatGetServerRolesByAccidParam.h"

#import "NIMQChatGetServerRolesResult.h"
#import "NIMQChatGetChannelRolesResult.h"
#import "NIMQChatGetMemberRolesResult.h"
#import "NIMQChatGetServerRoleMembersResult.h"
#import "NIMQChatGetServerRolesByAccidResult.h"
#import "NIMQChatGetServerRolesResult.h"
#import "NIMQChatAddServerRoleMembersResult.h"
#import "NIMQChatRemoveServerRoleMembersResult.h"
#import "NIMQChatGetExistingAccidsInServerRoleParam.h"
#import "NIMQChatGetExistingAccidsInServerRoleResult.h"
#import "NIMQChatGetExistingChannelRolesByServerRoleIdsParam.h"
#import "NIMQChatGetExistingChannelRolesByServerRoleIdsResult.h"
#import "NIMQChatGetExistingAccidsOfMemberRolesParam.h"
#import "NIMQChatGetExistingAccidsOfMemberRolesResult.h"
#import "NIMQChatUpdateServerRolePrioritiesParam.h"
#import "NIMQChatUpdateServerRolePrioritiesResult.h"
#import "NIMQChatGetExistingServerRoleMembersByAccidsResult.h"
#import "NIMQChatGetExistingServerRoleMembersByAccidsParam.h"
#import "NIMQChatCheckPermissionParam.h"
#import "NIMQChatCheckPermissionsParam.h"
#import "NIMQChatCheckPermissionsResult.h"

#import "NIMQChatChannelCategoryRole.h"
#import "NIMQChatChannelCategoryMemberRole.h"
#import "NIMQChatAddChannelCategoryRoleParam.h"
#import "NIMQChatRemoveChannelCategoryRoleParam.h"
#import "NIMQChatUpdateChannelCategoryRoleParam.h"
#import "NIMQChatGetChannelCategoryRolesParam.h"
#import "NIMQChatAddChannelCategoryMemberRoleParam.h"
#import "NIMQChatRemoveChannelCategoryMemberRoleParam.h"
#import "NIMQChatUpdateChannelCategoryMemberRoleParam.h"
#import "NIMQChatGetChannelCategoryMemberRolesParam.h"

#import "NIMQChatGetChannelCategoryRolesResult.h"
#import "NIMQChatGetChannelCategoryMemberRolesResult.h"

/**
 * 圈组消息
 */
#import "NIMQChatSubscribeParam.h"
#import "NIMQChatGetMessageHistoryParam.h"
#import "NIMQChatGetMessageHistoryByIdsParam.h"
#import "NIMQChatMessageServerIdInfo.h"
#import "NIMQChatGetMessageHistoryResult.h"
#import "NIMQChatGetThreadMessagesParam.h"
#import "NIMQChatGetThreadMessagesResult.h"
#import "NIMQChatGetMessageCacheParam.h"
#import "NIMQChatGetMessageCacheResult.h"
#import "NIMQChatSendSystemNotificationParam.h"
#import "NIMQChatSendSystemNotificationResult.h"
#import "NIMQChatResendSystemNotificationParam.h"
#import "NIMQChatUpdateSystemNotificationParam.h"
#import "NIMQChatUpdateSystemNotificationResult.h"
#import "NIMQChatReceiveSystemNotificationResult.h"
#import "NIMQChatSystemNotificationUpdateResult.h"
#import "NIMQChatMarkMessageReadParam.h"
#import "NIMQChatMarkSystemNotificationsReadParam.h"
#import "NIMQChatUpdateMessageInfo.h"
#import "NIMQChatUpdateMessageParam.h"
#import "NIMQChatRevokeMessageParam.h"
#import "NIMQChatDeleteMessageParam.h"
#import "NIMQChatUpdateMessageResult.h"
#import "NIMQChatUpdateMessageEvent.h"
#import "NIMQChatUpdateParam.h"
#import "NIMQChatUnreadInfoChangedEvent.h"
#import "NIMQChatFetchQuickCommentsByMsgsResult.h"
#import "NIMQChatUpdateQuickCommentInfo.h"
#import "NIMQChatMessageAntispamSetting.h"
#import "NIMQChatMessageAntispamResult.h"
#import "NIMQChatMessageTypingEvent.h"
#import "NIMQChatGetLastMessageOfChannelsParam.h"
#import "NIMQChatGetLastMessageOfChannelsResult.h"
#import "NIMQChatMessageUpdateContent.h"
#import "NIMQChatSearchMsgByPageParam.h"
#import "NIMQChatGetMentionedMeMessagesParam.h"
#import "NIMQChatGetMentionedMeMessagesResult.h"
#import "NIMQChatSearchMsgByPageResult.h"
#import "NIMQChatMarkServerReadParam.h"
#import "NIMQChatMarkServerReadResult.h"
#import "NIMQChatAreMentionedMeMessagesParam.h"
#import "NIMQChatAreMentionedMeMessagesResult.h"
#import "NIMQChatSubscribeAllChannelParam.h"
#import "NIMQChatSubscribeAllChannelResult.h"
#import "NIMQChatUpdatedMyMemberInfo.h"
/**
 *  圈组推送
 */
#import "NIMQChatUserPushNotificationConfig.h"

/**
* 日志
*/
# import "NIMLogDesensitizationConfig.h"
