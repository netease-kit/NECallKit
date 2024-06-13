//
//  NIMQChatUpdateCategoryInfoOfChannelParam.h
//  NIMLib
//
//  Created by Evang on 2022/5/9.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  修改频道中分组信息的参数
 */
@interface NIMQChatUpdateCategoryInfoOfChannelParam : NSObject
/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long categoryId;

/**
 * 是否与频道分组配置同步
 */
@property (nonatomic, assign) NIMQChatChannelSyncMode syncMode;

@end

NS_ASSUME_NONNULL_END

