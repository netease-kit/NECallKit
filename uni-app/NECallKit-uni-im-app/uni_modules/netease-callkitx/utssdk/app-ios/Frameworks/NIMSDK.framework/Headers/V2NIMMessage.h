//
//  V2NIMMessage.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMMessageEnum.h"
#import "V2NIMConversationEnum.h"
#import "V2NIMMessageRefer.h"

@protocol V2NIMMessageAttachment;

@class V2NIMMessagePushConfig;

@class V2NIMMessageRobotConfig;
@class V2NIMMessageConfig;
@class V2NIMMessageAntispamConfig;
@class V2NIMMessageRouteConfig;
@class V2NIMMessageAttachment;
@class V2NIMClientAntispamResult;

NS_ASSUME_NONNULL_BEGIN

/// 消息对象
@interface V2NIMMessage : V2NIMMessageRefer <NSCopying>
/// 消息发送者是否是自己
@property(nonatomic,assign,readonly) BOOL isSelf;
/// 附件上传状态
@property(nonatomic,assign,readonly) V2NIMMessageAttachmentUploadState attachmentUploadState;
/// 消息发送状态 可以主动查询 也可以根据回调监听来确认
@property(nonatomic,assign,readonly) V2NIMMessageSendingState sendingState;
/// 类型
@property(nonatomic,assign) V2NIMMessageType messageType;
/// 子类型
@property(nonatomic,assign) NSInteger subType;
/// 文本
@property(nullable,nonatomic,strong) NSString *text;
/// 附件
@property(nullable,nonatomic,strong) V2NIMMessageAttachment *attachment;
/// 服务端扩展信息
@property(nullable,nonatomic,strong) NSString *serverExtension;
/// 客户端本地扩展信息
@property(nullable,nonatomic,strong) NSString *localExtension;
/// 消息相关配置，具体参见每一个字段定义
@property(nullable,nonatomic,strong,readonly) V2NIMMessageConfig *messageConfig;
/// 推送设置
@property(nullable,nonatomic,strong,readonly) V2NIMMessagePushConfig *pushConfig;
/// 路由抄送相关配置
@property(nullable,nonatomic,strong,readonly) V2NIMMessageRouteConfig *routeConfig;
/// 反垃圾相关
@property(nullable,nonatomic,strong,readonly) V2NIMMessageAntispamConfig *antispamConfig;
/// 机器人相关配置
@property(nullable,nonatomic,strong,readonly) V2NIMMessageRobotConfig *robotConfig;
/// Thread消息引用
@property(nullable,nonatomic,strong,readwrite) V2NIMMessageRefer *threadRoot;
/// 回复消息引用
@property(nullable,nonatomic,strong,readonly) V2NIMMessageRefer *threadReply;

@end

/// 消息推送设置
@interface V2NIMMessagePushConfig : NSObject <NSCopying>
/// 是否需要推送消息。YES：需要，NO：不需要，默认YES
@property(nonatomic,assign,readwrite) BOOL pushEnabled;
/// 是否需要推送消息发送者昵称。YES：需要，NO：不需要，默认YES
@property(nonatomic,assign,readwrite) BOOL pushNickEnabled;
/// 推送文本
@property(nullable,nonatomic,strong,readwrite) NSString *pushContent;
/// 推送数据
@property(nullable,nonatomic,strong,readwrite) NSString *pushPayload;
/// 是否强制推送，忽略用户消息提醒相关设置
@property(nonatomic,assign,readwrite) BOOL forcePush;
/// 强制推送文案，只消息类型有效
@property(nullable,nonatomic,strong,readwrite) NSString *forcePushContent;
/// 强制推送目标账号列表
@property(nullable,nonatomic,strong,readwrite) NSArray<NSString *> *forcePushAccountIds;

@end

/// 消息配置
@interface V2NIMMessageConfig : NSObject <NSCopying>
/// 是否不需要群消息已读回执信息。YES：需要，NO：不需要，默认为NO
@property(nonatomic,assign,readwrite) BOOL readReceiptEnabled;
/// 是否需要更新消息所属的会话信息。YES：需要，NO：不需要，默认为NO
@property(nonatomic,assign,readwrite) BOOL lastMessageUpdateEnabled;
/// 是否需要在服务端保存历史消息。YES：需要，NO：不需要，默认NO
@property(nonatomic,assign,readwrite) BOOL historyEnabled;
/// 是否需要漫游消息。YES：需要，NO：不需要，默认NO
@property(nonatomic,assign,readwrite) BOOL roamingEnabled;
/// 是否需要发送方多端在线同步消息。YES：需要，NO：不需要，默认NO
@property(nonatomic,assign,readwrite) BOOL onlineSyncEnabled;
/// 是否需要存离线消息。YES：需要，NO：不需要，默认NO
@property(nonatomic,assign,readwrite) BOOL offlineEnabled;
/// 是否需要计未读。YES：需要，NO：不需要，默认NO
@property(nonatomic,assign,readwrite) BOOL unreadEnabled;
@end

@interface V2NIMMessageRouteConfig : NSObject <NSCopying>
/// 是否需要路由消息。YES：需要，NO：不需要，默认YES
@property(nonatomic,assign,readwrite) BOOL routeEnabled;
/// 环境变量，用于指向不同的抄送，第三方回调等配置
@property(nullable,nonatomic,strong,readwrite) NSString *routeEnvironment;
@end

/// 消息反垃圾设置
@interface V2NIMMessageAntispamConfig : NSObject <NSCopying>
/// 指定是否需要过安全通（对于已开通安全通的用户有效，默认消息都会走安全通，如果对单条消息设置 enable 为false，则此消息不会走安全通）。
/// true：需要，
/// false：不需要
/// 该字段为true，其他字段才生效
@property(nonatomic, assign, readwrite) BOOL antispamEnabled;
/// 指定易盾业务id，而不使用云信后台配置的
@property(nullable,nonatomic,strong,readwrite) NSString *antispamBusinessId;
/// 自定义消息中需要反垃圾的内容（仅当消息类型为自定义消息时有效）
@property(nullable,nonatomic,strong,readwrite) NSString *antispamCustomMessage;
/// 易盾反作弊（辅助检测数据），json格式，限制长度1024
@property(nullable,nonatomic,strong,readwrite) NSString *antispamCheating;
/// 易盾反垃圾（增强检测数据），json格式，限制长度1024
@property(nullable,nonatomic,strong,readwrite) NSString *antispamExtension;
@end

@interface V2NIMMessageRobotConfig : NSObject<NSCopying>
/// 机器人账号，对应控制台提前设置好的机器人
/// 仅在群聊中有效，点对点聊天室中该字段会被忽略
@property(nullable,nonatomic,strong,readwrite) NSString *accountId;
/// 机器人消息话题
@property(nullable,nonatomic,strong,readwrite) NSString *topic;
/// 机器人具体功能
@property(nullable,nonatomic,strong,readwrite) NSString *function;
/// 机器人自定义内容
@property(nullable,nonatomic,strong,readwrite) NSString *customContent;

@end

/// 消息发送相关参数
@interface V2NIMSendMessageParams : NSObject<NSCopying>
/// 消息相关配置
@property(nonatomic,strong,readwrite) V2NIMMessageConfig *messageConfig;
/// 路由抄送相关配置
@property(nonatomic,strong,readwrite) V2NIMMessageRouteConfig *routeConfig;
/// 推送相关配置
@property(nonatomic,strong,readwrite) V2NIMMessagePushConfig *pushConfig;
/// 反垃圾相关配置
@property(nonatomic,strong,readwrite) V2NIMMessageAntispamConfig *antispamConfig;
/// 机器人相关配置
@property(nonatomic,strong,readwrite) V2NIMMessageRobotConfig *robotConfig;
///是否启用本地反垃圾
///只针对文本消息生效
///发送消息时候，如果改字段为true，文本消息则走本地反垃圾检测，检测后返回V2NIMMessageClientAntispamOperatorType，
///返回0，直接发送该消息
///返回1，发送替换后的文本消息
///返回2，消息发送失败， 返回本地错误码
///返回3，消息正常发送，由服务端拦截
@property(nonatomic, assign, readwrite) BOOL clientAntispamEnabled;
/// 反垃圾命中后替换的文本
@property(nullable,nonatomic,strong,readwrite) NSString *clientAntispamReplace;


@end

/// 发送消息结果
@interface V2NIMSendMessageResult : NSObject
/// 发送成功后的消息体
@property(nullable,nonatomic,strong,readonly) V2NIMMessage *message;
/// 反垃圾返回的结果
@property(nullable,nonatomic,strong,readonly) NSString *antispamResult;
/// 客户端本地反垃圾结果
@property(nullable,nonatomic,strong,readonly) V2NIMClientAntispamResult *clientAntispamResult;
@end

/// 消息发送相关参数
@interface V2NIMMessageListOption : NSObject<NSCopying>
/// 消息所属会话ID 由senderId, conversiationType， receiverId拼装而成 [必填]
@property(nonatomic,strong) NSString *conversationId;
/// 根据消息类型查询会话， 为null或空列表， 则表示查询所有消息类型 [选填]
/// @see V2NIMMessageType
@property(nullable,nonatomic,strong,readwrite) NSArray *messageTypes;
/// 消息查询开始时间，闭区间 [选填]
@property(nonatomic,assign) NSTimeInterval beginTime;
/// 消息查询结束时间，闭区间 [选填]
@property(nonatomic,assign) NSTimeInterval endTime;
/// 每次查询条数，默认50 最大值100 [选填]
@property(nonatomic,assign) NSUInteger limit;
/// 锚点消息，根据锚点消息查询，不包含该消息 [选填]
@property(nullable,nonatomic,strong) V2NIMMessage *anchorMessage;
/// 消息查询方向，如果其它参数都不填 [选填]
/// 如果查询older， 则beginTime默认为long.maxValue，否则以beginTime向老查询
/// 如果查询newer， 则beginTime默认为0, 否则以beginTime开始向最新查询
@property(nonatomic,assign) V2NIMQueryDirection direction;
/// 严格模式，默认为NO [选填]
/// true：如果无法确定消息完整性，则返回错误
/// false：如果无法确定消息完整性，从数据库中查询并返回
@property (nonatomic, assign) BOOL strictMode;

@end

/// 消息发送相关参数
@interface V2NIMClearHistoryMessageOption : NSObject<NSCopying>
/// 需要清空消息的对应的会话ID
@property(nonatomic,strong,readwrite) NSString *conversationId;
/// 是否同步删除漫游消息，默认删除，该字段只P2P时有效 true：删除 false：保留漫游消息 默认 true
@property(nonatomic,assign,readwrite) BOOL deleteRoam;
/// 是否多端同步，默认不同步 true：同步到其它端 false：不同步V2NIMSendMessageParam
@property(nonatomic,assign,readwrite) BOOL onlineSync;
/// 扩展字段，多端同步时会同步到其它端
@property(nonatomic,strong,readwrite) NSString *serverExtension;

@end

NS_ASSUME_NONNULL_END
