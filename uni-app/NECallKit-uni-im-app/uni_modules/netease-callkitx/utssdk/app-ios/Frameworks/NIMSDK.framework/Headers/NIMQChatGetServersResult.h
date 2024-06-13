//
//  NIMQChatGetServersResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatServer;

NS_ASSUME_NONNULL_BEGIN

/**
 *  标记消息已读的回调类型
 */
@interface NIMQChatGetServersResult : NSObject

/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatServer *> *servers;
@end


NS_ASSUME_NONNULL_END
