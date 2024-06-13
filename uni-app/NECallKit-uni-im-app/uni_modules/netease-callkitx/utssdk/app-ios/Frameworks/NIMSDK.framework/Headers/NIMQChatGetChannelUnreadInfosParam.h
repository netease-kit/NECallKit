//
//  NIMQChatGetChannelUnreadInfosParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatChannelIdInfo;

/**
 *  查询未读信息的参数
 */
@interface NIMQChatGetChannelUnreadInfosParam : NSObject

/**
 * 操作的对象：频道ID列表
 */
@property (nonnull, nonatomic, copy) NSArray<NIMQChatChannelIdInfo *> *targets;

- (instancetype)initWithTargets:(NSArray<NIMQChatChannelIdInfo *> *)targets;

@end

NS_ASSUME_NONNULL_END
