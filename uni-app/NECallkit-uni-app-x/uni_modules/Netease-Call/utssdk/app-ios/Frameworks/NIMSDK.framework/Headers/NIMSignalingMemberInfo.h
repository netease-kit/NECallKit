//
//  NIMSignalMemberInfo.h
//  NIMLib
//
//  Created by taojinliang on 2018/10/24.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 成员信息
 */
@interface NIMSignalingMemberInfo : NSObject

/**
 账户ID
 */
@property(nonatomic, copy) NSString *accountId;

/**
 用户ID
 */
@property(nonatomic, assign) uint64_t uid;

/**
 创建时间
 */
@property(nonatomic, assign) uint64_t createTimeStamp;

/**
 过期时间
 */
@property(nonatomic, assign) uint64_t expireTimeStamp;
@end

NS_ASSUME_NONNULL_END
