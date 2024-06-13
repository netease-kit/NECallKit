//
//  NIMQChatUnreadInfoChangedEvent.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatUnreadInfo;

/**
 *  查询未读信息的参数
 */
@interface NIMQChatUnreadInfoChangedEvent : NSObject

/**
 * 变更后的未读状态
 */
@property (nullable, nonatomic, strong) NSArray<NIMQChatUnreadInfo *> *unreadInfo;

/**
 * 上一次通知时的未读状态
 */
@property (nullable, nonatomic, strong) NSArray<NIMQChatUnreadInfo *> *lastUnreadInfo;

@end

NS_ASSUME_NONNULL_END
