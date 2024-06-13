//
//  NIMQChatMessage.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "NIMMessage.h"

@class NIMQChatMessageRefer;
@class NIMQChatMessageAntispamSetting;
@class NIMQChatMessageAntispamResult;
@class NIMQChatMessageUpdateContent;
@class NIMQChatMessageUpdateOperatorInfo;
NS_ASSUME_NONNULL_BEGIN

/**
 *  消息处理状态
 */
typedef NS_ENUM(NSInteger, NIMQChatMessageStatus) {
    /**
     *  初始状态
     *  @discussion
     */
    NIMQChatMessageStatusInit          =   0,

    /**
     *  已撤回
     *  @discussion
     */
    NIMQChatMessageStatusRevoked       =   1,
    
    /**
     *  已删除
     *  @discussion
     */
    NIMQChatMessageStatusDeleted       =   2,

    /**
     *  自定义
     *  @discussion 自定义状态值必须大于10000
     */
    NIMQChatMessageStatusCustom        =   10000,
};

/**
 *  消息引用类型
 */
typedef NS_ENUM(NSInteger, NIMQChatMessageReferType) {
    /**
     *  回复的
     *  @discussion
     */
    NIMQChatMessageReferTypeReply       =   1,
    
    /**
     *  Thread
     *  @discussion
     */
    NIMQChatMessageReferTypeThread      =   2,

    /**
     *  所有
     *  @discussion
     */
    NIMQChatMessageReferTypeAll         =   3,
};

/**
 *  消息结构
 */
@interface NIMQChatMessage : NSObject

/**
 *  消息类型
 */
@property (nonatomic,assign,readonly)               NIMMessageType messageType;

/**
 *  消息所属会话
 */
@property (nullable,nonatomic,copy,readonly)        NIMSession *session;

/**
 *  消息ID,唯一标识
 */
@property (nonatomic,copy,readonly)                 NSString *messageId;

/**
 *  消息服务端ID
 */
@property (nonatomic,copy,readonly)                 NSString *serverID;

/**
 *  消息文本
 *  @discussion 所有消息类型都支持
 */
@property (nullable,nonatomic,copy)                 NSString *text;

/**
 *  消息附件内容
 */
@property (nullable,nonatomic,strong)               id<NIMMessageObject> messageObject;

/**
 *  消息附件原始字符串内容
 */
@property (nullable, nonatomic, copy, readonly)                NSString *rawAttachContent;

/**
 *  消息设置
 *  @discussion 可以通过这个字段制定当前消息的各种设置
 */
@property (nullable,nonatomic,strong)               NIMMessageSetting *setting;

/**
 *  消息推送文案,长度限制500字,撤回消息时该字段无效
 */
@property (nullable,nonatomic,copy)                 NSString *apnsContent;

/**
 *  消息推送Payload
 *  @discussion 可以通过这个字段定义消息推送 Payload ,支持字段参考苹果技术文档,长度限制 2K,撤回消息时该字段无效
 */
@property (nullable,nonatomic,copy)                 NSDictionary *apnsPayload;

/**
 *  服务器扩展
 *  @discussion 客户端可以设置这个字段,这个字段将在本地存储且发送至对端,上层需要保证 NSDictionary 可以转换为 JSON，长度限制 1K
 */
@property (nullable,nonatomic,copy)                 NSDictionary *remoteExt;

/**
 *  客户端本地扩展
 *  @discussion 客户端可以设置这个字段，这个字段只在本地存储,不会发送至对端,上层需要保证 NSDictionary 可以转换为 JSON
 */
@property (nullable,nonatomic,copy)                 NSDictionary *localExt;

/**
 *  消息发送时间
 *  @discussion 发送成功后将被服务器自动修正
 */
@property (nonatomic,assign)                        NSTimeInterval timestamp;

/**
 *  消息投递状态 仅针对发送的消息
 */
@property (nonatomic,assign,readonly)               NIMMessageDeliveryState deliveryState;

/**
 *  消息附件下载状态 仅针对收到的消息
 */
@property (nonatomic,assign,readonly)               NIMMessageAttachmentDownloadState attachmentDownloadState;

/**
 *  是否是收到的消息
 *  @discussion
 */
@property (nonatomic,assign,readonly)               BOOL isReceivedMsg;

/**
 *  是否是往外发的消息
 *  @discussion
 */
@property (nonatomic,assign,readonly)               BOOL isOutgoingMsg;

/**
 *  消息是否标记为已删除
 *  @discussion
 */
@property (nonatomic,assign,readonly)               BOOL isDeleted;

/**
 *  消息是否标记为已撤回
 *  @discussion
 */
@property (nonatomic,assign,readonly)               BOOL isRevoked;

/**
 *  消息处理状态
 */
@property (nonatomic,assign)                        NIMQChatMessageStatus status;

/**
 *  消息来源
 */
@property (nullable,nonatomic,copy)                 NSString *from;

/**
 *  消息发送者名字
 *  @discussion
 */
@property (nullable,nonatomic,copy,readonly)        NSString *senderName;

/**
 *  发送者客户端类型
 */
@property (nonatomic,assign,readonly)               NIMLoginClientType senderClientType;

/**
 * 圈组频道ID
 */
@property (nonatomic,readonly)                      unsigned long long qchatChannelId;

/**
 * 圈组服务器ID
 */
@property (nonatomic,readonly)                      unsigned long long qchatServerId;

/**
 *  是否艾特所有人
 *  @discussion
 */
@property(nonatomic, assign) BOOL mentionedAll;

/**
 *  被艾特的人的accid列表
 *  @discussion
 */
@property(nonatomic, copy) NSArray<NSString *> *mentionedAccids;

/**
 *  被艾特的身份组的ID列表
 *  @discussion
 */
@property(nonatomic, copy) NSArray<NSNumber *> *mentionedRoleidList;

/**
 *  消息更新时间
 *  @discussion
 */
@property(nonatomic, assign) NSTimeInterval updateTimestamp;


/**
*  环境变量
*  @discussion 环境变量，用于指向不同的抄送、第三方回调等配置
*/
@property (nullable,nonatomic,copy) NSString *env;

/**
 *  回复消息引用
 *  @discussion
 */
@property(nullable, nonatomic, copy, readonly) NIMQChatMessageRefer *replyRefer;

/**
 *  thread消息引用
 *  @discussion
 */
@property(nullable, nonatomic, copy, readonly) NIMQChatMessageRefer *threadRefer;

/**
 *  是否来自缓存
 *  @discussion
 */
@property (nonatomic,assign,readonly)               BOOL fromCache;

/**
 * 易盾反垃圾设置
 */
@property (nullable, nonatomic, copy) NIMQChatMessageAntispamSetting *yidunAntiSpamSetting;

/**
 * 易盾反垃圾返回的结果字段
 */
@property (nullable, nonatomic, copy) NIMQChatMessageAntispamResult *yidunAntiSpamResult;

/**
 *  第三方回调回来的自定义扩展字段
 */
@property (nonatomic,copy,readonly) NSString *callbackExt;

/**
 *  消息更新内容
 *  @discussion 如果是更新的消息，里面有具体更新内容
 */
@property (nullable, nonatomic, strong) NIMQChatMessageUpdateContent *updateContent;

/**
 *  消息更新操作信息
 *  @discussion 如果是更新的消息，里面有具体操作信息
 */
@property (nullable, nonatomic, strong) NIMQChatMessageUpdateOperatorInfo *updateOperatorInfo;

/**
 *  消息子类型,  大于0的int NSNumber包装值
 */
@property (nonatomic, strong) NSNumber *subType;

@end

NS_ASSUME_NONNULL_END
