//
//  V2NIMChatroomMessage.h
//  NIMSDK
//
//  Created by 陈吉力 on 2023/11/15.
//  Copyright © 2023 Netease. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "V2NIMMessageAttachment.h"
#import "V2NIMMessage.h"
#import "V2NIMLocationInfo.h"

NS_ASSUME_NONNULL_BEGIN

/// 聊天室消息相关配置
@interface V2NIMChatroomMessageConfig : NSObject <NSCopying>
/// 是否需要在服务端保存历史消息。YES：需要，NO：不需要，默认YES
@property(nonatomic,assign,readwrite) BOOL historyEnabled;
/// 是否是高优先级消息。true：是；false：不是。
/// 在超频情况下，默认先流控低优先级消息
@property(nonatomic,assign,readwrite) BOOL highPriority;
@end

/// 消息发送时配置的用户信息
@interface V2NIMUserInfoConfig : NSObject <NSCopying>

/// 消息发送者uinfo的最后更新时间
@property(nonatomic, assign, readwrite) NSTimeInterval userInfoTimestamp;

/// 发送方昵称
@property(nullable, nonatomic, strong, readwrite) NSString *senderNick;

/// 发送者头像
@property(nullable, nonatomic, strong, readwrite) NSString *senderAvatar;

/// 发送者扩展字段
@property(nullable, nonatomic, strong, readwrite) NSString *senderExtension;

@end

// https://docs.popo.netease.com/team/pc/nim/pageDetail/661e8e21fcb844f683ebcc72c023295c?xyz=1700452285591
/// 消息对象
@interface V2NIMChatroomMessage : NSObject<NSCopying>
/// 客户端消息id
@property(nullable,nonatomic,strong,readonly) NSString *messageClientId;
/// 消息发送方客户端类型， 服务器回填字段
@property(nonatomic,assign,readonly) NSInteger senderClientType;
/// 消息时间，服务器器时间
/// 在发送成功之前，时间为发送者本地时间
@property(nonatomic,assign,readonly) NSTimeInterval createTime;
/// 发送方账号id
@property(nullable,nonatomic,strong,readonly) NSString *senderId;
/// 消息接收者账号
@property(nullable,nonatomic,strong,readonly) NSString *roomId;
/// 消息发送者是否是自己
@property(nonatomic,assign,readonly) BOOL isSelf;
/// 附件上传状态
@property(nonatomic,assign,readonly) V2NIMMessageAttachmentUploadState attachmentUploadState;
/// 消息发送状态 可以主动查询 也可以根据回调监听来确认
@property(nonatomic,assign,readonly) V2NIMMessageSendingState sendingState;
/// 类型
@property(nonatomic,assign,readonly) V2NIMMessageType messageType;
/// 子类型
@property(nonatomic,assign) NSInteger subType;
/// 文本
@property(nullable,nonatomic,strong) NSString *text;
/// 附件
@property(nullable,nonatomic,strong) V2NIMMessageAttachment *attachment;
/// 服务端扩展信息
@property(nullable,nonatomic,strong) NSString *serverExtension;
/// 第三方回调扩展字段， 透传字段最长2048
@property(nullable,nonatomic,strong,readonly) NSString *callbackExtension;
/// 路由抄送相关配置
@property(nullable,nonatomic,strong,readonly) V2NIMMessageRouteConfig *routeConfig;
/// 反垃圾相关
@property(nullable,nonatomic,strong,readonly) V2NIMMessageAntispamConfig *antispamConfig;
/// 消息的目标标签表达式. 格式:https://doc.commsease.com/messaging/docs/TMxOTI0MDA?platform=android#%E6%A0%87%E7%AD%BE%E8%A1%A8%E8%BE%BE%E5%BC%8F
@property(nullable,nonatomic,strong) NSString *notifyTargetTags;
/// 聊天室消息配置
@property(nullable,nonatomic,strong,readonly) V2NIMChatroomMessageConfig *messageConfig;
/// 消息发送时用户信息配置
@property(nullable,nonatomic,strong) V2NIMUserInfoConfig *userInfoConfig;
/// 消息空间坐标信息配置
@property(nullable,nonatomic,strong) V2NIMLocationInfo *locationInfo;
@end

/// 发送聊天室消息相关配置
@interface V2NIMSendChatroomMessageParams : NSObject
/// 消息相关配置
@property(nullable, nonatomic, strong, readwrite) V2NIMChatroomMessageConfig *messageConfig;
/// 路由抄送相关配置
@property(nullable, nonatomic, strong, readwrite) V2NIMMessageRouteConfig *routeConfig;
/// 反垃圾相关配置
@property(nullable, nonatomic, strong, readwrite) V2NIMMessageAntispamConfig *antispamConfig;
/// 是否启用本地反垃圾
////// 只针对文本消息生效
////// 发送消息时候，如果该字段为true，文本消息则走本地反垃圾检测，检测后返回V2NIMClientAntispamOperateType，
////// 返回0，直接发送该消息
////// 返回1，发送替换后的文本消息
////// 返回2，消息发送失败， 返回本地错误码
////// 返回3，消息正常发送，由服务端拦截
@property(nonatomic, assign, readwrite) BOOL clientAntispamEnabled;
/// 反垃圾命中后替换的文本
////// clientAntispamEnabled为true， 且需要替换时必填
@property(nullable, nonatomic, strong, readwrite) NSString *clientAntispamReplace;
/// 如果receiverIds不为空，表示为聊天室定向消息， 设置该字段后， 会忽略消息配置中的history_enabled配置， 消息不存历史
@property(nullable, nonatomic, strong, readwrite) NSArray *receiverIds;
/// 消息的目标标签表达式， 标签表达式
////// https://doc.commsease.com/messaging/docs/TMxOTI0MDA?platform=android#%E6%A0%87%E7%AD%BE%E8%A1%A8%E8%BE%BE%E5%BC%8F
@property(nullable, nonatomic, strong, readwrite) NSString *notifyTargetTags;
/// 消息空间坐标信息配置
@property(nullable, nonatomic, strong, readwrite) V2NIMLocationInfo *locationInfo;

@end

@interface V2NIMSendChatroomMessageResult: NSObject <NSCopying>
/// 发送成功后的消息体
@property(nullable,nonatomic,strong,readonly) V2NIMChatroomMessage *message;
/// 反垃圾返回的结果
@property(nullable,nonatomic,strong,readonly) NSString *antispamResult;
/// 客户端本地反垃圾结果
@property(nullable,nonatomic,strong,readonly) V2NIMClientAntispamResult *clientAntispamResult;
@end
NS_ASSUME_NONNULL_END
