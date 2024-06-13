//
// Created by Netease on 2022/2/5.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@class NIMQChatServer;
@class NIMQChatServerMember;
@class NIMQChatChannel;
@class NIMQChatUpdateChannelBlackWhiteRoleInfo;
@class NIMQChatUpdateChannelBlackWhiteMembersInfo;
@class NIMQChatUpdateChannelCategoryBlackWhiteRoleInfo;
@class NIMQChatUpdateChannelCategoryBlackWhiteMemberInfo;
@class NIMQChatUpdateQuickCommentInfo;
@class NIMQChatChannelCategory;
@class NIMQChatServerRole;
@class NIMQChatPermissionStatusInfo;
@class NIMQChatChannelIdInfo;
@class NIMQChatUpdatedMyMemberInfo;
NS_ASSUME_NONNULL_BEGIN

// 参考：http://doc.hz.netease.com/display/MMC/QChatSystemMsgType

/**
 * 圈组系统通知附件协议
 */
@protocol NIMQChatSystemNotificationAttachment <NSObject, NSCopying>
@property (nullable, nonatomic, copy, readonly) NSDictionary *attachDict;
@property(nonatomic, assign, readonly) NIMQChatSystemNotificationType type;
+ (id<NIMQChatSystemNotificationAttachment>)initWithDict:(NSDictionary *)attachDict
                                                    type:(NIMQChatSystemNotificationType)type;
@end

/**
 * 圈组申请加入服务器接受的通知的附件
 */
@protocol NIMQChatApplyJoinServerMemberAcceptAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nullable, nonatomic, copy, readonly) NSString *applyAccid;
@property(nonatomic, assign, readonly) long requestId;
@end

@protocol NIMQChatApplyJoinServerMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nonatomic, assign, readonly) long requestId;
@end

/**
 * 圈组申请加入服务器完成的通知的附件
 */
@protocol NIMQChatApplyJoinServerMemberDoneAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nonatomic, assign, readonly) long requestId;
@end

/**
 * 圈组创建频道的通知的附件
 */
@protocol NIMQChatCreateChannelNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatChannel *channel;
@end

@protocol NIMQChatCreateServerAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@end

/**
 * 圈组删除频道的通知的附件
 */
@protocol NIMQChatDeleteChannelNotificationAttachment <NIMQChatSystemNotificationAttachment>
@end

/**
 * 圈组邀请服务器成员已接受的通知的附件
 */
@protocol NIMQChatInviteServerMemberAcceptAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nullable, nonatomic, copy, readonly) NSString *inviteAccid;
@property(nonatomic, assign, readonly) long requestId;
@end

@protocol NIMQChatInviteServerMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nonatomic, assign, readonly) long requestId;
@end

/**
 * 圈组邀请服务器成员的通知的附件
 */
@protocol NIMQChatInviteServerMembersDoneAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nullable, nonatomic, copy, readonly) NSArray<NSString *> *invitedAccids;
@property(nonatomic, assign, readonly) long requestId;
@end

/**
 * 圈组踢出服务器成员的通知的附件
 */
@protocol NIMQChatKickServerMembersDoneAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nullable, nonatomic, copy, readonly) NSArray<NSString *> *kickedAccids;
@end

/**
 * 圈组成员离开服务器的通知的附件
 */
@protocol NIMQChatLeaveServerAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@end

@protocol NIMQChatRejectApplyServerMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nonatomic, assign, readonly) long requestId;
@end

@protocol NIMQChatRejectInviteServerMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nonatomic, assign, readonly) long requestId;
@end

@protocol NIMQChatRemoveServerAttachment <NIMQChatSystemNotificationAttachment>
@end

/**
 * 圈组更新频道的通知的附件
 */
@protocol NIMQChatUpdateChannelNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatChannel *channel;
@end
/**
 * 圈组更新服务器的通知的附件
 */
@protocol NIMQChatUpdateServerAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@end
/**
 * 圈组更新服务器成员的通知的附件
 */
@protocol NIMQChatUpdateServerMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property(nullable, nonatomic, copy, readonly) NIMQChatServerMember *serverMember;
@end

/**
 * 圈组更新频道身份组黑白名单的通知的附件
 */
@protocol NIMQChatUpdateChannelBlackWhiteRoleAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatUpdateChannelBlackWhiteRoleInfo *updateBlackWhiteRoleInfo;
@end

/**
 * 圈组更新频道成员黑白名单的通知的附件
 */
@protocol NIMQChatUpdateChannelBlackWhiteMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatUpdateChannelBlackWhiteMembersInfo *updateBlackWhiteMembersInfo;
@end

/**
 * 圈组更新快捷评论的通知的附件
 */
@protocol NIMQChatUpdateQuickCommentAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatUpdateQuickCommentInfo *updateQuickCommentInfo;
@end

/**
 * 圈组创建频道分组的通知的附件
 */
@protocol NIMQChatCreateChannelCategoryNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatChannelCategory *channelCategory;
@end

/**
 * 圈组更新频道分组的通知的附件
 */
@protocol NIMQChatUpdateChannelCategoryNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatChannelCategory *channelCategory;
@end

/**
 * 圈组删除频道分组的通知的附件
 */
@protocol NIMQChatDeleteChannelCategoryNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property(nonatomic, assign, readonly) unsigned long long categoryId;
@end

/**
 * 圈组更新频道分组身份组黑白名单的通知的附件
 */
@protocol NIMQChatUpdateChannelCategoryBlackWhiteRoleAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatUpdateChannelCategoryBlackWhiteRoleInfo *updateChannelCategoryBlackWhiteRoleInfo;
@end

/**
 * 圈组更新频道分组成员黑白名单的通知的附件
 */
@protocol NIMQChatUpdateChannelCategoryBlackWhiteMemberAttachment <NIMQChatSystemNotificationAttachment>
@property(nullable, nonatomic, copy, readonly) NIMQChatUpdateChannelCategoryBlackWhiteMemberInfo *updateChannelCategoryBlackWhiteMemberInfo;
@end

/**
 * 服务器身份组加入成员通知的附件
 */
@protocol NIMQChatAddServerRoleMembersNotificationAttachment <NIMQChatSystemNotificationAttachment>
/**
 * 添加的成员
 */
@property(nullable, nonatomic, copy, readonly) NSArray <NSString *> *addServerRoleAccIds;

/**
 * 服务器id
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;
/**
 * 身份组id
 */
@property(nonatomic, assign, readonly) unsigned long long roleId;

@end

/**
 * 移除服务器身份组成员通知的附件
 */
@protocol NIMQChatRemoveServerRoleMembersNotificationAttachment <NIMQChatSystemNotificationAttachment>
/**
 * 移除的成员
 */
@property(nullable, nonatomic, copy, readonly) NSArray <NSString *> *removeServerRoleAccIds;

/**
 * 服务器id
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;
/**
 * 身份组id
 */
@property(nonatomic, assign, readonly) unsigned long long roleId;

@end

/**
 * 更新服务器身份组权限的通知的附件
 */
@protocol NIMQChatUpdateServerRoleAuthNotificationAttachment <NIMQChatSystemNotificationAttachment>

/**
 * 服务器id
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;
/**
 * 身份组id
 */
@property(nonatomic, assign, readonly) unsigned long long roleId;

/**
 * 操作的权限状态列表
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *updateAuths;

@end

/**
 * 更新频道身份组权限的通知的附件
 */
@protocol NIMQChatUpdateChannelRoleAuthNotificationAttachment <NIMQChatSystemNotificationAttachment>
/**
 * 服务器id
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;
/**
 * 频道身份组id
 */
@property(nonatomic, assign, readonly) unsigned long long roleId;
/**
 * 频道id
 */
@property(nonatomic, assign, readonly) unsigned long long channelId;
/**
 * 服务器身份组id
 */
@property(nonatomic, assign, readonly) unsigned long long parentRoleId;

/**
 * 操作的权限状态列表
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *updateAuths;

@end

/**
 * 更新个人定制权限的通知的附件
 */
@protocol NIMQChatUpdateMemberRoleAuthNotificationAttachment <NIMQChatSystemNotificationAttachment>
/**
 * 服务器id
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;
/**
 * 频道id
 */
@property(nonatomic, assign, readonly) unsigned long long channelId;
/**
 * 个人id
 */
@property(nullable, nonatomic, copy, readonly) NSString *accId;

/**
 * 操作的权限状态列表
 */
@property (nonatomic, copy) NSArray <NIMQChatPermissionStatusInfo *> *updateAuths;


@end

/*
 * 圈组频道可见性更新的通知的附件
 */
@protocol NIMQChatChannelVisibilityUpdateNotificationAttachment <NIMQChatSystemNotificationAttachment>
// 进入或者退出频道
@property (nonatomic, assign, readonly) NIMQChatInoutType inoutType;

@end

/*
 * 圈组进出服务器的通知的附件
 */
@protocol NIMQChatServerEnterLeaveNotificationAttachment <NIMQChatSystemNotificationAttachment>
// 进入或者退出频道
@property (nonatomic, assign, readonly) NIMQChatInoutType inoutType;

@end

/**
 * 圈组用户通过邀请码加入服务器的通知的附件
 */
@protocol NIMQChatServerJoinByInviteCodeNotificationAttachment <NIMQChatSystemNotificationAttachment>
@property (nullable, nonatomic, copy, readonly) NIMQChatServer *server;
@property (nonatomic, assign, readonly) long requestId;
@property (nullable, nonatomic, copy, readonly) NSString *inviteCode;

@end

/**
 * 频道对游客可见性变更的附件
 */
@protocol NIMQChatVisitorChannelVisibilityUpdateNotificationAttachment <NIMQChatSystemNotificationAttachment>
// 进出事件
@property (nonatomic, assign, readonly) NIMQChatInoutType inoutType;
@end


/**
 * 当前用户服务器成员信息与IM资料的联动变更的附件
 */
@protocol NIMQChatMyMemberInfoUpdatedNotificationAttachment <NIMQChatSystemNotificationAttachment>

/**
 * 当前用户成员信息发生变更的信息列表
 */
@property (nonatomic, copy) NSArray<NIMQChatUpdatedMyMemberInfo *> *updatedInfos;

@end

NS_ASSUME_NONNULL_END
