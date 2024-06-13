//
//  NIMQChatClient.h
//  NIMLib
//
//  Created by Netease on 2022/2/7.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NIMQChatClient : NSObject
/**
 * 客户端的操作系统信息，格式为
 */
@property(nullable, nonatomic, copy, readonly) NSString *os;

/**
 * 客户端类型。
 * @see ClientType
 *
 */
@property(nonatomic, assign, readonly) NSInteger clientType;

/**
 * 登录时间
 */
@property(nonatomic, assign, readonly) NSTimeInterval loginTime;

/**
 * 客户端IP
 */
@property(nullable, nonatomic, copy, readonly) NSString *clientIp;

/**
 * 客户端端口
 */
@property(nullable, nonatomic, copy, readonly) NSString *clientPort;

/**
 * 客户端设备Id
 */
@property(nullable, nonatomic, copy, readonly) NSString *deviceId;

/**
 * 自定义customTag
 */
@property(nullable, nonatomic, copy, readonly) NSString *customTag;

/**
 * 自定义ClientType
 */
@property(nonatomic, assign, readonly) NSInteger customClientType;
@end

