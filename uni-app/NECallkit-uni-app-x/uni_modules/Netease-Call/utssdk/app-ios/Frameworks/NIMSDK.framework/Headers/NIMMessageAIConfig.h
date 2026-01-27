//
//  NIMMessageAIConfig.h
//  NIMLib
//
//  Created by 陈吉力 on 2024/9/24.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
@class NIMAIModelConfigParams;
@class NIMAIModelCallContent;
@class NIMAIModelCallMessage;
@class NIMAIRAGInfo;
@class NIMMessageAIStreamChunk;

NS_ASSUME_NONNULL_BEGIN

/// 大模型角色类型
typedef NS_ENUM(NSInteger, NIMMessageAIStatus) {
    NIMMessageAIStatusUnknow                          = 0,  ///< 普通消息
    NIMMessageAIStatusAt                              = 1,  ///< 表示是一个艾特数字人的消息
    NIMMessageAIStatusResponse                        = 2,  ///< 表示是数字人响应艾特的消息
};

/// 数字人流式消息状态
typedef NS_ENUM(NSInteger, NIMMessageAIStreamStatus) {
    /// 流式过程中（本地状态，其他为服务器状态）
    NIM_MESSAGE_AI_STREAM_STATUS_STREAMING = -1,
    
    /// 非流式状态
    NIM_MESSAGE_AI_STREAM_STATUS_NONE = 0,
    
    /// 占位
    NIM_MESSAGE_AI_STREAM_STATUS_PLACEHOLDER = 1,
    
    /// 停止输出
    NIM_MESSAGE_AI_STREAM_STATUS_CANCEL = 2,
    
    /// 停止并更新
    NIM_MESSAGE_AI_STREAM_STATUS_UPDATE = 3,
    
    /// 输出完成
    NIM_MESSAGE_AI_STREAM_STATUS_GENERATED = 4,
    
    /// 服务器异常停止
    NIM_MESSAGE_AI_STREAM_STATUS_ABORTED = 5
};

/// 停止流式输出操作类型
typedef NS_ENUM(NSInteger, NIMMessageAIStreamStopOpType) {
    /// 停止输出(保持现状)
    NIM_MESSAGE_AI_STREAM_STOP_OP_DEFAULT = 0,
    
    /// 停止并撤回消息
    NIM_MESSAGE_AI_STREAM_STOP_OP_REVOKE = 1,
    
    /// 停止并更新消息内容
    NIM_MESSAGE_AI_STREAM_STOP_OP_UPDATE = 2
};

/// 重新输出数字人消息操作类型
typedef NS_ENUM(NSInteger, NIMMessageAIRegenOpType) {
    /// 更新消息
    /// 不会生成新消息
    NIM_MESSAGE_AI_REGEN_OP_UPDATE = 1,
    
    /// 生成一条新消息
    NIM_MESSAGE_AI_REGEN_OP_NEW = 2
};


@interface NIMMessageAIConfig :  NSObject<NSCopying>
/// 数字人的 accountId
@property(nullable,nonatomic,strong,readwrite) NSString *accountId;

/// 该 AI 消息的询问和应答标识
/// 0 表示普通消息
/// 1 表示是一个艾特数字人的消息
/// 2 表示是数字人响应艾特的消息
/// 响应回参
@property(nonatomic,assign,readwrite) NIMMessageAIStatus aiStatus;

/// 数字人回复内容的引用资源列表
@property(nullable,nonatomic,strong,readwrite) NSArray<NIMAIRAGInfo *> *aiRAGs;

/// 是否是流式响应，默认NO
@property(nonatomic,assign,readwrite) BOOL aiStream;

/// 数字人流式消息状态。默认V2NIM_MESSAGE_AI_STREAM_STATUS_NONE
@property(nonatomic,assign,readwrite) NIMMessageAIStreamStatus aiStreamStatus;

/// 数字人流式消息最近一个分片
/// 注意：流式过程中的消息text是将接收到的分片组装好之后的结果
@property(nullable,nonatomic,strong,readonly) NIMMessageAIStreamChunk *aiStreamLastChunk;

@end

@interface NIMMessageAIConfigParams : NSObject<NSCopying>
/// 数字人的 accountId
@property(nullable,nonatomic,strong,readwrite) NSString *accountId;

/// 请求大模型的内容
@property(nullable,nonatomic,strong,readwrite) NIMAIModelCallContent *content;
/// 上下文内容
/// 当前只支持文本消息
@property(nullable,nonatomic,strong,readwrite) NSArray<NIMAIModelCallMessage *> *messages;
/// 提示词变量占位符替换
/// JSON 格式的字符串
/// 用于填充prompt中的变量
@property(nullable,nonatomic,strong,readwrite) NSString *promptVariables;
/// 请求接口模型相关参数配置， 如果参数不为空，则默认覆盖控制相关配置
@property(nullable,nonatomic,strong,readwrite) NIMAIModelConfigParams *modelConfigParams;
/// 是否是流式响应，默认NO
@property(nonatomic,assign,readwrite) BOOL aiStream;
@end

/// 引用资源信息类
@interface NIMAIRAGInfo : NSObject
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
@interface NIMMessageAIStreamChunk : NSObject
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
@interface NIMMessageAIStreamStopParams : NSObject
/// 停止流式消息的操作类型
@property (nonatomic, assign) NIMMessageAIStreamStopOpType operationType;
/// 更新的消息内容，仅当operationType == V2NIM_MESSAGE_AI_STREAM_STOP_OP_UPDATE有效
@property (nullable,nonatomic, strong) NSString *updateContent;
@end

/// 重新输出数字人消息配置参数
@interface NIMMessageAIRegenParams: NSObject
/// 重新输出数字人消息操作类型
@property (nonatomic,assign,readonly) NIMMessageAIRegenOpType operationType;

- (instancetype)initWith:(NIMMessageAIRegenOpType)operationType;
@end


NS_ASSUME_NONNULL_END
