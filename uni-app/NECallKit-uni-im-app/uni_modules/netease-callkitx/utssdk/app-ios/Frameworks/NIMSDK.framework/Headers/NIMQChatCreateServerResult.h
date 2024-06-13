//
//  NIMQChatCreateServerResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatServer.h"

@class NIMQChatServer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建服务器的参数
 */
@interface NIMQChatCreateServerResult : NSObject

/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy) NIMQChatServer *server;

@end


NS_ASSUME_NONNULL_END
