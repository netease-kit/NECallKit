//
//  NIMQChatRTCChannelInfo.h
//  NIMLib
//
//  Created by lihuang on 2022/6/16.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatRTCChannelInfo : NSObject <NSCopying>

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
