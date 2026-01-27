//
//  V2NIMChatroomNotificationAttachment.h
//  NIMSDK
//
//  Created by 陈吉力 on 2023/12/17.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageAttachment.h"
#import "V2NIMChatroomServiceProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, V2NIMChatroomMessageNotificationType) {
    /**
     * 成员进入聊天室
            映射event_id: 301
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_ENTER = 0,
    /**
     * 成员退出聊天室
            映射event_id: 302
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_EXIT = 1,
    /**
     * 成员被加入黑名单
            映射event_id: 303
            自己会直接被踢， 收不到， 只会收到其他人
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_BLOCK_ADDED = 2,
    /**
     * 成员被移除黑名单
            映射event_id: 304
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_BLOCK_REMOVED = 3,
    /**
     * 成员被禁言
            映射event_id: 305
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_CHAT_BANNED_ADDED = 4,
    /**
     * 成员取消禁言
            映射event_id: 306
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_CHAT_BANNED_REMOVED = 5,
    /**
     * 聊天室信息更新
            映射event_id: 312
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_ROOM_INFO_UPDATED = 6,
    /**
     * 成员被踢
            映射event_id: 313
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_KICKED = 7,
    /**
     * 成员临时禁言
            映射event_id: 314
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_TEMP_CHAT_BANNED_ADDED = 8,
    /**
     * 成员解除临时禁言
            映射event_id: 315
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_TEMP_CHAT_BANNED_REMOVED = 9,
    /**
     * 成员信息更新（nick/avatar/extension）
            映射event_id: 316
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MEMBER_INFO_UPDATED = 10,
    /**
     * 队列有变更
            映射event_id: 317
            映射event_id: 320:  麦序队列中有批量变更，发生在元素提交者离开聊天室或者从聊天室异常掉线时
            映射event_id: 324:  麦序队列中有批量添加
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_QUEUE_CHANGE = 11,
    /**
     * 聊天室被禁言
            仅创建者和管理员可以发消息
            映射event_id: 318
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_CHAT_BANNED = 12,
    /**
     * 聊天室解除禁言
            映射event_id: 319
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_CHAT_BANNED_REMOVED = 13,
    /**
     * 聊天室新增标签禁言，包括的字段是muteDuration、targetTag、operator、opeNick字段
            映射event_id: 321
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_TAG_TEMP_CHAT_BANNED_ADDED = 14,
    /**
     * 聊天室移除标签禁言，包括的字段是muteDuration、targetTag、operator、opeNick字段
            映射event_id: 322
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_TAG_TEMP_CHAT_BANNED_REMOVED = 15,
    /**
     * 聊天室消息撤回，包括的字段是operator、target、msgTime、msgId、ext字段
            映射event_id: 323
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_MESSAGE_REVOKE = 16,
    /**
     * 聊天室标签更新
            映射event_id: 325
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_TAGS_UPDATE = 17,
    /**
     * 聊天室成员角色更新
            映射event_id: 326, 新增ID， V2代替之前307， 308， 309， 310
            PreviousRole， CurrentRole
     */
    V2NIM_CHATROOM_MESSAGE_NOTIFICATION_TYPE_ROLE_UPDATE = 18,

};

typedef NS_ENUM(NSInteger, V2NIMChatroomQueueChangeType)
{
    /// 未知
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_UNKNOWN = 0,
    /// 新增队列元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_OFFER = 1,
    /// 移除队列元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_POLL = 2,
    /// 清空所有元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_DROP = 3,
    /// 部分清理元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_PARTCLEAR = 4,
    /// 批量更新元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_BATCH_UPDATE = 5,
    /// 批量添加元素
    V2NIM_CHATROOM_QUEUE_CHANGE_TYPE_BATCH_OFFER = 6,
};


@interface V2NIMChatroomNotificationAttachment : V2NIMMessageAttachment
/// 通知类型
@property(nonatomic, assign, readonly) V2NIMChatroomMessageNotificationType type;
/// 被操作的成员账号列表
@property(nonatomic, strong, readonly) NSArray<NSString *> *targetIds;
/// 被操作成员的昵称列表
@property(nonatomic, strong, readonly) NSArray<NSString *> *targetNicks;
/// 被操作的标签
@property(nonatomic, strong, readonly) NSString *targetTag;
/// 操作者
@property(nonatomic, strong, readonly) NSString *operatorId;
/// 操作者昵称
@property(nonatomic, strong, readonly) NSString *operatorNick;
/// 扩展字段
@property(nonatomic, strong, readonly) NSString *notificationExtension;
/// 更新后的标签
@property(nonatomic, strong, readonly) NSArray<NSString *> *tags;
@end

@interface V2NIMChatroomMessageRevokeNotificationAttachment: V2NIMChatroomNotificationAttachment
/// 消息撤回 ID
/// 通知类型：323， 包括消息客户端ID和时间
@property(nonatomic, strong, readonly) NSString *messageClientId;
/// 消息撤回时间
/// 通知类型：323， 包括消息客户端ID和时间
@property(nonatomic, assign, readonly) NSTimeInterval messageTime;
@end

@interface V2NIMChatroomQueueNotificationAttachment: V2NIMChatroomNotificationAttachment
/// 队列变更的内容
/// 通知类型： 320， 可以批量移除该内容
/// 通知类型：324， 多条批量添加
/// 通知类型：317， 单个或多个key变更
@property(nonatomic, strong, readonly) NSArray<V2NIMChatroomQueueElement *> *elements;
/// 队列更新类型
@property(nonatomic, assign, readonly) V2NIMChatroomQueueChangeType queueChangeType;
@end

@interface V2NIMChatroomChatBannedNotificationAttachment: V2NIMChatroomNotificationAttachment
/// 成员是否被禁言
@property(nonatomic, assign, readonly) BOOL chatBanned;
/// 成员是否被临时禁言
@property(nonatomic, assign, readonly) BOOL tempChatBanned;
/// 成员临时禁言时长
/// 时间为0， 表示解除禁言
@property(nonatomic, assign, readonly) NSTimeInterval tempChatBannedDuration;
@end

@interface V2NIMChatroomMemberEnterNotificationAttachment: V2NIMChatroomNotificationAttachment
/// 成员是否被禁言
/// 管理员，普通成员， 普通有客户，相同账号下次再次进入聊天室， 会保留之前设置的状态
@property(nonatomic, assign, readonly) BOOL chatBanned;
/// 成员是否被临时禁言
@property(nonatomic, assign, readonly) BOOL tempChatBanned;
/// 成员临时禁言时长
@property(nonatomic, assign, readonly) NSTimeInterval tempChatBannedDuration;
@end

@interface V2NIMChatroomMemberRoleUpdateAttachment: V2NIMChatroomNotificationAttachment
/// 之前的角色类型
@property(nonatomic, assign, readonly) V2NIMChatroomMemberRole previousRole;
/// 当前的成员信息
@property(nonatomic, strong, readonly) V2NIMChatroomMember *currentMember;
@end

NS_ASSUME_NONNULL_END
