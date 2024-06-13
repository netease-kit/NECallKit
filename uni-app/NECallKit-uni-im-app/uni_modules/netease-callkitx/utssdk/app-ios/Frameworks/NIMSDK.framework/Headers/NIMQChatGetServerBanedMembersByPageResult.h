
//
//  NIMQChatGetServerBanedMembersByPageResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMQChatServerMemberBanInfo;

/**
 *  分页获取服务器封禁名单的结果
 */
@interface NIMQChatGetServerBanedMembersByPageResult : NSObject

/**
 * 是否还有下一页数据
 */
@property (nonatomic, assign) BOOL hasMore;

/**
 * 下一页的起始时间戳
 */
@property (nonatomic, assign) NSTimeInterval nextTimetag;

/**
 * 成员列表
 */
@property (nonatomic, copy) NSArray <NIMQChatServerMemberBanInfo *> *memberArray;

@end



@interface NIMQChatServerMemberBanInfo : NSObject

/**
 * 服务器id
 */
@property (nonatomic, assign) unsigned long long  serverId;
/**
 * 应用id
 */
@property (nonatomic, assign) unsigned long long  appId;

/**
 * 用户accid
 */
@property (nonatomic, copy) NSString *accId;

/**
 * 自定义扩展
 */
@property (nonatomic, copy) NSString  *custom;

/**
 * 封禁时间
 */
@property (nonatomic, assign) NSTimeInterval banTime;

/**
 * 有效标志
 */
@property (nonatomic, assign) BOOL validFlag;

/**
 * 创建时间
 */
@property (nonatomic, assign) NSTimeInterval  createTime;

/**
 * 更新时间
 */
@property (nonatomic, assign) NSTimeInterval  updateTime;


@end

NS_ASSUME_NONNULL_END


