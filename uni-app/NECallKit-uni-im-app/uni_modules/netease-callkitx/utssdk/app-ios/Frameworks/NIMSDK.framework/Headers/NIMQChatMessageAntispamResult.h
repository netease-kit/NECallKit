//
//  NIMQChatMessageAntispamResult.h
//  NIMLib
//
//  Created by Evang on 2022/3/23.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 圈组消息反垃圾结果
 */
@interface NIMQChatMessageAntispamResult : NSObject

/**
 * 是否被反垃圾了
 */
@property (nonatomic, assign) BOOL isAntispam;

/**
 * 反垃圾返回的结果字段
 */
@property (nonatomic, copy) NSString *yidunAntiSpamRes;

@end

NS_ASSUME_NONNULL_END
