//
//  V2NIMMessageAttachment.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMMessage;

/// 消息附件协议
@interface V2NIMMessageAttachment: NSObject
/// 消息对象
@property(nonnull,nonatomic,strong) NSString *raw;

@end

/// 消息文件附件
@interface V2NIMMessageFileAttachment : V2NIMMessageAttachment
/// 文件本地路径
@property(nullable,nonatomic,strong) NSString *path;
/// 文件数据大小
@property(nonatomic,assign) NSUInteger size;
/// 文件数据md5
@property(nonnull,nonatomic,strong) NSString *md5;
/// 文件上传服务器路径
@property(nullable,nonatomic,strong,readonly) NSString *url;
/// 文件类型
@property(nullable,nonatomic,strong) NSString *ext;
/// 文件显示名称
@property(nonnull,nonatomic,copy) NSString *name;
/// 文件存储场景 自定义场景使用之前， 需要先调用V2NIMStorageService.addCustomStorageScene新增自定义场景值
/// 传默认使用：V2NIMStorageSceneConfig.DEFAULT_IM
@property(nullable,nonatomic,strong) NSString *sceneName;
/// 上传状态
@property(nonatomic,assign) V2NIMMessageAttachmentUploadState uploadState;

@end

/// 图片附件对象
@interface V2NIMMessageImageAttachment : V2NIMMessageFileAttachment
/// 图片宽度
@property(nonatomic,assign,readonly) int width;
/// 图片高度
@property(nonatomic,assign,readonly) int height;
@end

/// 语音附件对象
@interface V2NIMMessageAudioAttachment : V2NIMMessageFileAttachment
/// 语音文件播放时长
@property(nonatomic,assign,readwrite) NSUInteger duration;

@end

/// 视频附件对象
@interface V2NIMMessageVideoAttachment : V2NIMMessageFileAttachment
/// 视频文件播放时长
@property(nonatomic,assign) NSUInteger duration;
/// 视频宽度
@property(nonatomic,assign) NSInteger width;
/// 视频高度
@property(nonatomic,assign) NSInteger height;
@end

/// 消息地理位置附件
@interface V2NIMMessageLocationAttachment : V2NIMMessageAttachment
/// 经度
@property(nonatomic,assign) double longitude;
/// 纬度
@property(nonatomic,assign) double latitude;
/// 详细位置信息
@property(nonnull,nonatomic,strong) NSString *address;

@end

/// 通知附件对象
@interface V2NIMMessageNotificationAttachment : V2NIMMessageAttachment
/// 通知类型
@property(nonatomic,assign) V2NIMMessageNotificationType type;
/// 扩展字段
@property(nullable,nonatomic,strong) NSString *serverExtension;
/// 被操作者ID列表
@property(nullable,nonatomic,strong) NSArray<NSString *> *targetIds;
/// 群成员是否被禁言
@property(nonatomic,assign) BOOL chatBanned;
@end

/// 消息提醒附件
@interface V2NIMMessageTipsAttachment : V2NIMMessageAttachment

/// 第三方回调回来的自定义扩展字段
@property(nullable,nonatomic,copy,readonly) NSString *callbackExtension;

@end

/// 消息机器人附件
@interface V2NIMMessageRobotAttachment : V2NIMMessageAttachment
/**
 *  当该消息为用户上行发送给机器人时，此字段为目标机器人 Id,
 *  当该消息为机器人回复的消息时, 此字段为本消息所属机器人 Id
 */
@property (nullable, nonatomic, copy, readonly) NSString *robotId;
/**
 *  机器人回复的消息结果，只在机器人下行消息，此字段有效
 */
@property (nullable, nonatomic, copy, readonly) NSDictionary *response;

/**
 *  机器人回复的消息所属的提问消息 Id ，只在机器人下行消息，此字段有效
 */
@property (nullable, nonatomic, copy, readonly) NSString *responseForMessageId;
@end

/// 消息话单附件
@interface V2NIMMessageCallAttachment : V2NIMMessageAttachment

@end

NS_ASSUME_NONNULL_END
