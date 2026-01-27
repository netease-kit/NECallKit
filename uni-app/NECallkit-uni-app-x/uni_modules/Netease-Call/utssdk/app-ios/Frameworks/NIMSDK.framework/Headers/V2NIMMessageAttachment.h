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
@class V2NIMUpdatedTeamInfo;

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
/// 群信息更新字段
@property(nullable,nonatomic,strong) V2NIMUpdatedTeamInfo *updatedTeamInfo;
@end


@interface V2NIMMessageCallDuration : NSObject
// 话单对应成员的账号ID
@property(nullable,nonatomic,strong) NSString *accountId;
// 通话时长
@property(nonatomic,assign) NSInteger duration;
@end

/// 话单附件
@interface V2NIMMessageCallAttachment : V2NIMMessageAttachment

/**
 * 话单类型， 业务自定义，内容不校验
 * 建议：
 * 音频：1
 * 视频：2
 */
@property (nonatomic, assign) NSInteger type;

/**
 话单频道ID， 内容不校验
 */
@property (nonatomic, copy) NSString *channelId;

/**
 * 通话状态，业务自定义状态， 内容不校验
 * 建议：
 * 通话完成：1
 * 通话取消：2
 * 通话拒绝：3
 * 超时未接听：4
 * 对方忙： 5
 */
@property (nonatomic, assign) NSInteger status;

/**
 通话成员时长列表， 内容不校验
 */
@property (nonatomic, copy) NSArray<V2NIMMessageCallDuration *>*durations;

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

///自定义消息附件解析器
@protocol V2NIMMessageCustomAttachmentParser <NSObject>

@required
/**
 * @param subType 自定义消息子类型
 * @param attach  自定义消息附件内容
 *
 */
- (nullable id)parse:(int)subType attach:(NSString *)attach;

@end

/**
 * 自定义消息附件 必须给raw赋值
 * 用户自定义消息不同类型附件可以继承自该类型，可以采用subtype区分
 *
 */

@interface V2NIMMessageCustomAttachment : V2NIMMessageAttachment

/**
 * ///overwrite
 * @param attach 解析的附件内容
 *
 */
- (void)parse:(NSString *)attach;

@end




NS_ASSUME_NONNULL_END
