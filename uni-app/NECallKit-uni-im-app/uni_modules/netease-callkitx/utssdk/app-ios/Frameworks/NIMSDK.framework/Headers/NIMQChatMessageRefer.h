//
//  NIMQChatMessageRefer.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatMessageServerIdInfo;
/**
 *  消息引用结构
 *  @discussion 各属性命名同NIMQChatMessage
 */
@interface NIMQChatMessageRefer : NSObject <NSCopying>


/**
 *  消息服务端ID信息
 */
@property (nonatomic,copy,readonly)                 NIMQChatMessageServerIdInfo *serverIdInfo;

/**
 *  消息ID,唯一标识（本地）
 */
@property (nonatomic,copy,readonly)                 NSString *messageId;

/**
 *  消息发送者
 */
@property (nonatomic,copy,readonly)                 NSString *from;

@end

NS_ASSUME_NONNULL_END
