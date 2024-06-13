//
//  NIMQChatRTCUpdateChannelInfoParam.h
//  NIMLib
//
//  Created by lihuang on 2022/6/18.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatRTCUpdateChannelInfoParam : NSObject

/**
 *  服务器ID
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 *  频道ID
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 *  人数限制
 */
@property (nonatomic, assign) NSInteger limit;

/**
 *  音频设置
 */
@property (nonatomic, copy) NSString *audioConfig;

/**
 *  视频设置
 */
@property (nonatomic, copy) NSString *videoConfig;

@end

NS_ASSUME_NONNULL_END
