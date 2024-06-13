//
//  NIMQChatGetChannelRolesResult.h
//  NIMSDK
//
//  Created by Evang on 2022/1/15.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatChannelRole;
/**
 *  获取频道下身份组信息列表
 */
@interface NIMQChatGetChannelRolesResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatChannelRole *> *channelRoleArray;

@end

NS_ASSUME_NONNULL_END

