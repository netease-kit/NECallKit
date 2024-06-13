//
//  SuperTeamManagerProtocol.h
//  NIMLib
//
//  Created by He on 2019/5/14.
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMTeamDefs.h"
#import "NIMTeamMember.h"
#import "NIMTeamManagerDelegate.h"
#import "NIMTeam.h"
#import "NIMTeamFetchMemberOption.h"

NS_ASSUME_NONNULL_BEGIN
/**
 *  超大群接口
 */
@protocol NIMSuperTeamManager  <NSObject>

/**
 *  获取所有群组
 *
 *  @return 返回所有群组
 */
- (nullable NSArray<NIMTeam *> *)allMyTeams;

/**
 *  根据群组 ID 获取具体的群组信息
 *
 *  @param teamId 群组 ID
 *
 *  @return 群组信息
 *  @discussion 如果自己不在群里，则该接口返回 nil
 */
- (nullable NIMTeam *)teamById:(NSString *)teamId;

/**
 *  根据群组ID判断是否是我所在的群
 *
 *  @param teamId 群组ID
 *
 *  @return 是否在此群组
 */
- (BOOL)isMyTeam:(NSString *)teamId;

/**
 *  退出群组
 *
 *  @param teamId     群组ID
 *  @param completion 完成后的回调
 */
- (void)quitTeam:(NSString *)teamId
      completion:(nullable NIMTeamHandler)completion;

/**
 *  邀请用户入群
 *
 *  @param users       用户ID列表
 *  @param teamId      群组ID
 *  @param completion  完成后的回调
 *  @discussion        群主和管理员可以邀请用户
 */
- (void)addUsers:(NSArray<NSString *>  *)users
          toTeam:(NSString *)teamId
      postscript:(nullable NSString *)postscript
          attach:(nullable NSString *)attach
      completion:(nullable NIMTeamMemberHandler)completion;

/**
 *  从群组内移除成员
 *
 *  @param users       需要移除的用户ID列表
 *  @param teamId      群组ID
 *  @param completion  完成后的回调
 *  @discussion        群主和管理员可以移除成员，管理员不能踢群主，不能踢管理员。
 */
- (void)kickUsers:(NSArray<NSString *> *)users
         fromTeam:(NSString *)teamId
       completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群组名称
 *
 *  @param teamName   群组名称
 *  @param teamId     群组ID
 *  @param completion 完成后的回调
 */
- (void)updateTeamName:(NSString *)teamName
                teamId:(NSString *)teamId
            completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群组头像
 *
 *  @param teamAvatarUrl 群组头像Url
 *  @param teamId        群组ID
 *  @param completion    完成后的回调
 */
- (void)updateTeamAvatar:(NSString *)teamAvatarUrl
                  teamId:(NSString *)teamId
              completion:(nullable NIMTeamHandler)completion;


/**
 *  更新群组验证方式
 *
 *  @param joinMode   验证方式
 *  @param teamId     群组ID
 *  @param completion 完成后的回调
 */
- (void)updateTeamJoinMode:(NIMTeamJoinMode)joinMode
                    teamId:(NSString *)teamId
                completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群组被邀请人验证方式
 *
 *  @param beInviteMode 邀请方式
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateTeamBeInviteMode:(NIMTeamBeInviteMode)beInviteMode
                        teamId:(NSString *)teamId
                    completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群介绍
 *
 *  @param intro       群介绍
 *  @param teamId      群组ID
 *  @param completion  完成后的回调
 */
- (void)updateTeamIntro:(NSString *)intro
                 teamId:(NSString *)teamId
             completion:(nullable NIMTeamHandler)completion;


/**
 *  更新群公告
 *
 *  @param announcement 群公告
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateTeamAnnouncement:(NSString *)announcement
                        teamId:(NSString *)teamId
                    completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群自定义信息
 *
 *  @param info         群自定义信息
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateTeamCustomInfo:(NSString *)info
                      teamId:(NSString *)teamId
                  completion:(nullable NIMTeamHandler)completion;

/**
 *  更新群信息
 *
 *  @param values      需要更新的群信息键值对
 *  @param teamId      群组ID
 *  @param completion  完成后的回调
 *  @discussion   这个接口可以一次性修改群的多个属性,如名称,公告等,传入的数据键值对是 {@(NIMSuperTeamUpdateTag) : NSString},无效数据将被过滤.群主和管理员可修改
 */
- (void)updateTeamInfos:(NSDictionary<NSNumber *,NSString *> *)values
                 teamId:(NSString *)teamId
             completion:(nullable NIMTeamHandler)completion;

/**
 *  群申请
 *
 *  @param teamId     群组ID
 *  @param message    申请消息
 *  @param completion 完成后的回调
 */
- (void)applyToTeam:(NSString *)teamId
            message:(NSString *)message
         completion:(nullable NIMTeamApplyHandler)completion;


/**
 *  通过群申请
 *
 *  @param teamId       群组ID
 *  @param userId       申请的用户ID
 *  @param completion   完成后的回调
 */
- (void)passApplyToTeam:(NSString *)teamId
                 userId:(NSString *)userId
             completion:(nullable NIMTeamApplyHandler)completion;

/**
 *  拒绝群申请
 *
 *  @param teamId       群组ID
 *  @param userId       申请的用户ID
 *  @param rejectReason 拒绝理由
 *  @param completion   完成后的回调
 */
- (void)rejectApplyToTeam:(NSString *)teamId
                   userId:(NSString *)userId
             rejectReason:(NSString*)rejectReason
               completion:(nullable NIMTeamHandler)completion;

/**
 *  更新成员群昵称
 *
 *  @param userId       群成员ID
 *  @param newNick      新的群成员昵称
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateUserNick:(NSString *)userId
               newNick:(NSString *)newNick
                inTeam:(NSString *)teamId
            completion:(nullable NIMTeamHandler)completion;

/**
 *  更新自己群自定义属性
 *
 *  @param newInfo      新的自定义属性
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateMyCustomInfo:(NSString *)newInfo
                    inTeam:(NSString *)teamId
                completion:(nullable NIMTeamHandler)completion;

/**
 *  添加管理员
 *
 *  @param teamId      群组ID
 *  @param users       需要添加为管理员的用户ID列表
 *  @param completion  完成后的回调
 */
- (void)addManagersToTeam:(NSString *)teamId
                    users:(NSArray<NSString *>  *)users
               completion:(nullable NIMTeamHandler)completion;

/**
 *  移除管理员
 *
 *  @param teamId     群组ID
 *  @param users      需要移除管理员的用户ID列表
 *  @param completion 完成后的回调
 */
- (void)removeManagersFromTeam:(NSString *)teamId
                         users:(NSArray<NSString *>  *)users
                    completion:(nullable NIMTeamHandler)completion;

/**
 *  移交群主
 *
 *  @param teamId     群组ID
 *  @param newOwnerId 新群主ID
 *  @param isLeave    是否同时离开群组
 *  @param completion 完成后的回调
 */
- (void)transferManagerWithTeam:(NSString *)teamId
                     newOwnerId:(NSString *)newOwnerId
                        isLeave:(BOOL)isLeave
                     completion:(nullable NIMTeamHandler)completion;

/**
 *  接受入群邀请
 *
 *  @param teamId     群组ID
 *  @param invitorId  邀请者ID
 *  @param completion 完成后的回调
 */
- (void)acceptInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                  completion:(nullable NIMTeamHandler)completion;


/**
 *  拒绝入群邀请
 *
 *  @param teamId       群组ID
 *  @param invitorId    邀请者ID
 *  @param rejectReason 拒绝原因
 *  @param completion   完成后的回调
 */
- (void)rejectInviteWithTeam:(NSString*)teamId
                   invitorId:(NSString*)invitorId
                rejectReason:(NSString*)rejectReason
                  completion:(nullable NIMTeamHandler)completion;

/**
 *  修改群通知状态
 *
 *  @param state        群通知状态
 *  @param teamId       群组ID
 *  @param completion   完成后的回调
 */
- (void)updateNotifyState:(NIMTeamNotifyState)state
                   inTeam:(NSString *)teamId
               completion:(nullable NIMTeamHandler)completion;

/**
 *  群通知状态
 *
 *  @param teamId 群Id
 *
 *  @return 群通知状态
 */
- (NIMTeamNotifyState)notifyStateForNewMsg:(NSString *)teamId;


/**
 *  群成员禁言
 *
 *  @param mute        是否禁言
 *  @param userIds     用户ID
 *  @param teamId      群组ID
 *  @param completion  经验操作完成后的回调
 *  @discussion   操作成功后，云信服务器会下发禁言的群通知消息
 */
- (void)updateMuteState:(BOOL)mute
                userIds:(NSArray<NSString *> *)userIds
                 inTeam:(NSString *)teamId
             completion:(nullable NIMTeamHandler)completion;

/**
 *  禁言群全体成员
 *
 *  @param mute        是否禁言
 *  @param teamId      群组ID
 *  @param completion  经验操作完成后的回调
 *  @discussion   操作成功后，云信服务器会下发禁言的群通知消息
 */
- (void)updateMuteState:(BOOL)mute
                inTeam:(NSString *)teamId
            completion:(nullable NIMTeamHandler)completion;

/**
 *  获取超大群组成员
 *
 *  @param teamId     群组ID
 *  @param completion 完成后的回调
 *  @discussion   绝大多数情况这个请求都是从本地读取缓存并同步返回，但是由于群成员信息量较大， SDK 采取的是登录后延迟拉取的策略
 *                考虑到用户网络等问题, SDK 有可能没有及时缓存群成员信息,那么这个请求将是个带网络请求的异步操作(增量请求)。
 *                同时这个接口会去请求本地没有缓存的群用户的资料信息，但不会触发 - (void)onUserInfoChanged: 回调。
 */
- (void)fetchTeamMembers:(NSString *)teamId
                  option:(NIMTeamFetchMemberOption *)option
              completion:(nullable NIMTeamMemberHandler)completion;

/**
 *  获取群内被禁言的成员列表
 *
 *  @param teamId     群组ID
 *  @param completion 完成后的回调
 *  @discussion   绝大多数情况这个请求都是从本地读取缓存并同步返回，但是由于群成员信息量较大， SDK 采取的是登录后延迟拉取的策略
 *                考虑到用户网络等问题, SDK 有可能没有及时缓存群成员信息,那么这个请求将是个带网络请求的异步操作(增量请求)。
 *                同时这个接口会去请求本地没有缓存的群用户的资料信息，但不会触发 - (void)onUserInfoChanged: 回调。
 */
- (void)fetchTeamMutedMembers:(NSString *)teamId
                   completion:(nullable NIMTeamMemberHandler)completion;

/**
 *  获取群信息
 *
 *  @param teamId      群组ID
 *  @param completion  完成后的回调
 */
- (void)fetchTeamInfo:(NSString *)teamId
           completion:(nullable NIMTeamFetchInfoHandler)completion;


/**
 *  获取单个群成员信息
 *
 *  @param userId 用户ID
 *  @param teamId 群组ID
 *  @return       返回成员信息
 *  @discussion   返回本地缓存的群成员信息，如果本地没有相应数据则返回 nil。
 */
- (nullable NIMTeamMember *)teamMember:(NSString *)userId
                                inTeam:(NSString *)teamId;

/**
 *  添加超大群组委托
 *
 *  @param delegate 群组委托
 */
- (void)addDelegate:(id<NIMTeamManagerDelegate>)delegate;

/**
 *  移除超大群组委托
 *
 *  @param delegate 群组委托
 */
- (void)removeDelegate:(id<NIMTeamManagerDelegate>)delegate;
@end


NS_ASSUME_NONNULL_END
