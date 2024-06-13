//
//  NIMMessageRobotInfo.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2023年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 消息中机器人相关信息
 */
@interface NIMMessageRobotInfo : NSObject

/**
 * 机器人具体功能
 * @discussion
 *
 */
@property(nullable, nonatomic, copy)    NSString    *function;

/**
 * 话题
 * @discussion
 *
 */
@property(nullable, nonatomic, copy)    NSString    *topic;

/**
 * 自定义内容
 * @discussion
 *
 */
@property(nullable, nonatomic, copy)    NSString    *customContent;

/**
 * 机器人账号
 * @discussion 仅群消息有效，指定要发送给群里的具体某个机器人账号
 *
 */
@property(nullable, nonatomic, copy)    NSString    *account;

@end

NS_ASSUME_NONNULL_END
