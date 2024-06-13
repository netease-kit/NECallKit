

//
//  NIMQChatSubscribeAllChannelResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class NIMQChatUnreadInfo;
/**
 *  订阅服务器下所有频道的结果
 */
@interface NIMQChatSubscribeAllChannelResult : NSObject

/**
 * 未读信息数组
 */
@property (nonatomic, copy) NSArray<NIMQChatUnreadInfo *> *unreadInfos;

/**
 * 设置失败的服务器ID 数组，元素为 服务器ID 的 NSNumber 包装
 */
@property (nonatomic, copy) NSArray <NSNumber *> *failServerIds;

@end


NS_ASSUME_NONNULL_END


