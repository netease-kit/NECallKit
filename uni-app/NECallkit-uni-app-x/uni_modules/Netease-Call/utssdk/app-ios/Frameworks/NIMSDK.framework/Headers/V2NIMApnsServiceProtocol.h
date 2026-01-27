//
//  V2NIMApnsServiceProtocol.h
//  NIMSDK
//
//  Created by 陈吉力 on 2025/5/21.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取 badge 回调
 *
 *  @return badge 数量
 */
typedef NSUInteger(^V2NIMBadgeHandler)(void);

@protocol V2NIMApnsService <NSObject>

/**
 *  注册获取 badge 数量的回调函数
 *
 *  @param handler 获取 badge 回调
 *  @discussion 默认场景下，云信会将所有未读数量统一汇报给服务器，包括需要提醒和不需要提醒的会话未读数，上层可以通过注册该接口进行调整
 */
- (void)registerBadgeCountHandler:(nullable V2NIMBadgeHandler)handler;

@end

NS_ASSUME_NONNULL_END
