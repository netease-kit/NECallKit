//
//  NIMQChatChannelCategoryIdInfo.h
//  NIMLib
//
//  Created by Evang on 2022/4/28.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 * 频道分组id信息
 */
@interface NIMQChatChannelCategoryIdInfo : NSObject

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long categoryId;

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

@end

NS_ASSUME_NONNULL_END
