//
// Created by 陈吉力 on 2022/10/18.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 我的聊天室标签变更通知类
 */
@interface NIMChatroomTagsUpdateEvent : NSObject
/**
 * 聊天室ID
 */
@property(nonatomic, nullable, copy, readonly) NSString *roomId;

/**
 * 修改后的标签
 */
@property(nonatomic, nullable, copy, readonly) NSArray *tags;
@end
NS_ASSUME_NONNULL_END