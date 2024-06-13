//
//  NIMQChatChannelCategory.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"
NS_ASSUME_NONNULL_BEGIN
/**
 * 频道分组
 */
@interface NIMQChatChannelCategory : NSObject

/**
 * 频道id
 */
@property (nonatomic, assign) unsigned long long categoryId;

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
 * 自定义扩展
 */
@property (nonatomic, copy)   NSString *custom;

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
 * 频道数量
 */
@property (nonatomic, assign) NSInteger channelNumber;

@end

NS_ASSUME_NONNULL_END
