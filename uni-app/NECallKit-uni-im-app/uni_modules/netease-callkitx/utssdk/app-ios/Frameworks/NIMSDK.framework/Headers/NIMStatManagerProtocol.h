//
//  NIMStatManager.h
//  NIMLib
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMSessionStatOption;
@class NIMSessionStatContext;
@class NIMSessionStat;

NS_ASSUME_NONNULL_BEGIN

/**
 *  消息表中消息数量，不包括已经删除的（NSInteger）
 */
extern NSString *const NIMSessionStatKeyMessageCount;

/**
 *  消息表中消息数量，包括已经删除的（NSInteger）
 */
extern NSString *const NIMSessionStatKeyRawMessageCount;

/**
 *  在最近会话中（BOOL）
 */
extern NSString *const NIMSessionStatKeyInRecentSession;

/**
 *  会话统计回调block
 *  @param context  统计上下文信息
 *  @param stat 统计信息
 *  @param error    错误,如果成功则为nil
 *  @param stop 控制是否停止
 */
typedef void(^NIMSessionStatBlock)(NIMSessionStatContext* context,
                                   NIMSessionStat* __nullable stat,
                                   NSError* __nullable error,
                                   BOOL * stop);

/**
 *  统计协议
 */
@protocol NIMStatManager <NSObject>

/**
 *  会话统计
 *  @param option  统计选项
 *  @param receiver 统计信息接收block
 */
- (BOOL)statSessions:(nullable NIMSessionStatOption *)option
            receiver:(NIMSessionStatBlock)receiver;

@end

NS_ASSUME_NONNULL_END
