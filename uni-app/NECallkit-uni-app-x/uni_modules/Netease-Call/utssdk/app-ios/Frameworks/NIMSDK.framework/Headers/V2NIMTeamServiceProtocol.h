//
//  V2NIMTeamServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMTeamRefer;
@class V2NIMTeam;
@class V2NIMTeamMember;

@class V2NIMCreateTeamParams;
@class V2NIMCreateTeamResult;
@class V2NIMUpdateTeamInfoParams;
@class V2NIMUpdatedTeamInfo;

@class V2NIMUpdateSelfMemberInfoParams;
@class V2NIMTeamMemberQueryOption;
@class V2NIMTeamMemberListResult;

@class V2NIMTeamInviteParams;

@class V2NIMTeamJoinActionInfo;
@class V2NIMTeamJoinActionInfoQueryOption;
@class V2NIMTeamJoinActionInfoResult;

@class V2NIMTeamMemberSearchOption;
@class V2NIMTeamMemberSearchResult;
@class V2NIMTeamSearchParams;
@class V2NIMSearchTeamMemberParams;
    
@class V2NIMAntispamConfig;
@class V2NIMUpdateMemberNickParams;

@protocol V2NIMTeamListener;

/// 群组类型
typedef NS_ENUM(NSInteger, V2NIMTeamType) {
    V2NIM_TEAM_TYPE_INVALID                           = 0,  ///< 无效类型
    V2NIM_TEAM_TYPE_NORMAL                            = 1,  ///< 高级群/讨论组
    V2NIM_TEAM_TYPE_SUPER                             = 2,  ///< 超大群
};

/// 申请入群模式
typedef NS_ENUM(NSInteger, V2NIMTeamJoinMode) {
    V2NIM_TEAM_JOIN_MODE_FREE                         = 0,  ///< 自由加入，无须验证
    V2NIM_TEAM_JOIN_MODE_APPLY                        = 1,  ///< 需申请，群主或管理同意后加入
    V2NIM_TEAM_JOIN_MODE_INVITE                       = 2,  ///< 私有群，不接受申请，仅能通过邀请方式入群
};

/// 被邀请人同意入群模式
typedef NS_ENUM(NSInteger, V2NIMTeamAgreeMode) {
    V2NIM_TEAM_AGREE_MODE_AUTH                        = 0,  ///< 需要被邀请方同意（默认值）
    V2NIM_TEAM_AGREE_MODE_NO_AUTH                     = 1,  ///< 不需要被邀请人同意
};

/// 邀请入群模式
typedef NS_ENUM(NSInteger, V2NIMTeamInviteMode) {
    V2NIM_TEAM_INVITE_MODE_MANAGER                    = 0,  ///< 群主，管理员可以邀请其他人入群
    V2NIM_TEAM_INVITE_MODE_ALL                        = 1,  ///< 所有人都可以邀请其他人入群
};

/// 群组资料修改模式
typedef NS_ENUM(NSInteger, V2NIMTeamUpdateInfoMode) {
    V2NIM_TEAM_UPDATE_INFO_MODE_MANAGER               = 0,  ///< 群主/管理员可以修改群组资料
    V2NIM_TEAM_UPDATE_INFO_MODE_ALL                   = 1,  ///< 所有人均可以修改群组资料
};

/// 群组禁言模式
typedef NS_ENUM(NSInteger, V2NIMTeamChatBannedMode) {
    V2NIM_TEAM_CHAT_BANNED_MODE_NONE                  = 0,  ///< 不禁言，群组成员可以自由发言
    V2NIM_TEAM_CHAT_BANNED_MODE_BANNED_NORMAL         = 1,  ///< 普通成员禁言，不包括管理员，群主
    V2NIM_TEAM_CHAT_BANNED_MODE_BANNED_ALL            = 3,  ///< 全员禁言，群组所有成员都被禁言， 该状态只能OpenApi发起
};

/// 群组扩展字段修改模式
typedef NS_ENUM(NSInteger, V2NIMTeamUpdateExtensionMode) {
    V2NIM_TEAM_UPDATE_EXTENSION_MODE_MANAGER          = 0,  ///< 群主/管理员可以修改群组扩展字段
    V2NIM_TEAM_UPDATE_EXTENSION_MODE_ALL              = 1,  ///< 所有人均可以修改群组扩展字段
};

/// 群组成员角色
typedef NS_ENUM(NSInteger, V2NIMTeamMemberRole) {
    V2NIM_TEAM_MEMBER_ROLE_NORMAL                     = 0,  ///< 普通成员
    V2NIM_TEAM_MEMBER_ROLE_OWNER                      = 1,  ///< 群组拥有者
    V2NIM_TEAM_MEMBER_ROLE_MANAGER                    = 2,  ///< 群组管理员
};

/// 群组成员角色查询类型
typedef NS_ENUM(NSInteger, V2NIMTeamMemberRoleQueryType) {
    V2NIM_TEAM_MEMBER_ROLE_QUERY_TYPE_ALL             = 0,  ///< 所有成员
    V2NIM_TEAM_MEMBER_ROLE_QUERY_TYPE_MANAGER         = 1,  ///< 群组管理员(包括群主)
    V2NIM_TEAM_MEMBER_ROLE_QUERY_TYPE_NORMAL          = 2,  ///< 普通成员
};

/// 群组成员角色查询类型
typedef NS_ENUM(NSInteger, V2NIMTeamJoinActionType) {
    V2NIM_TEAM_JOIN_ACTION_TYPE_APPLICATION           = 0,  ///< 申请入群
    V2NIM_TEAM_JOIN_ACTION_TYPE_REJECT_APPLICATION    = 1,  ///< 申请人收到管理员拒绝申请
    V2NIM_TEAM_JOIN_ACTION_TYPE_INVITATION            = 2,  ///< 邀请入群
    V2NIM_TEAM_JOIN_ACTION_TYPE_REJECT_INVITATION     = 3,  ///< 成员拒绝邀请入群
};

/// 成员入群操作处理状态
typedef NS_ENUM(NSInteger, V2NIMTeamJoinActionStatus) {
    V2NIM_TEAM_JOIN_ACTION_STATUS_INIT                = 0,  ///< 未处理
    V2NIM_TEAM_JOIN_ACTION_STATUS_AGREED              = 1,  ///< 已同意
    V2NIM_TEAM_JOIN_ACTION_STATUS_REJECTED            = 2,  ///< 已拒绝
    V2NIM_TEAM_JOIN_ACTION_STATUS_EXPIRED             = 3,  ///< 已过期
};

/// 成功接收创建群组结果回调
typedef void (^V2NIMCreateTeamResultCallback)(V2NIMCreateTeamResult *result);
/// 成功接收群组信息回调
typedef void (^V2NIMTeamInfoCallback)(V2NIMTeam *team);
/// 成功接收群组信息列表回调
typedef void (^V2NIMTeamInfoListCallback)(NSArray<V2NIMTeam *> *teamList);
/// 成功接收邀请成员加入群组回调
typedef void (^V2NIMTeamInviteMemberCallback)(NSArray<NSString *> *failedList);
/// 成功接收群组成员列表结果回调
typedef void (^V2NIMTeamMemberListResultCallback)(V2NIMTeamMemberListResult *result);
/// 成功接收群组成员列表回调
typedef void (^V2NIMTeamMemberListCallback)(NSArray<V2NIMTeamMember *> *memberList);
/// 成功接收群组成员邀请人结果回调
typedef void (^V2NIMTeamMemberInvitorResultCallback)(NSDictionary<NSString *, NSString *> *result);
/// 成功接收群加入相关信息回调
typedef void (^V2NIMTeamJoinActionInfoResultCallback)(V2NIMTeamJoinActionInfoResult *result);
/// 成功获取群申请/邀请未读数量回调
typedef void (^V2NIMTeamJoinActionInfoUnreadCountResultCallback)(NSInteger count);
/// 成功接收搜索群成员结果回调
typedef void (^V2NIMTeamMemberSearchResultCallback)(V2NIMTeamMemberSearchResult *result);
/// 成功接收群信息检索返回结果
typedef void (^V2NIMSearchTeamsCallback)(NSArray<V2NIMTeam *> *list);
/// 成功接收群成员信息检索返回结果
typedef void (^V2NIMSearchTeamMembersExCallback)(NSDictionary<V2NIMTeamRefer *, NSArray<V2NIMTeamMember *> *> *dict);

/// 群协议
@protocol V2NIMTeamService <NSObject>

/**
 *  创建群组
 *
 *  @param createTeamParams 创建参数
 *  @param inviteeAccountIds 邀请加入账号id列表
 *  @param postscript 邀请入群的附言
 *  @param antispamConfig 反垃圾配置
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)createTeam:(V2NIMCreateTeamParams *)createTeamParams
 inviteeAccountIds:(nullable NSArray<NSString *> *)inviteeAccountIds
        postscript:(nullable NSString *)postscript
    antispamConfig:(nullable V2NIMAntispamConfig *)antispamConfig
           success:(nullable V2NIMCreateTeamResultCallback)success
           failure:(nullable V2NIMFailureCallback)failure;

/**
 *  创建群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param updateTeamInfoParams 更新参数
 *  @param antispamConfig 反垃圾配置
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateTeamInfo:(NSString *)teamId
              teamType:(V2NIMTeamType)teamType
  updateTeamInfoParams:(V2NIMUpdateTeamInfoParams *)updateTeamInfoParams
        antispamConfig:(nullable V2NIMAntispamConfig *)antispamConfig
               success:(nullable V2NIMSuccessCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 *  退出群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)leaveTeam:(NSString *)teamId
         teamType:(V2NIMTeamType)teamType
          success:(nullable V2NIMSuccessCallback)success
          failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取群组信息
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamInfo:(NSString *)teamId
           teamType:(V2NIMTeamType)teamType
            success:(nullable V2NIMTeamInfoCallback)success
            failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取群组信息
 *  @discussion 1. 不做在群有效性校验 2. 以本地数据源为准， 如果没有则直接返回 3. 如果本地查询不存在，则请调用异步
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param error 接收错误对象
 *
 *  @return 返回群组信息
 */
- (V2NIMTeam *)getTeamInfo:(NSString *)teamId
                  teamType:(V2NIMTeamType)teamType
                     error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 *  根据群组id获取群组信息
 *
 *  @param teamIds 群组Id列表
 *  @param teamType 群组类型
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamInfoByIds:(NSArray<NSString *> *)teamIds
                teamType:(V2NIMTeamType)teamType
                 success:(nullable V2NIMTeamInfoListCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据群组id获取群组信息
 *  @discussion 1. 每次查询所有ID必须从属于同一群组类型 2. 不做在群有效性校验（在解散后，或者退出后依然能获取群信息）3. 只查本地，本地数据可能不全，如果需要查询最新所有快照，则使用异步接口
 *
 *  @param teamIds 群组Id列表
 *  @param teamType 群组类型
 *  @param error 接收错误对象
 *
 *  @return 返回群组信息列表
 */
- (NSArray<V2NIMTeam *> *)getTeamInfoByIds:(NSArray<NSString *> *)teamIds
                                  teamType:(V2NIMTeamType)teamType
                                     error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 *  解散群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)dismissTeam:(NSString *)teamId
           teamType:(V2NIMTeamType)teamType
            success:(nullable V2NIMSuccessCallback)success
            failure:(nullable V2NIMFailureCallback)failure;

/**
 *  邀请成员加入群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param inviteeAccountIds 邀请加入账号id列表
 *  @param postscript 邀请入群的附言
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)inviteMember:(NSString *)teamId
            teamType:(V2NIMTeamType)teamType
   inviteeAccountIds:(NSArray<NSString *> *)inviteeAccountIds
          postscript:(nullable NSString *)postscript
             success:(nullable V2NIMTeamInviteMemberCallback)success
             failure:(nullable V2NIMFailureCallback)failure;

/**
 *  邀请成员加入群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param inviteeParams 邀请入群的参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)inviteMemberEx:(NSString *)teamId
              teamType:(V2NIMTeamType)teamType
         inviteeParams:(V2NIMTeamInviteParams *)inviteeParams
               success:(nullable V2NIMTeamInviteMemberCallback)success
               failure:(nullable V2NIMFailureCallback)failure;

/**
 *  同意邀请入群
 *
 *  @param invitationInfo 邀请信息
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)acceptInvitation:(V2NIMTeamJoinActionInfo *)invitationInfo
                 success:(nullable V2NIMTeamInfoCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  拒绝邀请入群请求
 *
 *  @param invitationInfo 邀请信息
 *  @param postscript 拒绝邀请入群的附言
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)rejectInvitation:(V2NIMTeamJoinActionInfo *)invitationInfo
              postscript:(nullable NSString *)postscript
                 success:(nullable V2NIMSuccessCallback)success
                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  踢出群组成员
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param memberAccountIds 踢出群组的成员账号列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)kickMember:(NSString *)teamId
          teamType:(V2NIMTeamType)teamType
  memberAccountIds:(nullable NSArray<NSString *> *)memberAccountIds
           success:(nullable V2NIMSuccessCallback)success
           failure:(nullable V2NIMFailureCallback)failure;

/**
 *  申请加入群组
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param postscript 申请入群的附言
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)applyJoinTeam:(NSString *)teamId
             teamType:(V2NIMTeamType)teamType
           postscript:(nullable NSString *)postscript
              success:(nullable V2NIMTeamInfoCallback)success
              failure:(nullable V2NIMFailureCallback)failure;

/**
 *  接受入群申请请求
 *
 *  @param applicationInfo 申请信息
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)acceptJoinApplication:(V2NIMTeamJoinActionInfo *)applicationInfo
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  拒绝入群申请
 *
 *  @param applicationInfo 申请信息
 *  @param postscript 拒绝申请加入的附言
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)rejectJoinApplication:(V2NIMTeamJoinActionInfo *)applicationInfo
                   postscript:(nullable NSString *)postscript
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置成员角色
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param memberAccountIds 设置成员角色的账号id列表
 *  @param memberRole 设置新的角色类型
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateTeamMemberRole:(NSString *)teamId
                    teamType:(V2NIMTeamType)teamType
            memberAccountIds:(NSArray<NSString *> *)memberAccountIds
                  memberRole:(V2NIMTeamMemberRole)memberRole
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  移交群主
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountId 新群主的账号id
 *  @param leave 转让群主后，是否同时退出该群
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)transferTeamOwner:(NSString *)teamId
                 teamType:(V2NIMTeamType)teamType
                accountId:(NSString *)accountId
                    leave:(BOOL)leave
                  success:(nullable V2NIMSuccessCallback)success
                  failure:(nullable V2NIMFailureCallback)failure;

/**
 *  修改自己的群成员信息
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param memberInfoParams 更新参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateSelfTeamMemberInfo:(NSString *)teamId
                        teamType:(V2NIMTeamType)teamType
                memberInfoParams:(V2NIMUpdateSelfMemberInfoParams *)memberInfoParams
                         success:(nullable V2NIMSuccessCallback)success
                         failure:(nullable V2NIMFailureCallback)failure;

/**
 *  修改群成员昵称
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountId 被修改成员的账号id
 *  @param teamNick 被修改成员新的昵称
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateTeamMemberNick:(NSString *)teamId
                    teamType:(V2NIMTeamType)teamType
                   accountId:(NSString *)accountId
                    teamNick:(NSString *)teamNick
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  修改群成员昵称, 只有群主和管理员拥有此权限
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param nickParams 被修改成员新的昵称参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)updateTeamMemberNickEx:(NSString *)teamId
                      teamType:(V2NIMTeamType)teamType
                    nickParams:(V2NIMUpdateMemberNickParams *)nickParams
                       success:(nullable V2NIMSuccessCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;
/**
 *  设置群组聊天禁言模式
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param chatBannedMode 群组禁言模式
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setTeamChatBannedMode:(NSString *)teamId
                     teamType:(V2NIMTeamType)teamType
               chatBannedMode:(V2NIMTeamChatBannedMode)chatBannedMode
                      success:(nullable V2NIMSuccessCallback)success
                      failure:(nullable V2NIMFailureCallback)failure;

/**
 *  设置群组成员聊天禁言状态
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountId 群成员账号id
 *  @param chatBanned 群组中聊天是否被禁言
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)setTeamMemberChatBannedStatus:(NSString *)teamId
                             teamType:(V2NIMTeamType)teamType
                            accountId:(NSString *)accountId
                           chatBanned:(BOOL)chatBanned
                              success:(nullable V2NIMSuccessCallback)success
                              failure:(nullable V2NIMFailureCallback)failure;

/**
 * 设置群申请已读
 * 调用该方法，历史数据未读数据均标记为已读
 *
 * @param applicationInfo 加入申请的相关信息
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)setTeamJoinActionInfoRead:(nullable V2NIMTeamJoinActionInfo *)applicationInfo
                            success:(nullable V2NIMSuccessCallback)success
                              failure:(nullable V2NIMFailureCallback)failure;

/**
 * 获取群申请/邀请未读数量
 *
 * @param success 成功回调
 * @param failure 失败回调
 */
- (void)getTeamJoinActionInfoUnreadCount:(nullable V2NIMTeamJoinActionInfoUnreadCountResultCallback)success
                                 failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取当前已经加入的群组列表
 *
 *  @param teamTypes 群类型列表，nil或空列表表示获取所有
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getJoinedTeamList:(NSArray<NSNumber *> *)teamTypes
                  success:(nullable V2NIMTeamInfoListCallback)success
                  failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取当前已经加入的群组列表
 *
 *  @param teamTypes 群类型列表，nil或空列表表示获取所有
 *  @param error 接收错误对象
 *
 *  @return 返回群组列表
 */
- (NSArray<V2NIMTeam *> *)getJoinedTeamList:(NSArray<NSNumber *> *)teamTypes
                                      error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 *  获取当前自己的群组（自己是群主）列表
 *
 *  @param teamTypes 群类型列表，nil或空列表表示获取所有
 *  @param error 接收错误对象
 *
 *  @return 返回群组列表
 */
- (NSArray<V2NIMTeam *> *)getOwnerTeamList:(NSArray<NSNumber *> *)teamTypes
                                     error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 *  获取当前已经加入的群组个数
 *
 *  @param teamTypes 群类型列表，nil或空列表表示获取所有
 *
 *  @return 群组个数
 */
- (NSInteger)getJoinedTeamCount:(NSArray<NSNumber *> *)teamTypes;

/**
 *  获取自己所有加入的群的群成员信息
 *
 *  @param teamTypes 群组类型列表（元素类型为V2NIMTeamType）。1. 如果为nil，或者数组大小为0， 表示查询所有所有群类型，否则按输入群类型进行查询
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getJoinedTeamMembers:(nullable NSArray<NSNumber *> *)teamTypes
                     success:(nullable V2NIMTeamMemberListCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取群组成员列表
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param queryOption 群组成员查询选项
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamMemberList:(NSString *)teamId
                 teamType:(V2NIMTeamType)teamType
              queryOption:(V2NIMTeamMemberQueryOption *)queryOption
                  success:(nullable V2NIMTeamMemberListResultCallback)success
                  failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据账号id列表获取群组成员列表
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountIds 账号id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamMemberListByIds:(NSString *)teamId
                      teamType:(V2NIMTeamType)teamType
                    accountIds:(NSArray<NSString *> *)accountIds
                       success:(nullable V2NIMTeamMemberListCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据账号id列表获取群组成员列表
 *  @discussion 1. 只返回ID存在且合法的成员 2. 只查本地存在的数据源，如果查询数据不全， 请调用异步接口
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountIds 账号id列表
 *  @param error 接收错误对象
 *
 *  @return 返回群组成员列表
 */
- (NSArray<V2NIMTeamMember *> *)getTeamMemberListByIds:(NSString *)teamId
                                              teamType:(V2NIMTeamType)teamType
                                            accountIds:(NSArray<NSString *> *)accountIds
                                                 error:(V2NIMError * __autoreleasing _Nullable * _Nullable)error;

/**
 *  根据账号id列表获取群组成员邀请人
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountIds 账号id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamMemberInvitor:(NSString *)teamId
                    teamType:(V2NIMTeamType)teamType
                  accountIds:(NSArray<NSString *> *)accountIds
                     success:(nullable V2NIMTeamMemberInvitorResultCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  获取群加入相关信息
 *
 *  @param option 查询参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamJoinActionInfoList:(V2NIMTeamJoinActionInfoQueryOption *)option
                          success:(nullable V2NIMTeamJoinActionInfoResultCallback)success
                          failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据关键字搜索群信息
 *
 *  @param keyword 关键字
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)searchTeamByKeyword:(NSString *)keyword
                    success:(nullable V2NIMTeamInfoListCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  根据关键字搜索群成员
 *
 *  @param searchOption 搜索参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)searchTeamMembers:(V2NIMTeamMemberSearchOption *)searchOption
                  success:(nullable V2NIMTeamMemberSearchResultCallback)success
                  failure:(nullable V2NIMFailureCallback)failure;

/**
 *  全文检索群信息，可以指定是否检索群ID或者群名称
 *
 *  @param params 群信息检索参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)searchTeams:(V2NIMTeamSearchParams *)params
            success:(nullable V2NIMSearchTeamsCallback)success
            failure:(nullable V2NIMFailureCallback)failure;

/**
 *  全文检索群成员信息，可以指定是否检索群成员ID或者群成员昵称
 *
 *  @param params 群成员信息检索参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)searchTeamMembersEx:(V2NIMSearchTeamMemberParams *)params
                    success:(nullable V2NIMSearchTeamMembersExCallback)success
                    failure:(nullable V2NIMFailureCallback)failure;

/**
 *  群成员添加特别关注
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountIds 账号id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)addTeamMembersFollow:(NSString *)teamId
                    teamType:(V2NIMTeamType)teamType
                  accountIds:(NSArray<NSString *> *)accountIds
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  群成员移除特别关注
 *
 *  @param teamId 群组Id
 *  @param teamType 群组类型
 *  @param accountIds 账号id列表
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)removeTeamMembersFollow:(NSString *)teamId
                       teamType:(V2NIMTeamType)teamType
                     accountIds:(NSArray<NSString *> *)accountIds
                        success:(nullable V2NIMSuccessCallback)success
                        failure:(nullable V2NIMFailureCallback)failure;

/**
 * 清空所有群申请
 *
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)clearAllTeamJoinActionInfo:(nullable V2NIMSuccessCallback)success
                       failure:(nullable V2NIMFailureCallback)failure;

/**
 * 删除群申请
 *
 *  @param success  请求成功回调
 *  @param failure  请求失败回调
 */
- (void)deleteTeamJoinActionInfo:(V2NIMTeamJoinActionInfo *)applicationInfo
                     success:(nullable V2NIMSuccessCallback)success
                     failure:(nullable V2NIMFailureCallback)failure;

/**
 *  添加群监听
 *
 *  @param listener 群监听
 */
- (void)addTeamListener:(id<V2NIMTeamListener>)listener;

/**
 *  移除群监听
 *
 *  @param listener 群监听
 */
- (void)removeTeamListener:(id<V2NIMTeamListener>)listener;

@end

/// 群回调协议
@protocol V2NIMTeamListener <NSObject>

@optional

/**
 *  同步开始
 */
- (void)onSyncStarted;

/**
 *  同步完成
 */
- (void)onSyncFinished;

/**
 *  同步失败
 *
 *  @param error 错误
 */
- (void)onSyncFailed:(V2NIMError *)error;

/**
 *  群组创建回调
 *
 *  @param team 新创建的群组
 */
- (void)onTeamCreated:(V2NIMTeam *)team;

/**
 *  群组解散回调
 *
 *  @param team 解散的群组
 *
 *  @discussion 仅teamId和teamType字段有效
 */
- (void)onTeamDismissed:(V2NIMTeam *)team;

/**
 *  加入群组回调
 *
 *  @param team 加入的群组
 */
- (void)onTeamJoined:(V2NIMTeam *)team;

/**
 *  离开群组回调
 *
 *  @param team 离开的群组
 *  @param isKicked 是否被踢出群组
 *
 *  @discussion 主动离开群组或被管理员踢出群组
 */
- (void)onTeamLeft:(V2NIMTeam *)team
          isKicked:(BOOL)isKicked;

/**
 *  群组信息更新回调
 *
 *  @param team 更新信息群组
 */
- (void)onTeamInfoUpdated:(V2NIMTeam *)team;

/**
 *  群组成员加入回调
 *
 *  @param teamMembers 加入的群组成员列表
 */
- (void)onTeamMemberJoined:(NSArray<V2NIMTeamMember *> *)teamMembers;

/**
 *  群组成员被踢回调
 *
 *  @param operatorAccountId 操作账号id
 *  @param teamMembers teamMembers的群组成员列表
 */
- (void)onTeamMemberKicked:(NSString *)operatorAccountId
               teamMembers:(NSArray<V2NIMTeamMember *> *)teamMembers;

/**
 *  群组成员退出回调
 *
 *  @param teamMembers 退出的群组成员列表
 */
- (void)onTeamMemberLeft:(NSArray<V2NIMTeamMember *> *)teamMembers;

/**
 *  群组成员信息变更回调
 *
 *  @param teamMembers 信息变更的群组成员列表
 */
- (void)onTeamMemberInfoUpdated:(NSArray<V2NIMTeamMember *> *)teamMembers;

/**
 *  入群操作回调
 *
 *  @param joinActionInfo 入群操作信息
 */
- (void)onReceiveTeamJoinActionInfo:(V2NIMTeamJoinActionInfo *)joinActionInfo;

@end

/// 群摘要
@interface V2NIMTeamRefer : NSObject <NSCopying>

/// 群组id
@property(nonatomic,copy) NSString *teamId;

/// 群组类型
@property(nonatomic,assign) V2NIMTeamType teamType;

/**
 *  高级群摘要
 *
 *  @param teamId 群组id
 *
 *  @return 群摘要
 */
+ (instancetype)referWithNormalTeamId:(NSString *)teamId;

/**
 *  超大群摘要
 *
 *  @param teamId 群组id
 *
 *  @return 群摘要
 */
+ (instancetype)referWithSuperTeamId:(NSString *)teamId;

/**
 *  群摘要
 *
 *  @param teamId 群组id
 *  @param teamType 群类型
 *
 *  @return 群摘要
 */
+ (instancetype)referWithTeamId:(NSString *)teamId
                       teamType:(V2NIMTeamType)teamType;

@end

/// 群组
@interface V2NIMTeam : NSObject <NSCopying>

/// 群组id
@property(nonatomic,copy,readonly) NSString *teamId;

/// 群组类型
@property(nonatomic,assign,readonly) V2NIMTeamType teamType;

/// 群组名称
@property(nonatomic,copy,readonly) NSString *name;

/// 群组创建者/拥有者账号id
@property(nonatomic,copy,readonly) NSString *ownerAccountId;

/// 群组人数上限
@property(nonatomic,assign,readonly) NSInteger memberLimit;

/// 群组当前人数
@property(nonatomic,assign,readonly) NSInteger memberCount;

/// 群组创建时间
@property(nonatomic,assign,readonly) NSTimeInterval createTime;

/// 群组更新时间
@property(nonatomic,assign,readonly) NSTimeInterval updateTime;

/// 群组介绍
@property(nullable,nonatomic,copy,readonly) NSString *intro;

/// 群组公告
@property(nullable,nonatomic,copy,readonly) NSString *announcement;

/// 群组头像
@property(nullable,nonatomic,copy,readonly) NSString *avatar;

/// 服务端扩展字段
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

/// 客户自定义扩展
@property(nullable,nonatomic,copy,readonly) NSString *customerExtension;

/// 申请入群模式
@property(nonatomic,assign,readonly) V2NIMTeamJoinMode joinMode;

/// 被邀请人同意入群模式
@property(nonatomic,assign,readonly) V2NIMTeamAgreeMode agreeMode;

/// 邀请入群模式
@property(nonatomic,assign,readonly) V2NIMTeamInviteMode inviteMode;

/// 群组资料修改模式
@property(nonatomic,assign,readonly) V2NIMTeamUpdateInfoMode updateInfoMode;

/// 群组扩展字段修改模式
@property(nonatomic,assign,readonly) V2NIMTeamUpdateExtensionMode updateExtensionMode;

/// 群组禁言模式
@property(nonatomic,assign,readonly) V2NIMTeamChatBannedMode chatBannedMode;

/// 是否有效的群， 群存在且我在群组中
@property(nonatomic,assign,readonly) BOOL isValidTeam;

/// 是否有效的群
@property(nonatomic,assign,readonly) BOOL isTeamEffective;

@end

/// 群组成员
@interface V2NIMTeamMember : NSObject <NSCopying>

/// 群组id
@property(nonatomic,copy,readonly) NSString *teamId;

/// 群组类型
@property(nonatomic,assign,readonly) V2NIMTeamType teamType;

/// 群组成员账号id
@property(nonatomic,copy,readonly) NSString *accountId;

/// 群组成员类型
@property(nonatomic,assign,readonly) V2NIMTeamMemberRole memberRole;

/// 群组昵称
@property(nullable,nonatomic,copy,readonly) NSString *teamNick;

/// 服务端扩展字段
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

/// 入群时间
@property(nonatomic,assign,readonly) NSTimeInterval joinTime;

/// 成员信息更新时间
@property(nonatomic,assign,readonly) NSTimeInterval updateTime;

/// 入群邀请人，主动入群该字段为空
@property(nullable,nonatomic,copy,readonly) NSString *invitorAccountId;

/// 是否在群中，YES 在群组中，NO 不在群组中
@property(nonatomic,assign,readonly) BOOL inTeam;

/// 聊天是否被禁言，YES 被禁言，NO 未禁言
@property(nonatomic,assign,readonly) BOOL chatBanned;

/// 特别关注成员账号id列表
@property(nullable,nonatomic,copy,readonly) NSArray<NSString *> *followAccountIds;

@end

/// 创建群组参数
@interface V2NIMCreateTeamParams : NSObject

/// 群组名称
@property(nonatomic,copy) NSString *name;

/// 群组类型
@property(nonatomic,assign) V2NIMTeamType teamType;

/// 群组人数上限
@property(nonatomic,assign) NSInteger memberLimit;

/// 群组介绍
@property(nullable,nonatomic,copy) NSString *intro;

/// 群组公告
@property(nullable,nonatomic,copy) NSString *announcement;

/// 群组头像
@property(nullable,nonatomic,copy) NSString *avatar;

/// 服务端扩展字段
@property(nullable,nonatomic,copy) NSString *serverExtension;

/// 申请入群模式
@property(nonatomic,assign) V2NIMTeamJoinMode joinMode;

/// 被邀请人同意入群模式
@property(nonatomic,assign) V2NIMTeamAgreeMode agreeMode;

/// 邀请入群模式
@property(nonatomic,assign) V2NIMTeamInviteMode inviteMode;

/// 群组资料修改模式
@property(nonatomic,assign) V2NIMTeamUpdateInfoMode updateInfoMode;

/// 群组扩展字段修改模式
@property(nonatomic,assign) V2NIMTeamUpdateExtensionMode updateExtensionMode;

/// 群组禁言模式
@property(nonatomic,assign) V2NIMTeamChatBannedMode chatBannedMode;

@end

/// 创建群组结果
@interface V2NIMCreateTeamResult : NSObject

/// 群组信息
@property(nullable,nonatomic,copy,readonly) V2NIMTeam *team;

/// 邀请失败账号id列表
@property(nullable,nonatomic,copy,readonly) NSArray<NSString *> *failedList;

@end

/// 修改群组信息参数
@interface V2NIMUpdateTeamInfoParams : NSObject

/// 群组名称
@property(nullable,nonatomic,copy) NSString *name;

/// 群组人数上限（当输出时，如果未被更新，此时值为0）
@property(nonatomic,assign) NSInteger memberLimit;

/// 群组介绍
@property(nullable,nonatomic,copy) NSString *intro;

/// 群组公告
@property(nullable,nonatomic,copy) NSString *announcement;

/// 群组头像
@property(nullable,nonatomic,copy) NSString *avatar;

/// 服务端扩展字段
@property(nullable,nonatomic,copy) NSString *serverExtension;

/// 申请入群模式（当输出时，如果未被更新，此时值为-1）
@property(nonatomic,assign) V2NIMTeamJoinMode joinMode;

/// 被邀请人同意入群模式（当输出时，如果未被更新，此时值为-1）
@property(nonatomic,assign) V2NIMTeamAgreeMode agreeMode;

/// 邀请入群模式（当输出时，如果未被更新，此时值为-1）
@property(nonatomic,assign) V2NIMTeamInviteMode inviteMode;

/// 群组资料修改模式（当输出时，如果未被更新，此时值为-1）
@property(nonatomic,assign) V2NIMTeamUpdateInfoMode updateInfoMode;

/// 群组扩展字段修改模式（当输出时，如果未被更新，此时值为-1）
@property(nonatomic,assign) V2NIMTeamUpdateExtensionMode updateExtensionMode;

@end

/// 群信息更新通知
@interface V2NIMUpdatedTeamInfo : NSObject

/// 群组名称，nil表示未更新
@property(nullable,nonatomic,copy,readonly) NSString *name;

/// 群组人数上限，0表示未更新
@property(nonatomic,assign,readonly) NSInteger memberLimit;

/// 群组介绍，nil表示未更新
@property(nullable,nonatomic,copy,readonly) NSString *intro;

/// 群组公告，nil表示未更新
@property(nullable,nonatomic,copy,readonly) NSString *announcement;

/// 群组头像，nil表示未更新
@property(nullable,nonatomic,copy,readonly) NSString *avatar;

/// 服务端扩展字段，nil表示未更新
@property(nullable,nonatomic,copy,readonly) NSString *serverExtension;

/// 申请入群模式，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamJoinMode joinMode;

/// 被邀请人同意入群模式，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamAgreeMode agreeMode;

/// 邀请入群模式，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamInviteMode inviteMode;

/// 群组资料修改模式，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamUpdateInfoMode updateInfoMode;

/// 群组扩展字段修改模式，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamUpdateExtensionMode updateExtensionMode;

/// 群组禁言状态，-1表示未更新
@property(nonatomic,assign,readonly) V2NIMTeamChatBannedMode chatBannedMode;

/// 客户自定义扩展， 由openApi设置
///    仅服务器API可以设置，内容透传
@property(nullable,nonatomic,copy,readonly) NSString *customerExtension;

@end

/// 修改自己的群成员信息参数
@interface V2NIMUpdateSelfMemberInfoParams : NSObject

/// 群组昵称
@property(nullable,nonatomic,copy) NSString *teamNick;

/// 服务端扩展字段
@property(nullable,nonatomic,copy) NSString *serverExtension;

/// 反垃圾配置
@property(nullable,nonatomic,copy) V2NIMAntispamConfig *antispamConfig;

@end

/// 修改群成员昵称相关参数
@interface V2NIMUpdateMemberNickParams : NSObject

/// 群组昵称
@property(nullable,nonatomic,copy) NSString *accountId;

/// 服务端扩展字段
@property(nullable,nonatomic,copy) NSString *teamNick;

/// 如果不审核，该配置不需要配置\
/// 主要针对群昵称进行检测
/// 如果开启了安全通，默认采用安全通，该配置不需要配置
/// 如果需要审核，且需要调整策略，则需要该配置
@property(nullable,nonatomic,copy) V2NIMAntispamConfig *antispamConfig;

@end

/// 群组成员查询参数
@interface V2NIMTeamMemberQueryOption : NSObject

/// 查询成员类型
@property(nonatomic,assign) V2NIMTeamMemberRoleQueryType roleQueryType;

/// 是否只返回聊天禁言成员列表，YES true： 只返回聊天禁言成员列表，NO 全部成员列表
@property(nonatomic,assign) BOOL onlyChatBanned;

/// 查询方向
@property(nonatomic,assign) V2NIMQueryDirection direction;

/// 分页偏移，首次传""，后续拉取采用上一次返回的nextToken
@property(nullable,nonatomic,copy) NSString *nextToken;

/// 分页拉取数量，不建议超过100
@property(nonatomic,assign) NSInteger limit;

@end

/// 群组成员列表结果
@interface V2NIMTeamMemberListResult : NSObject

/// 数据是否拉取完毕
@property(nonatomic,assign,readonly) BOOL finished;

/// 下一次查询的偏移量
@property(nullable,nonatomic,copy,readonly) NSString *nextToken;

/// 群组成员列表
@property(nullable,nonatomic,copy,readonly) NSArray<V2NIMTeamMember *> *memberList;

@end

@interface V2NIMTeamInviteParams : NSObject

/// 被邀请加入群的成员账号列表
@property (nonatomic, copy) NSArray<NSString *> *inviteeAccountIds;

/// 邀请入群的附言
@property (nonatomic, copy, nullable) NSString *postscript;

/// 邀请入群的扩展字段，暂不支持超大群
@property (nonatomic, copy, nullable) NSString *serverExtension;

@end

/// 入群操作信息
@interface V2NIMTeamJoinActionInfo : NSObject

/// 入群操作类型
@property(nonatomic,assign) V2NIMTeamJoinActionType actionType;

/// 群组id
@property(nonatomic,copy) NSString *teamId;

/// 群组类型
@property(nonatomic,assign) V2NIMTeamType teamType;

/// 操作账号id
@property(nonatomic,copy) NSString *operatorAccountId;

/// 附言
@property(nonatomic,copy) NSString *postscript;

/// 时间戳
@property(nonatomic,assign) NSTimeInterval timestamp;

/// 操作状态
@property(nonatomic,assign) V2NIMTeamJoinActionStatus actionStatus;

/// 邀请入群的扩展字段
@property(nonatomic,copy) NSString *serverExtension;

/// 是否已读
@property (nonatomic,assign) BOOL read;

@end

/// 群加入相关信息查询参数
@interface V2NIMTeamJoinActionInfoQueryOption : NSObject

/// 入群操作类型列表，输入类型为V2NIMTeamJoinActionType
@property(nullable,nonatomic,copy) NSArray<NSNumber *> *types;

/// 查询偏移，首次传0， 下一次传上一次返回的offset，默认0
@property(nonatomic,assign) NSInteger offset;

/// 查询数量，默认50
@property(nonatomic,assign) NSInteger limit;

/// 入群操作状态列表，输入类型为V2NIMTeamJoinActionStatus
@property(nullable,nonatomic,copy) NSArray<NSNumber *> *status;

@end

/// 群加入相关信息返回内容
@interface V2NIMTeamJoinActionInfoResult : NSObject

/// 查询返回的列表
@property(nullable,nonatomic,copy,readonly) NSArray<V2NIMTeamJoinActionInfo *> *infos;

/// 下一次的偏移量
@property(nonatomic,assign,readonly) NSInteger offset;

/// 查询j结束
@property(nonatomic,assign,readonly) BOOL finished;

@end

/// 群成员搜索参数
@interface V2NIMTeamMemberSearchOption : NSObject <NSCopying>

/// 搜索关键词，不为空
@property(nonatomic,strong) NSString *keyword;

/// 是否搜索用户账号
@property(nonatomic,assign) BOOL searchAccountId;

/// 群组类型
@property(nonatomic,assign) V2NIMTeamType teamType;

/// 群组id， 如果不传则检索所有群， 如果需要检索特定的群， 则需要同时传入teamId+teamType
@property(nullable,nonatomic,strong) NSString *teamId;

/// 起始位置，首次传@""， 后续传上次返回的nextToken
@property(nonatomic,strong) NSString *nextToken;

/// V2NIM_SORT_ORDER_DESC 按joinTime降序，V2NIM_SORT_ORDER_ASC 按joinTime升序
@property(nonatomic,assign) V2NIMSortOrder order;

/// 查询成员的个数。 默认10。
@property(nonatomic,assign) NSInteger limit;

/// 初始传入的nextToken
@property(class,nonatomic,strong) NSString *initNextToken;

@end

/// 成员列表搜索结果
@interface V2NIMTeamMemberSearchResult : NSObject

/// 返回列表
@property(nullable,nonatomic,strong,readonly) NSArray<V2NIMTeamMember *> *memberList;

/// 下次搜索偏移量，finished = YES 时，nextToken置为“”
@property(nonatomic,strong,readonly) NSString *nextToken;

/// 查询是否结束
@property(nonatomic,assign,readonly) BOOL finished;

@end

///  群信息检索参数
@interface V2NIMTeamSearchParams : NSObject

/// 最多支持 5 个，必须设置。
@property (nonatomic,strong) NSArray<NSString *> *keywordList;

/// 指定关键字列表匹配类型。可设置为 “或” 关系搜索，或 “与” 关系搜索。取值分别为 V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR 和 V2NIM_SEARCH_KEYWORD_MATH_TYPE_AND。默认为V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR “或” 关系搜索。
@property (nonatomic,assign) V2NIMSearchKeywordMathType keywordMatchType;

/// 群类型（元素类型为V2NIMTeamType），nil或空列表表示获取所有群类型。类型为
@property (nonatomic,strong,nullable) NSArray<NSNumber *> *teamTypes;

/// 单次检索返回的数量。 默认20。必须为正数，本地检索接口忽略此参数。
@property(nonatomic,assign) NSInteger limit;

/// 起始位置，首次传“”， 后续传上次返回的nextToken。本地检索接口忽略此参数。
@property(nullable,nonatomic,strong) NSString *nextToken;

@end

///   群成员检索参数
@interface V2NIMSearchTeamMemberParams : NSObject

/// 最多支持 5 个，必须设置。
@property (nonatomic,strong) NSArray<NSString *> *keywordList;

/// 指定关键字列表匹配类型。可设置为 “或” 关系搜索，或 “与” 关系搜索。取值分别为 V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR 和 V2NIM_SEARCH_KEYWORD_MATH_TYPE_AND。默认为V2NIM_SEARCH_KEYWORD_MATH_TYPE_OR “或” 关系搜索。
@property (nonatomic,assign) V2NIMSearchKeywordMathType keywordMatchType;

/// 需要检索的群ID列表。
@property (nonatomic,strong) NSArray<V2NIMTeamRefer *> *teamRefers;

/// 是否搜索用户账号。默认NO。（searchAccountId和searchTeamNick不能同时为NO）
@property (nonatomic,assign) BOOL searchAccountId;

/// 是否搜索群昵称。默认YES。（searchAccountId和searchTeamNick不能同时为NO）
@property (nonatomic,assign) BOOL searchTeamNick;

/// 单次检索返回的数量。 默认20。必须为正数，本地检索接口忽略此参数。
@property(nonatomic,assign) NSInteger limit;

/// 起始位置，首次传“”， 后续传上次返回的nextToken。本地检索接口忽略此参数。
@property(nullable,nonatomic,strong) NSString *nextToken;

@end

NS_ASSUME_NONNULL_END
