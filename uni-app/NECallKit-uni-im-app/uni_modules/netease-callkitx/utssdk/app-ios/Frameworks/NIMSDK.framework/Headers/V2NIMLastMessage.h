//
//  V2NIMLastMessage.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMMessageEnum.h"

@class V2NIMMessageRefer;
@class V2NIMMessageAttachment;

NS_ASSUME_NONNULL_BEGIN

/// 最近一条消息的状态
typedef NS_ENUM(NSInteger, V2NIMLastMessageState) {
    V2NIM_LAST_MESSAGE_STATE_DEFAULT                              = 0,  ///< 正常
    V2NIM_LAST_MESSAGE_STATE_REVOKED                              = 1,  ///< 已撤回
    V2NIM_LAST_MESSAGE_STATE_CLIENT_FILL                          = 2,  ///< 客户端回填消息
};

/// 会话的最后一条消息
@interface V2NIMLastMessage : NSObject <NSCopying>

/// 最后一条消息状态
@property(nonatomic,assign,readonly) V2NIMLastMessageState lastMessageState;

/// 最后一条消息的引用
@property(nonatomic,strong,readonly) V2NIMMessageRefer *messageRefer;

/// 消息类型（仅消息时有意义）
@property(nonatomic,assign,readonly) V2NIMMessageType messageType;

/// 消息子类型（仅消息时有意义）
@property(nonatomic,assign,readonly) NSInteger subType;

/// 消息发送状态（仅消息时有意义）
@property(nonatomic,assign,readonly) V2NIMMessageSendingState sendingState;

/// 消息文本（撤回时为撤回附言）
@property(nullable,nonatomic,strong,readonly) NSString *text;

/// 消息附件（仅消息时有意义）
@property(nullable,nonatomic,strong,readonly) V2NIMMessageAttachment *attachment;

/// 消息撤回者账号id（仅撤回时有意义）
@property(nullable,nonatomic,strong,readonly) NSString *revokeAccountId;

/// 消息撤回类型（仅撤回时有意义）
@property(nonatomic,assign,readonly) V2NIMMessageRevokeType revokeType;

/// 服务端扩展信息
@property(nullable,nonatomic,strong,readonly) NSString *serverExtension;

/// 第三方回调传入的自定义扩展字段
@property(nullable,nonatomic,strong,readonly) NSString *callbackExtension;

@end

NS_ASSUME_NONNULL_END
