
//
//  NIMQChatGetChannelMembersByPageResult.h
//  NIMSDK
//
//  Created by Evang on 2022/1/17.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerMember;
/**
 *  分页获取频道成员列表
 */
@interface NIMQChatGetChannelMembersByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 成员列表
 */
@property (nonatomic, copy) NSArray <NIMQChatServerMember *> *memberArray;

@end

NS_ASSUME_NONNULL_END
