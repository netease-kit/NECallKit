//
//  NIMQChatCreateChannelParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  创建频道的类型
 */
@interface NIMQChatCreateChannelParam : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 名称
 */
@property (nonatomic, copy)   NSString *name;

/**
 * 主题
 */
@property (nonatomic, copy)   NSString *topic;

/**
 * 自定义扩展
 */
@property (nonatomic, copy)   NSString *custom;

/**
 * 类型：0-消息频道，1音视频频道，100自定义频道
 */
@property (nonatomic, assign) NIMQChatChannelType type;

/**
 * 查看模式
 */
@property (nonatomic, assign) NIMQChatChannelViewMode viewMode;

/**
 * 对某些资料内容另外的反垃圾的业务ID
 */
@property (nonatomic, copy)    NSString *antispamBusinessId;

/**
 * 频道分组id，传categoryId和NIMQChatChannelSyncModeSync时，viewMode将不生效
 */
@property (nonatomic, assign) unsigned long long categoryId;

/**
 * 是否与频道分组配置同步,传categoryId和NIMQChatChannelSyncModeSync时，viewMode将不生效
 */
@property (nonatomic, assign) NIMQChatChannelSyncMode syncMode;

/**
 * 游客可见模式
 */
@property (nonatomic, assign) NIMQChatVisitorMode visitorMode;

@end


NS_ASSUME_NONNULL_END
