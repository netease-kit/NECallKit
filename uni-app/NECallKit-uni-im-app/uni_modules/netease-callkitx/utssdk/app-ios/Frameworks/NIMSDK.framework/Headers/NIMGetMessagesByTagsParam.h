//
// Created by NetEase on 2022/10/10.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface NIMGetMessagesByTagsParam : NSObject <NSCopying>
/**
 * 聊天室ID
 */
@property(nonatomic, readonly, assign) NSInteger roomId;
/**
 * 标签
 */
@property(nonatomic, readonly, nonnull, copy) NSArray<NSString *> *tags;
/**
 * 消息类型
 */
@property(nonatomic, nullable, copy) NSArray<NSNumber *> *messageTypes;
/**
 * 起始时间s
 * NSTimeInterval，即double
 */
@property(nonatomic, nullable, copy) NSNumber *fromTime;
/**
 * 结束时间s
 * NSTimeInterval，即double
 */
@property(nonatomic, nullable, copy) NSNumber *toTime;
/**
 * 最大消息数量
 * NSInteger
 */
@property(nonatomic, nullable, copy) NSNumber *limit;
/**
 * 是否反向
 * BOOL
 */
@property(nonatomic, nullable, copy) NSNumber *reverse;

- (instancetype)initWithRoomId:(NSInteger)roomId tags:(nonnull NSArray<NSString *> *)tags;

@end
