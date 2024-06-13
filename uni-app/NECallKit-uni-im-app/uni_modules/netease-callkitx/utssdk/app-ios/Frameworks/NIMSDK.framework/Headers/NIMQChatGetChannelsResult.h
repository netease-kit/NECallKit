//
//  NIMQChatGetChannelsResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatChannel;
/**
 *  查询频道信息的回调类型
 */
@interface NIMQChatGetChannelsResult : NSObject

@property (nonatomic, copy) NSArray <NIMQChatChannel *> *channels;

@end


NS_ASSUME_NONNULL_END
