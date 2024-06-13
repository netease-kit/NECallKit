//
//  NIMChatExtendBasicInfo.h
//  NIMLib
//
//  Created by He on 2020/4/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMSession.h"

@class NIMMessage;
@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取 Thread Talk 消息基本信息
 */
@interface NIMChatExtendBasicInfo : NSObject <NSCopying>

/**
 *  会话类型
 */
@property (nonatomic,assign) NIMSessionType type;

/**
 *  消息的发送时间戳，单位(s)
 */
@property (nonatomic,assign) NSTimeInterval timestamp;

/**
 *  消息发送方
 */
@property (nonatomic,copy) NSString *fromAccount;

/**
 *  消息的接收方
 */
@property (nonatomic,copy) NSString *toAccount;

/**
 *  消息的服务端ID
 */
@property (nonatomic,copy) NSString *serverID;

/**
 *  消息的本地ID
 */
@property (nonatomic,copy) NSString *messageID;

/**
 * 所在会话
 */
@property (nonatomic,strong,readonly) NIMSession *session;


/**
 *  根据消息获取
 *
 *  @param message 目标消息
 */
- (instancetype)initWithMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
