//
//  NIMQChatMarkServerReadParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@class NIMQChatChannelIdInfo;

NS_ASSUME_NONNULL_BEGIN

/**
 *  设置以游客身份订阅频道的参数
 */
@interface NIMQChatSubscribeChannelAsVisitorParam: NSObject <NSCopying>

/**
 * 操作类型
 */
@property(nonatomic, assign) NIMQChatSubscribeOperationType operateType;

/**
 * 圈组服务器ID列表
 */
@property (nonatomic, copy, nonnull) NSArray<NIMQChatChannelIdInfo *> *channelIdInfos;
@end


NS_ASSUME_NONNULL_END


