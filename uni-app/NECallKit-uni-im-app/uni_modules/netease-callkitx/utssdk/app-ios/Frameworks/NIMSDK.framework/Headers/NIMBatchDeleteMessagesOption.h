//
//  NIMBatchDeleteMessagesOption.h
//  NIMLib
//
//  Created by He on 2019/6/25.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  批量删除本地消息选项
 */
@interface NIMBatchDeleteMessagesOption : NSObject

/**
 *  起始时间， 默认 0， 单位s
 *  @discussion 小于等于0表示之前全部消息
 */
@property(nonatomic,assign) NSTimeInterval start;

/**
 *  截止时间， 默认 0， 单位s
 *  @discussion 小于等于0表示当前时间
 */
@property(nonatomic,assign) NSTimeInterval end;

@end

NS_ASSUME_NONNULL_END
