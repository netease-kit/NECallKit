//
//  NIMQChatSearchServerChannelMemberParam.h
//  NIMLib
//
//  Created by 齐洪茹 on 2022/8/23.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatSearchServerChannelMemberParam : NSObject
/**
 * 检索关键字，目标检索昵称、账号，最大100个字符
 */
@property (nonnull, nonatomic, copy)NSString *keyword;

/**
 * 服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 频道ID
 */
@property (nonatomic, assign) unsigned long long channelId;


/**
 * 检索返回的最大记录数，最大和默认都是100
 */
@property (nullable, nonatomic, copy) NSNumber *limit;

@end

NS_ASSUME_NONNULL_END
