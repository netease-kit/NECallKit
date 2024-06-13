//
//  NIMMessageTimeConsumingStatistics.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2023年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 消息收发耗时统计
 */
@interface NIMTimeConsumingStatistics : NSObject

/**
 * 发送 调用api
 */
@property (nonatomic,assign)                NSTimeInterval sendTagInvokeAPI;

/**
 * 发送 进入发送队列
 */
@property (nonatomic,assign)                NSTimeInterval sendTagEnterSendQueue;

/**
 * 发送 收到服务器Ack
 */
@property (nonatomic,assign)                NSTimeInterval sendTagReceivedServerAck;

/**
 * 发送 回调应用层
 */
@property (nonatomic,assign)                NSTimeInterval sendTagCallbackApp;

/**
 * 接收 解析到消息包
 */
@property (nonatomic,assign)                NSTimeInterval recvTagParsedMessagePacket;

/**
 * 接收 回调应用层
 */
@property (nonatomic,assign)                NSTimeInterval recvTagCallbackApp;

@end

NS_ASSUME_NONNULL_END
