//
//  NIMMessageStreamConfig.h
//  NIMSDK
//
//  Created by 陈吉力 on 2025/6/4.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessageStreamChunk;
@class NIMAIRAGInfo;

NS_ASSUME_NONNULL_BEGIN

/// 流式消息状态
typedef NS_ENUM(NSInteger, NIMMessageStreamStatus) {
    /// 流式过程中（本地状态，其他为服务器状态）
    NIM_MESSAGE_STREAM_STATUS_STREAMING = -1,
    
    /// 非流式状态
    NIM_MESSAGE_STREAM_STATUS_NONE = 0,
    
    /// 占位
    NIM_MESSAGE_STREAM_STATUS_PLACEHOLDER = 1,
    
    /// 停止输出
    NIM_MESSAGE_STREAM_STATUS_STOPPED = 2,
    
    /// 停止并更新
    NIM_MESSAGE_STREAM_STATUS_UPDATED = 3,
    
    /// 输出完成
    NIM_MESSAGE_STREAM_STATUS_GENERATED = 4,
    
    /// 服务器异常停止
    NIM_MESSAGE_STREAM_STATUS_ABORTED = 5
};

@interface NIMMessageStreamConfig : NSObject <NSCopying>
/// 流式消息状态
@property(nonatomic,assign,readonly) NIMMessageStreamStatus status;
/// 流式消息最近一个分片
/// 流式过程中才有该字段，最终完整消息无此字段
/// 注意：流式过程中的消息text是将接收到的分片组装好之后的结果
@property(nullable,nonatomic,strong,readonly) NIMMessageStreamChunk *lastChunk;
/// 数字人回复内容的引用资源列表
@property(nullable,nonatomic,strong,readonly) NSArray<NIMAIRAGInfo *> *rags;
@end

@interface NIMMessageStreamChunk : NSObject <NSCopying>
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

NS_ASSUME_NONNULL_END
