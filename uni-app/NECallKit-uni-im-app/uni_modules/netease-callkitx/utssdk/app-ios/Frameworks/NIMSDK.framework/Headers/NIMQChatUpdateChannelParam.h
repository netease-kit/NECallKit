//
//  NIMQChatUpdateChannelParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@class NIMQChatChannel;

NS_ASSUME_NONNULL_BEGIN

/**
 *  修改频道信息的参数
 */
@interface NIMQChatUpdateChannelParam : NSObject

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 名称
 */
@property (nullable, nonatomic, copy)   NSString *name;

/**
 * 主题
 */
@property (nullable, nonatomic, copy)   NSString *topic;

/**
 * 自定义扩展
 */
@property (nullable, nonatomic, copy)   NSString *custom;

/**
 * 查看模式
 */
@property (nonatomic, assign)   NIMQChatChannelViewMode viewMode;

/**
 * 游客可见模式
 */
@property (nonatomic, assign) NIMQChatVisitorMode visitorMode;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;


@end


NS_ASSUME_NONNULL_END
