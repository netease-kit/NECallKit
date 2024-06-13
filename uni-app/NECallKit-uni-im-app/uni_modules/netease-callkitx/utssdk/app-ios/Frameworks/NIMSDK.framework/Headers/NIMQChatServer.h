//
//  NIMQChatServer.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatServer : NSObject
/**
 * 圈组服务器id
 */
@property (nonatomic, assign) unsigned long long serverId;

/**
 * 应用id
 */
@property (nonatomic, assign) NSInteger appId;

/**
 * 名称
 */
@property (nullable, nonatomic, copy) NSString *name;

/**
 * 图标
 */
@property (nullable, nonatomic, copy) NSString *icon;

/**
 * 自定义扩展
 */
@property (nullable, nonatomic, copy) NSString *custom;

/**
 * 所有者
 */
@property (nullable, nonatomic, copy) NSString *owner;

/**
 * 成员数
 */
@property (nonatomic, assign) NSInteger memberNumber;

/**
 * 邀请模式：0-邀请需要同意(默认),1-邀请不需要同意
 */
@property (nonatomic, assign) NIMQChatServerInviteMode inviteMode;

/**
 * 申请模式：0-申请不需要同意(默认)，1-申请需要同意
 */
@property (nonatomic, assign) NIMQChatServerApplyMode applyMode;

/**
 * 有效标志：0-无效，1-有效
 */
@property (nonatomic, assign) BOOL validFlag;

/**
 * 创建时间
 */
@property (nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间
 */
@property (nonatomic, assign) NSTimeInterval updateTime;

/**
 * 频道数
 */
@property (nonatomic, assign) NSInteger channelNumber;

/**
 * 频道分组的数量
 */
@property (nonatomic, assign) NSInteger catogeryNumber;

/**
 * 服务器搜索类型，客户自定义：比如服务器行业类型等,大于0的正整数
 */
@property (nullable, nonatomic, copy) NSNumber *searchType;

/**
 * 服务器是否允许被搜索，默认允许
 */
@property (nonatomic, assign) BOOL searchEnable;

/**
 * 自定义排序权重值
 */
@property (nonatomic, assign) long reorderWeight;

@end

NS_ASSUME_NONNULL_END
