//
//  NIMQChatApplyServerJoinParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * 申请加入服务器的参数
 */
@interface NIMQChatApplyServerJoinParam : NSObject

/**
 * 申请加入的服务器Id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 附言（最长5000）
 */
@property (nullable, nonatomic, copy) NSString *postscript;

/**
 *  有效时间，秒的NSNumber包装
 */
@property (nullable, nonatomic, strong) NSNumber *ttl;

@end


NS_ASSUME_NONNULL_END
