//
//  NIMQChatSystemNotification.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@class NIMQChatSystemNotificationSetting;
@protocol NIMQChatSystemNotificationAttachment;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NIMQChatSystemNotificationStatus) {
    /**
     * 正常状态
     */
    NIMQChatSystemNotificationStatusNormal = 0,
};

/**
 * 圈组系统消息
 */
@interface NIMQChatSystemNotification : NSObject <NSCopying>

/**
 * 目标
 */
@property(nonatomic, assign, readonly) NIMQChatSystemNotificationToType toType;

/**
 * 消息所属的服务器ID
 */
@property(nonatomic, assign, readonly) unsigned long long serverId;

/**
 * 消息所属的频道ID
 */
@property(nonatomic, assign, readonly) unsigned long long channelId;

/**
 * 消息接收者的账号列表
 */
@property(nullable, nonatomic, copy, readonly) NSArray<NSString *> *toAccids;

/**
 * 消息发送者的accid
 */
@property(nullable, nonatomic, copy) NSString *fromAccount;

/**
 * 消息发送者这的客户端类型
 */
@property(nonatomic, assign) NSInteger fromClientType;

/**
 * 发送设备id
 */
@property(nullable, nonatomic, copy) NSString *fromDeviceId;

/**
 * 发送方昵称
 */
@property(nullable, nonatomic, copy) NSString *fromNick;

/**
 * 消息发送时间
 */
@property(nonatomic, assign) NSTimeInterval time;

/**
 * 消息更新时间，可以更新body/attach/ext三个字段
 */
@property(nonatomic, assign) NSTimeInterval updateTime;


/**
 * 系统通知类型
 */
@property(nonatomic, assign) NIMQChatSystemNotificationType type;

/**
 * 客户端生成的消息id, 会用于去重
 */
@property(nullable, nonatomic, copy) NSString *messageClientId;

/**
 * 服务端生成的消息id，全局唯一
 */
@property(nonatomic, assign) unsigned long long messageServerID;

/**
 * 通知内容
 */
@property(nullable, nonatomic, copy) NSString *body;

/**
 * 系统通知附件
 */
@property(nullable, nonatomic, copy) id<NIMQChatSystemNotificationAttachment> attach;

/**
 * 系统通知自定义扩展字段，推荐使用json格式
 */
@property(nullable, nonatomic, copy) NSString *ext;

/**
 * 系统通知状态
 */
@property(nonatomic, assign) NSInteger status;


/**
 * 第三方自定义的推送属性，限制json
 */
@property(nullable, nonatomic, copy) NSString *pushPayload;

/**
 * 自定义推送文案
 */
@property(nullable, nonatomic, copy) NSString *pushContent;

/**
 *  自定义系统通知设置
 *  @discussion 可以通过这个字段制定当前通知的各种设置,如是否需要计入推送未读，是否需要带推送前缀等等
 */
@property(nullable, nonatomic, copy) NIMQChatSystemNotificationSetting *setting;

/**
 *  环境变量
 */
@property (nullable, nonatomic, copy) NSString *env;

/**
 *  第三方回调回来的自定义扩展字段
 */
@property (nullable, nonatomic, copy) NSString *callbackExt;

@end

NS_ASSUME_NONNULL_END
