//
//  NIMQChatCreateChannelResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatChannel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建频道的回调类型
 */
@interface NIMQChatCreateChannelResult : NSObject

@property (nullable, nonatomic, copy) NIMQChatChannel *channel;

@end


NS_ASSUME_NONNULL_END
