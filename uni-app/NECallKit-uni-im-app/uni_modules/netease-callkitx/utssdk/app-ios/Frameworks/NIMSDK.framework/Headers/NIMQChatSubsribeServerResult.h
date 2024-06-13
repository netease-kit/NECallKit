//
//  NIMQChatSubsribeServerResult.h
//  NIMLib
//
//  Created by Evang on 2022/6/9.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 订阅服务器结果
 */
@interface NIMQChatSubsribeServerResult : NSObject
/**
 * 订阅服务器失败的serverId列表
 */
@property (nonatomic, copy) NSArray <NSNumber *> *failedServerIds;

@end

NS_ASSUME_NONNULL_END
