//
//  V2NIMMessageEnum.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 消息类型
typedef NS_ENUM(NSInteger, V2NIMMessageType) {
    V2NIM_MESSAGE_TYPE_INVALID                                = -1,  ///< 未知， 不合法
    V2NIM_MESSAGE_TYPE_TEXT                                   = 0,  ///< 文本
    V2NIM_MESSAGE_TYPE_IMAGE                                  = 1,  ///< 图片
    V2NIM_MESSAGE_TYPE_AUDIO                                  = 2,  ///< 语音
    V2NIM_MESSAGE_TYPE_VIDEO                                  = 3,  ///< 视频
    V2NIM_MESSAGE_TYPE_LOCATION                               = 4,  ///< 地理位置
    V2NIM_MESSAGE_TYPE_NOTIFICATION                           = 5,  ///< 通知
    V2NIM_MESSAGE_TYPE_FILE                                   = 6,  ///< 文件
    V2NIM_MESSAGE_TYPE_AVCHAT                                 = 7,  ///<音视频通话
    V2NIM_MESSAGE_TYPE_TIP                                    = 10,  ///< 提醒
    V2NIM_MESSAGE_TYPE_ROBOT                                  = 11,  ///< 机器人
    V2NIM_MESSAGE_TYPE_CALL                                   = 12,  ///< 话单
    V2NIM_MESSAGE_TYPE_CUSTOM                                 = 100,  ///< 自定义
};


/// 通知类型
typedef NS_ENUM(NSInteger, V2NIMMessageNotificationType){
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_INVITE                 = 0, ///< 群拉人
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_KICK                   = 1, ///< 群踢人
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_LAVE                   = 2, ///< 退出群
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_UPDATE_TINFO           = 3, ///< 更新群信息
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_DISMISS                = 4, ///< 群解散
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_APPLY_PASS             = 5, ///< 群申请加入通过
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_OWNER_TRANSFER         = 6, ///< 移交群主
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_ADD_MANAGER            = 7, ///< 添加管理员
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_REMOVE_MANAGER         = 8, ///< 移除管理员
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_INVITE_ACCEPT          = 9, ///< 接受邀请进群
    V2NIM_MESSAGE_NOTIFICATION_TYPE_TEAM_BANNED_TEAM_MEMBER     = 10 ///< 禁言群成员
};

/// 消息状态
typedef NS_ENUM(NSInteger, V2NIMMessageState) {
    V2NIM_MESSAGE_STATE_DEFAULT                               = 0,  ///< 默认
    V2NIM_MESSAGE_STATE_DELETED                               = 1,  ///< 已删除
    V2NIM_MESSAGE_STATE_REVOKED                               = 2,  ///< 已撤回
};

/// 消息发送状态
typedef NS_ENUM(NSInteger, V2NIMMessageSendingState) {
    V2NIM_MESSAGE_SENDING_STATE_UNKNOWN                          = 0,  ///< 未知
    V2NIM_MESSAGE_SENDING_STATE_SUCCEEDED                        = 1,  ///< 发送成功
    V2NIM_MESSAGE_SENDING_STATE_FAILED                           = 2,  ///< 发送失败
    V2NIM_MESSAGE_SENDING_STATE_SENDING                          = 3,  ///< 发送中
};

/// 消息附件上传状态
typedef NS_ENUM(NSInteger, V2NIMMessageAttachmentUploadState) {
    V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_UNKNOWN             = 0,  ///< 未知
    V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_SUCCEED             = 1,  ///< 上传成功
    V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_FAILED              = 2,  ///< 上传失败
    V2NIM_MESSAGE_ATTACHMENT_UPLOAD_STATE_UPLOADING           = 3,  ///< 上传中
};

/// 消息附件下载状态
typedef NS_ENUM(NSInteger, V2NIMMessageAttachmentDownloadState) {
    V2NIM_MESSAGE_ATTACHMENT_DOWNLOAD_STATE_UNKNOWN           = 0,  ///< 未知
    V2NIM_MESSAGE_ATTACHMENT_DOWNLOAD_STATE_SUCCEED           = 1,  ///< 下载成功
    V2NIM_MESSAGE_ATTACHMENT_DOWNLOAD_STATE_FAILED            = 2,  ///< 下载失败
    V2NIM_MESSAGE_ATTACHMENT_DOWNLOAD_STATE_DOWNLOADING       = 3,  ///< 下载中
};

/// 消息查询方向
typedef NS_ENUM(NSInteger, V2NIMQueryDirection) {
    V2NIM_QUERY_DIRECTION_DESC                           = 0,  ///< 按时间戳从大到小查询
    V2NIM_QUERY_DIRECTION_ASC                            = 1,  ///< 按时间戳从小到大查询
};


/// 消息查询方向
typedef NS_ENUM(NSInteger, V2NIMClientAntispamOperateType) {
    V2NIM_CLIENT_ANTISPAM_OPERATOR_NONE                 = 0,  ///< 无操作
    V2NIM_CLIENT_ANTISPAM_OPERATOR_REPLACE              = 1,  ///< 命中后，本地替换
    V2NIM_CLIENT_ANTISPAM_OPERATOR_CLIENT_SHIELD        = 2,  ///< 命中后，本地屏蔽，该消息拒绝发送
    V2NIM_CLIENT_ANTISPAM_OPERATOR_SERVER_SHIELD        = 3   ///< 命中后，消息可以发送，由服务器屏蔽
};

/// 消息撤回类型
typedef NS_ENUM(NSUInteger, V2NIMMessageRevokeType){
    V2NIM_MESSAGE_REOKE_TYPE_UNDEFINED          = 0,    ///< 未定义
    V2NIM_MESSAGE_REOKE_TYPE_P2P_BOTHWAY        = 1,    ///< 点对点双向撤回
    V2NIM_MESSAGE_REOKE_TYPE_TEAM_BOTHWAY       = 2,    ///< 群双向撤回
    V2NIM_MESSAGE_REOKE_TYPE_SUPER_TEAM_BOTHWAY = 3,   ///< 超大群双向撤回
    V2NIM_MESSAGE_REOKE_TYPE_P2P_ONEWAY         = 4,   ///< 点对点单向撤回
    V2NIM_MESSAGE_REOKE_TYPE_TEAM_ONEWAY        = 5    ///< 群单向撤回
};

/// 消息撤回类型
typedef NS_ENUM(NSUInteger, V2NIMMessagePinState){
    V2NIM_MESSAGE_PIN_STEATE_NOT_PINNED    = 0,    ///< 未pin
    V2NIM_MESSAGE_PIN_STEATE_PINNED        = 1,    ///< 已PIN
    V2NIM_MESSAGE_PIN_STEATE_UPDATED       = 2,    ///< 已PIN状态更新
};

typedef NS_ENUM(NSUInteger, V2NIMMessageQuickCommentType){
    V2NIM_MESSAGE_QUICK_COMMENT_STATE_ADD           = 1,    ///< 添加
    V2NIM_MESSAGE_QUICK_COMMENT_STATE_REMOVE        = 2,    ///< 删除
};

typedef NS_ENUM(NSUInteger, V2NIMSortOrder){
    V2NIM_SORT_ORDER_DESC           = 0,    ///< 按时间降序排序
    V2NIM_SORT_ORDER_ASC            = 1,    ///< 按时间升序排序
};


NS_ASSUME_NONNULL_END
