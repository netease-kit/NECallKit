
//
//  NIMQChatGetChannelCategoryBlackWhiteRolesByPageResult.h
//  NIMSDK
//
//  Created by Evang on 2022/1/17.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
 

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerRole;
/**
 *  分页查询频道分组黑白名单身份组列表
 */
@interface NIMQChatGetChannelCategoryBlackWhiteRolesByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 身份组列表
 */
@property (nonatomic, copy) NSArray <NIMQChatServerRole *> *roleArray;

@end

NS_ASSUME_NONNULL_END
