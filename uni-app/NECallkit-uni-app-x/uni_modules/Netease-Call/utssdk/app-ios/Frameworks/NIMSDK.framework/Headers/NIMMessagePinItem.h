//
//  NIMMessagePinItem.h
//  NIMLib
//
//  Created by 丁文超 on 2020/4/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;
@class NIMSession;

NS_ASSUME_NONNULL_BEGIN

@interface NIMMessagePinItem : NSObject

/**
 * 对应会话
 */
@property (nonatomic, copy) NIMSession *session;

/**
 * 消息发送方ID
 */
@property (nonatomic, copy) NSString *messageFromAccount;

/**
 * 消息接收方ID
 */
@property (nonatomic, copy) NSString *messageToAccount;

/**
 * 消息时间戳(s)
 */
@property (nonatomic, assign) NSTimeInterval messageTime;

/**
 * 服务端消息ID
 */
@property (nonatomic, strong) NSString *messageServerID;

/**
 * 本地消息ID
 */
@property (nonatomic, copy) NSString *messageId;

/**
 * 操作者，不传表示当前登录者
 */
@property (nonatomic, copy, nullable) NSString *accountID;

/**
 * 扩展字段，string，最大512
 */
@property (nonatomic, copy, nullable) NSString *ext;

/**
 * 创建时间(s)
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间(s)
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

/**
 * 简便初始化方法
 */
- (instancetype)initWithMessage:(NIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
