//
//  NIMQChatGetChannelUnreadInfosResult.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatUnreadInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  更新圈组消息的回调参数类型
 */
@interface NIMQChatGetChannelUnreadInfosResult : NSObject

/**
 * 未读信息列表
 */
@property (nullable, nonatomic, strong) NSArray<NIMQChatUnreadInfo *> *unreadInfo;

@end


NS_ASSUME_NONNULL_END
