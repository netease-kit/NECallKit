//
//  NIMQChatUpdateServerResult.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  修改服务器信息的回调参数类型
 */
@interface NIMQChatUpdateServerResult : NSObject

/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy) NIMQChatServer *server;

@end

NS_ASSUME_NONNULL_END
