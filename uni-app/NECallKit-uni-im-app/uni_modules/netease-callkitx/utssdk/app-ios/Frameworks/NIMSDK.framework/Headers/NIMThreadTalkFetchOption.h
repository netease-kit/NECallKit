//
//  NIMThreadTalkFetchOption.h
//  NIMLib
//
//  Created by He on 2020/4/7.
//  Copyright © 2020 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMMessage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取Thread Talk消息分页选择
 */
@interface NIMThreadTalkFetchOption : NSObject
/**
 *  查询开始时间戳，默认 0，单位(s)
 */
@property (nonatomic,assign) NSTimeInterval start;
/**
 *  查询h结束时间戳，默认 当前时间+1小时，单位(s)
 */
@property (nonatomic,assign) NSTimeInterval end;
/**
 *  查询结果排除指定消息，默认为空
 */
@property (nonatomic,strong) NIMMessage *excludeMessage;
/**
 *  分页查询数量，默认100
 */
@property (nonatomic,assign) NSUInteger limit;
/**
 *  逆序查询，默认 NO
 */
@property (nonatomic,assign) BOOL reverse;

/**
 *  同步到DB，默认 NO
 */
@property (nonatomic,assign) BOOL sync;

@end

NS_ASSUME_NONNULL_END
