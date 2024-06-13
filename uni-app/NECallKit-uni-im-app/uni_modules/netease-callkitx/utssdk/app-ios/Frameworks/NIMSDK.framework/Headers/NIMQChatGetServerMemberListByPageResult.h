//
//  NIMQChatGetServerMemberByPageResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatServerMember;
/**
 *  查询服务器成员的回调类型
 */
@interface NIMQChatGetServerMemberListByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

@property (nullable, nonatomic, copy) NSArray <NIMQChatServerMember *> *memberArray;

@end


NS_ASSUME_NONNULL_END
