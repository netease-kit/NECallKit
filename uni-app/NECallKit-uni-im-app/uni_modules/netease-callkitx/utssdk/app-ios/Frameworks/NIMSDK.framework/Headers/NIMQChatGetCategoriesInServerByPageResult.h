

//
//  NIMQChatGetCategoriesInServerByPageResult.h
//  NIMSDK
//
//  Created by Evang on 2022/4/26.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannelCategory;
/**
 *  分页获取服务器内频道分组信息
 */
@interface NIMQChatGetCategoriesInServerByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 频道分组列表
 */
@property (nonatomic, copy) NSArray <NIMQChatChannelCategory *> *categoryArray;

@end

NS_ASSUME_NONNULL_END

