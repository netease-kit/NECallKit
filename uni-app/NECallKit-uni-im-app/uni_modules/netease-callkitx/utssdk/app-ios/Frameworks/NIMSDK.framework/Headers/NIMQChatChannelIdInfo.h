//
//  NIMQChatChannelIdInfo.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 频道ID
 */
@interface NIMQChatChannelIdInfo : NSObject<NSCopying>

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

- (instancetype)initWithChannelId:(unsigned long long int)channelId serverId:(unsigned long long int)serverId;


@end

NS_ASSUME_NONNULL_END
