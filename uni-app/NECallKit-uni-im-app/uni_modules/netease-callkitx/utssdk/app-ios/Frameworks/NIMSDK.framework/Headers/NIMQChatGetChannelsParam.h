//
//  NIMQChatGetChannelsParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  获取频道列表入参
 */
@interface NIMQChatGetChannelsParam : NSObject

/**
 * 频道id数组
 */
@property (nonatomic, copy) NSArray *channelIdArray;

@end


NS_ASSUME_NONNULL_END
