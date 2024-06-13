//
//  NIMQChatRejectServerApplyParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  拒绝申请的参数
 */
@interface NIMQChatRejectServerApplyParam : NSObject

/**
 * 圈组服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 申请人ID
 */
@property (nonnull, nonatomic, copy) NSString *accid;

/**
 * 附言（最长5000）
 */
@property (nullable, nonatomic, copy) NSString *postscript;

/**
 *  请求id
 */
@property (nonatomic, assign) unsigned long long requestId;

@end


NS_ASSUME_NONNULL_END
