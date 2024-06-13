//
//  NIMQChatChannel.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"
NS_ASSUME_NONNULL_BEGIN
/**
 * 频道
 */
@interface NIMQChatChannel : NSObject

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long channelId;

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 应用id
 */
@property (nonatomic, assign) NSInteger appId;

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
 * 类型：0-消息频道，100自定义频道
 */
@property (nonatomic, assign) NIMQChatChannelType type;

/**
 * 有效标志：0-无效，1-有效
 */
@property (nonatomic, assign) BOOL validflag;

/**
 * 创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;
/**
 * 所有者
 */
@property (nonatomic, copy) NSString *owner;

/**
 * 查看模式
 */
@property (nonatomic, assign) NIMQChatChannelViewMode viewMode;

/**
 * 频道分组id
 */
@property (nonatomic, assign) unsigned long long categoryId;

/**
 * 是否与频道分组配置同步
 */
@property (nonatomic, assign) NIMQChatChannelSyncMode syncMode;

/**
 * 自定义排序权重值
 */
@property (nonatomic, assign) long reorderWeight;

/**
 * 游客可见模式
 */
@property (nonatomic, assign) NIMQChatVisitorMode visitorMode;

@end

NS_ASSUME_NONNULL_END
