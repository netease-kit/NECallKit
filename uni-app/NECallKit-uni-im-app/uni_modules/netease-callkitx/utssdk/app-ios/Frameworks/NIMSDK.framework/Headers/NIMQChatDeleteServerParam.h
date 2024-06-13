//
//  NIMQChatDeleteServerParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  删除服务器的参数
 */
@interface NIMQChatDeleteServerParam : NSObject

/**
 * 圈组服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;
@end


NS_ASSUME_NONNULL_END
