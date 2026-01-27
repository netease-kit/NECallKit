//
//  V2NIMIndex.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

/// 索引类型，同NIMIndexType
typedef NS_ENUM(NSInteger, V2NIMIndexType) {
    /// 消息文本
    V2NIM_INDEX_TYPE_MESSAGE_TEXT = 0,

    /// 自定义索引类型起始
    V2NIM_INDEX_TYPE_MESSAGE_TEXT_CUSTOM_BASE = 100,
};

/// 消息索引
@interface V2NIMMessageIndex : NSObject<NSCopying>

/// 索引文本
@property(nullable,nonatomic,strong,readonly) NSString *indexText;
/// 索引类型 V2NIMIndexType
@property(nonatomic,assign,readonly) NSInteger indexType;

/// 客户端消息ID
@property(nullable,nonatomic,strong,readonly) NSString *messageClientId;
/// 会话 ID
@property(nullable,nonatomic,strong,readonly) NSString *conversationId;
/// 消息时间
@property(nonatomic,assign,readonly) NSTimeInterval createTime;
/// 类型
@property(nonatomic,assign,readonly) V2NIMMessageType messageType;
/// 子类型
@property(nonatomic,assign,readonly) NSInteger subType;
/// 发送者账号
@property(nullable,nonatomic,strong,readonly) NSString *senderId;

@end

NS_ASSUME_NONNULL_END
