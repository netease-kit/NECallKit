//
//  V2NIMBaseConversation.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMConversationEnum.h"

@class V2NIMLastMessage;

NS_ASSUME_NONNULL_BEGIN

@protocol V2NIMBaseConversation <NSObject>

/// 会话id
@property(nonatomic,copy,readonly) NSString *conversationId;

/// 会话类型
@property(nonatomic,assign,readonly) V2NIMConversationType type;

/// 会话名称
@property(nullable,nonatomic,copy,readonly) NSString *name;

/// 会话头像
@property(nullable,nonatomic,copy,readonly) NSString *avatar;

/// 免打扰。YES：开启，NO：关闭，默认NO：关闭
@property(nonatomic,assign,readonly) BOOL mute;

/// 置顶。YES：已置顶，NO：未置顶，默认NO：未置顶
@property(nonatomic,assign,readonly) BOOL stickTop;

/// 本地扩展字段
@property(nonatomic,copy,readonly) NSString *localExtension;

/// 会话所属的最近一条消息
@property(nullable,nonatomic,copy,readonly) V2NIMLastMessage *lastMessage;

/// 会话的未读消息计数
@property(nonatomic,assign,readonly) NSInteger unreadCount;

/// 会话创建时间
@property(nonatomic,assign,readonly) NSTimeInterval createTime;

/// 会话更新时间
@property(nonatomic,assign,readonly) NSTimeInterval updateTime;

/// 会话排序字段
@property(nonatomic,assign,readonly) long long sortOrder;

@end

NS_ASSUME_NONNULL_END
