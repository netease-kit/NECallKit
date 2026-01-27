//
//  V2NIMMessage.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
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
@class V2NIMAIModelCallContent;
@class V2NIMMessage;
@class V2NIMMessageAIConfig;
@class V2NIMAIModelConfigParams;
@class V2NIMAIModelCallMessage;
@class V2NIMMessageStatus;
@class V2NIMAIRAGInfo;
@class V2NIMMessageAIStreamChunk;
@class V2NIMMessageStreamConfig;
@class V2NIMMessageStreamChunk;

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
/// 服务端扩展信息，必须是Json 字符串，要不然会解析失败。
@property(nullable,nonatomic,strong) NSString *serverExtension;
/// 客户端本地扩展信息
@property(nullable,nonatomic,strong) NSString *localExtension;
/// 第三方回调扩展字段， 透传字段
@property(nullable,nonatomic,strong,readonly) NSString *callbackExtension;
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
/// AI数字人相关信息
@property(nullable,nonatomic,strong,readwrite) V2NIMMessageAIConfig *aiConfig;
/// 消息状态相关
@property(nonnull,nonatomic,strong, readonly) V2NIMMessageStatus *messageStatus;
/// 消息更新时间
@property(nonatomic,assign, readonly) NSTimeInterval modifyTime;
/// 消息更新者账号
@property(nullable,nonatomic,copy, readonly) NSString *modifyAccountId;
/// 流式配置
@property(nullable,nonatomic,strong, readonly) V2NIMMessageStreamConfig *streamConfig;
/// 消息来源
@property(nonatomic,assign,readonly) V2NIMMessageSource messageSource;
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
/// 是否需要群消息已读回执信息。YES：需要，NO：不需要，默认为NO
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


@interface V2NIMMessageAIConfig :  NSObject<NSCopying>
/// 数字人的 accountId
@property(nullable,nonatomic,strong,readwrite) NSString *accountId;

/// 该 AI 消息的询问和应答标识
/// 0 表示普通消息
/// 1 表示是一个艾特数字人的消息
/// 2 表示是数字人响应艾特的消息
/// 响应回参
@property(nonatomic,assign,readwrite) V2NIMMessageAIStatus aiStatus;

/// 数字人回复内容的引用资源列表
@property(nullable,nonatomic,strong,readwrite) NSArray<V2NIMAIRAGInfo *> *aiRAGs;

/// 是否是流式响应，默认NO
@property(nonatomic,assign,readwrite) BOOL aiStream;

/// 数字人流式消息状态。默认V2NIM_MESSAGE_AI_STREAM_STATUS_NONE
@property(nonatomic,assign,readwrite) V2NIMMessageAIStreamStatus aiStreamStatus;

/// 数字人流式消息最近一个分片
/// 注意：流式过程中的消息text是将接收到的分片组装好之后的结果
@property(nullable,nonatomic,strong,readonly) V2NIMMessageAIStreamChunk *aiStreamLastChunk;

@end

@interface V2NIMMessageStreamConfig : NSObject<NSCopying>
/// 流式消息状态
@property(nonatomic,assign,readonly) V2NIMMessageStreamStatus status;
/// 流式消息最近一个分片
/// 流式过程中才有该字段，最终完整消息无此字段
/// 注意：流式过程中的消息text是将接收到的分片组装好之后的结果
@property(nullable,nonatomic,strong,readonly) V2NIMMessageStreamChunk *lastChunk;
/// 数字人回复内容的引用资源列表
@property(nullable,nonatomic,strong,readonly) NSArray<V2NIMAIRAGInfo *> *rags;
@end

@interface V2NIMMessageAIConfigParams : NSObject<NSCopying>
/// 数字人的 accountId
@property(nullable,nonatomic,strong,readwrite) NSString *accountId;

/// 请求大模型的内容
@property(nullable,nonatomic,strong,readwrite) V2NIMAIModelCallContent *content;
/// 上下文内容
/// 当前只支持文本消息
@property(nullable,nonatomic,strong,readwrite) NSArray<V2NIMAIModelCallMessage *> *messages;
/// 提示词变量占位符替换
/// JSON 格式的字符串
/// 用于填充prompt中的变量
@property(nullable,nonatomic,strong,readwrite) NSString *promptVariables;
/// 请求接口模型相关参数配置， 如果参数不为空，则默认覆盖控制相关配置
@property(nullable,nonatomic,strong,readwrite) V2NIMAIModelConfigParams *modelConfigParams;
/// 是否是流式响应，默认NO
@property(nonatomic,assign,readwrite) BOOL aiStream;

@end

/// 引用资源信息类
@interface V2NIMAIRAGInfo : NSObject
/// rag 名称
@property (nonatomic, copy) NSString *name;
/// rag 图标
@property (nonatomic, copy) NSString *icon;
/// 引用资源的title
@property (nonatomic, copy) NSString *title;
/// 引用资源的描述
@property (nonatomic, copy) NSString *desc;
/// 引用资源的时间
@property (nonatomic, assign) NSTimeInterval time;
/// 引用资源的url
@property (nonatomic, copy) NSString *url;
@end

/// 流式消息分片信息
@interface V2NIMMessageAIStreamChunk : NSObject
/// 数字人流式回复分片文本
@property (nonatomic, copy) NSString *content;
/// 数字人流式消息时间，即占位消息时间
@property (nonatomic, assign) NSTimeInterval messageTime;
/// 数字人流式消息当前分片时间
/// chunkTime >= msgTime
@property (nonatomic, assign) NSTimeInterval chunkTime;
/// 类型，当前仅支持0表示文本
@property (nonatomic, assign) NSInteger type;
/// 分片序号，从0开始
@property (nonatomic, assign) NSInteger index;
@end

/// 流式消息分片信息
@interface V2NIMMessageStreamChunk : NSObject
/// 数字人流式回复分片文本
@property (nonatomic, copy) NSString *content;
/// 数字人流式消息时间，即占位消息时间
@property (nonatomic, assign) NSTimeInterval messageTime;
/// 数字人流式消息当前分片时间
/// chunkTime >= msgTime
@property (nonatomic, assign) NSTimeInterval chunkTime;
/// 类型，当前仅支持0表示文本
@property (nonatomic, assign) NSInteger type;
/// 分片序号，从0开始
@property (nonatomic, assign) NSInteger index;
@end

/// 停止数字人流式输出配置参数
@interface V2NIMMessageAIStreamStopParams : NSObject
/// 停止流式消息的操作类型
@property (nonatomic, assign) V2NIMMessageAIStreamStopOpType operationType;
/// 更新的消息内容，仅当operationType == V2NIM_MESSAGE_AI_STREAM_STOP_OP_UPDATE有效
@property (nullable,nonatomic, strong) NSString *updateContent;
@end

/// 重新输出数字人消息配置参数
@interface V2NIMMessageAIRegenParams: NSObject
/// 重新输出数字人消息操作类型
@property (nonatomic,assign,readonly) V2NIMMessageAIRegenOpType operationType;

- (instancetype)initWith:(V2NIMMessageAIRegenOpType)operationType;
@end

/// 用以控制在发送群组消息时，消息是否发送给指定的群组成员
@interface V2NIMMessageTargetConfig : NSObject<NSCopying>
/// 为 true 时表示消息发送到群组中 receiverIds 对应的成员，为 false 时表示消息发送到群组中排除 receiverIds 以外的所有成员。当发送的消息会话类型为超级群时不允许设置该字段为 false
@property(nonatomic,assign,readwrite) BOOL inclusive;
/// 接收者 ID 列表
@property(nonatomic,strong,readwrite) NSArray<NSString *> *receiverIds;
/// 新成员是否可以查看该定向消息
@property(nonatomic,assign,readwrite) BOOL newMemberVisible;
@end

@interface V2NIMMessageStatus : NSObject<NSCopying>
/// 消息发送错误码
/// 客户端回填，以及服务器回填
/// 客户端回填的时候， 发送状态为失败
/// 服务器回填的时候， 发送状态为成功
/// 包括如下情况:
/// 1，本地命中发垃圾拦截
/// 2，本地发送超时
/// 3，服务器AI响应消息由于反垃圾失败返回
/// 4，服务器AI响应消息由于三方回调拦截返回
/// 3，4两种情况服务器默认下发消息类型为tips消息，同时下发消息错误码， 由端上拦截处理上抛界面
/// 5，被对方拉黑发送失败
/// 6，以及其他发送失败情况
@property(nonatomic,assign,readwrite) NSInteger errorCode;

/// 群消息开启已读回执配置， 客户端收到消息后需要发送已读回执请求， 该字段记录是否已经发送过已读回执请求， 避免重复发送
/// 只对群消息有效
@property(nonatomic,assign,readwrite) BOOL readReceiptSent;
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
/// 请求大模型的相关参数
@property(nullable,nonatomic,strong,readwrite) V2NIMMessageAIConfigParams *aiConfig;
/// 群组定向消息
@property(nullable,nonatomic,strong,readwrite) V2NIMMessageTargetConfig *targetConfig;
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
@property(nonatomic,assign) NSInteger limit;
/// 锚点消息，根据锚点消息查询，不包含该消息 [选填]
@property(nullable,nonatomic,strong) V2NIMMessage *anchorMessage;
/// 消息查询方向，如果其它参数都不填 [选填]
/// 如果查询older， 则beginTime默认为long.maxValue，否则以beginTime向老查询
/// 如果查询newer， 则beginTime默认为0, 否则以beginTime开始向最新查询
@property(nonatomic,assign) V2NIMQueryDirection direction;
/// 严格模式，默认为NO [选填]
/// YES：如果无法确定消息完整性，则返回错误
/// NO：如果无法确定消息完整性，从数据库中查询并返回
@property (nonatomic, assign) BOOL strictMode;

/// 是否只查询本地消息，默认为NO [选填]
/// YES：直接返回数据库中的消息
/// NO：综合判断消息来源
@property (nonatomic, assign) BOOL onlyQueryLocal;
@end

@interface V2NIMCloudMessageListOption : NSObject<NSCopying>
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
@property(nonatomic,assign) NSInteger limit;
/// 锚点消息，根据锚点消息查询，不包含该消息 [选填]
@property(nullable,nonatomic,strong) V2NIMMessage *anchorMessage;
/// 消息查询方向，如果其它参数都不填 [选填]
/// 如果查询older， 则beginTime默认为long.maxValue，否则以beginTime向老查询
/// 如果查询newer， 则beginTime默认为0, 否则以beginTime开始向最新查询
@property(nonatomic,assign) V2NIMQueryDirection direction;
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
/// 清除模式，默认为 V2NIM_CLEAR_HISTORY_MODE_ALL ， 表示删除云端和本地
@property(nonatomic,assign,readwrite) V2NIMClearHistoryMode clearMode;
@end

@interface V2NIMUpdateLocalMessageParams : NSObject<NSCopying>
/// 消息子类型，需要 >= 0
@property(nonatomic,assign) NSInteger subType;
/// 消息内容
@property(nonatomic,copy, nullable) NSString *text;
/// 消息附属附件。根据消息类型继承实现
@property(nonatomic,strong, nullable) V2NIMMessageAttachment *attachment;
/// 消息本地扩展
@property(nonatomic,copy, nullable) NSString *localExtension;
/// 消息发送状态。仅支持修改为成功和失败， 其它状态返回参数报错
@property(nonatomic,assign) V2NIMMessageSendingState sendingState;
@end

@interface V2NIMImportMessagesToLocalOption : NSObject<NSCopying>
/**
 * YES：如果会话入口不存在，则同步创建会话
 * NO：则不会主动创建会话入口， 依赖于后续收发消息后产生
 */
@property(nonatomic,assign) BOOL shouldUpdateConversation;
@end

NS_ASSUME_NONNULL_END
