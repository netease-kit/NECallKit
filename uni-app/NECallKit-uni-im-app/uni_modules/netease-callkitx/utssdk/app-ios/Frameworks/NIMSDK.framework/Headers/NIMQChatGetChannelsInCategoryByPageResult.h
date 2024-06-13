

//
//  NIMQChatGetChannelsInCategoryByPageResult.h
//  NIMSDK
//
//  Created by Evang on 2022/4/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannel;
/**
 *  分页获取频道分组内频道结果
 */
@interface NIMQChatGetChannelsInCategoryByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 频道列表
 */
@property (nonatomic, copy) NSArray <NIMQChatChannel *> *channelArray;

@end

NS_ASSUME_NONNULL_END

