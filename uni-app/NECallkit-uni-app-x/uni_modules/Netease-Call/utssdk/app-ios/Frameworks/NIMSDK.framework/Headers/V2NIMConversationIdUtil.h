//
//  V2NIMConversationIdUtil.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMConversationEnum.h"

NS_ASSUME_NONNULL_BEGIN

/// 会话id
@interface V2NIMConversationIdUtil : NSObject

/**
 *  使用账号Id构造会话id
 *
 *  @param accountId 账号Id
 *  @return 返回会话id
 *  @discussion
 */
+ (nullable NSString *)p2pConversationId:(NSString *)accountId;
/**
 *  使用群Id构造会话id
 *
 *  @param teamId 群Id
 *  @return 返回会话id
 *  @discussion
 */
+ (nullable NSString *)teamConversationId:(NSString *)teamId;
/**
 *  使用群Id构造会话id（超大群）
 *
 *  @param teamId 群Id
 *  @return 返回会话id
 *  @discussion
 */
+ (nullable NSString *)superTeamConversationId:(NSString *)teamId;

/**
 *  从会话id中获取会话类型
 *
 *  @param conversationId 会话id
 *  @return 返回会话类型
 *  @discussion
 */
+ (V2NIMConversationType)conversationType:(NSString *)conversationId;
/**
 *  从会话id中获取会话对象id
 *
 *  @param conversationId 会话id
 *  @return 返回会话对象id
 *  @discussion
 */
+ (nullable NSString *)conversationTargetId:(NSString *)conversationId;

@end

NS_ASSUME_NONNULL_END
