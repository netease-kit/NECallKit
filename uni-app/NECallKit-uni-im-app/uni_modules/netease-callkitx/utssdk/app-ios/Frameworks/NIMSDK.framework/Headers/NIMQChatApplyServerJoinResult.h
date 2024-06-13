//
//  NIMQChatApplyServerJoinResult.h
//  NIMLib
//
//  Created by lihuang on 2022/6/21.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 *  申请加入服务器的结果
 */
@interface NIMQChatApplyServerJoinResult : NSObject
/**
 *  申请id
 */
@property (nonatomic, assign) unsigned long long requestId;

/**
 *  申请的有效时间
 */
@property (nonatomic, assign) NSTimeInterval ttl;

@end

NS_ASSUME_NONNULL_END
