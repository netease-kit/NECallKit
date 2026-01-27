//
//  NIMTeamManagerDelegate.h
//  NIMSDK
//
//  Created by Netease on 2019/7/19.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMTeam;

NS_ASSUME_NONNULL_BEGIN

@protocol NIMTeamManagerDelegate <NSObject>

@optional
/**
 *  群组增加回调
 *
 *  @param team 添加的群组
 */
- (void)onTeamAdded:(NIMTeam *)team;

/**
 *  群组更新回调
 *
 *  @param team 更新的群组
 */
- (void)onTeamUpdated:(NIMTeam *)team;

/**
 *  群组移除回调
 *
 *  @param team 被移除的群组
 */
- (void)onTeamRemoved:(NIMTeam *)team;

/**
 *  群组成员变动回调,包括数量增减以及成员属性变动
 *
 *  @param team 变动的群组
 */
- (void)onTeamMemberChanged:(NIMTeam *)team;

/**
 *  群组成员变动回调,包含有更新的群成员ID
 *
 *  @param team 变动的群组
 *  @param memberIDs 变动的成员ID
 */
- (void)onTeamMemberUpdated:(NIMTeam *)team
                withMembers:(nullable NSArray<NSString *> *)memberIDs;

/**
 *  群组成员变动回调,包含被移除的群成员ID
 *
 *  @param team 变动的群组
 *  @param memberIDs 变动的成员ID
 */
- (void)onTeamMemberRemoved:(NIMTeam *)team
                withMembers:(nullable NSArray<NSString *> *)memberIDs;

@end

NS_ASSUME_NONNULL_END
