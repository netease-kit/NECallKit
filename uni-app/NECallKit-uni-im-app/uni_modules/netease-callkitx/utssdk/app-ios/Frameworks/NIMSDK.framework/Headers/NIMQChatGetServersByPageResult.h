//
//  NIMQChatGetServersByPageResult.h
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
@interface NIMQChatGetServersByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;
/**
 * 圈组服务器
 */
@property (nullable, nonatomic, copy)NSArray<NIMQChatServer *> *servers;
@end


NS_ASSUME_NONNULL_END
