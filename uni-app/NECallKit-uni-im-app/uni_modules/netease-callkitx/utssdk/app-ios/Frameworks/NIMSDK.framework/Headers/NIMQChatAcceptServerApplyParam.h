//
//  NIMQChatAcceptServerApplyParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  接受申请的参数
 */
@interface NIMQChatAcceptServerApplyParam : NSObject

/**
 * 同意加入的服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 申请者ID
 */
@property (nonnull, nonatomic, copy) NSString *accid;

/**
 *  请求id
 */
@property (nonatomic, assign) unsigned long long requestId;

@end


NS_ASSUME_NONNULL_END
