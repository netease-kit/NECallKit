

//
//  NIMQChatMarkServerReadParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  设置服务器消息已读的参数
 */
@interface NIMQChatMarkServerReadParam : NSObject

/**
 * 服务器id 数组，元素为 serverId 的NSNumber 包装
 */
@property (nonatomic, copy) NSArray<NSNumber *> *serverIds;


@end


NS_ASSUME_NONNULL_END


