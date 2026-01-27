//
//  NIMMessageObjectProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"

NS_ASSUME_NONNULL_BEGIN

@class NIMMessage;
@class NIMQChatMessage;

/**
 *  消息体协议
 */
@protocol NIMMessageObject <NSObject>

/**
 *  消息体所在的消息对象
 */
@property (nullable,nonatomic, weak) NIMMessage *message;

/**
 *  消息体所在的消息对象（圈组消息）
 */
@property (nullable,nonatomic, weak) NIMQChatMessage *qchatMessage;

/**
 *  消息内容类型
 *
 *  @return 消息内容类型
 */
- (NIMMessageType)type;


@end

NS_ASSUME_NONNULL_END
