//
//  NIMQChatGetChannelsByPageResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannel;
/**
 *  分页查询频道信息的回调类型
 */
@interface NIMQChatGetChannelsByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

@property (nonatomic, copy) NSArray <NIMQChatChannel *> *channels;

@end


NS_ASSUME_NONNULL_END
