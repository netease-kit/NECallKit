//
//  NIMQChatFetchQuickCommentsByMsgsResult.h
//  NIMLib
//
//  Created by Evang on 2022/3/22.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatChannelIdInfo;

NS_ASSUME_NONNULL_BEGIN
/**
 * 以游客身份加入服务器的结果
 */
@interface NIMQChatSubscribeChannelAsVisitorResult : NSObject <NSCopying>

/**
 * 订阅失败的频道id信息列表
 */
@property (nonatomic, nullable, readonly, copy) NSArray<NIMQChatChannelIdInfo *>* failedChannelInfos;
@end

NS_ASSUME_NONNULL_END
