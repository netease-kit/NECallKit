//
//  V2NIMTeamServiceProtocol.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NIMBase.h"
#import "V2NIMMessageEnum.h"

NS_ASSUME_NONNULL_BEGIN

@class V2NIMTeam;
@class V2NIMTeamMember;

@class V2NIMCreateTeamParams;
@class V2NIMCreateTeamResult;
@class V2NIMUpdateTeamInfoParams;

@class V2NIMUpdateSelfMemberInfoParams;
@class V2NIMTeamMemberQueryOption;
@class V2NIMTeamMemberListResult;

@class V2NIMTeamJoinActionInfo;
@class V2NIMTeamJoinActionInfoQueryOption;
@class V2NIMTeamJoinActionInfoResult;

@class V2NIMAntispamConfig;

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
    V2NIM_TEAM_CHAT_BANNED_MODE_BANNED_ALL            = 2,  ///< 全员禁言，群组所有成员都被禁言， 该状态只能OpenApi发起
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
 *  获取当前已经加入的群组个数
 *
 *  @param teamTypes 群类型列表，nil或空列表表示获取所有
 *
 *  @return 群组个数
 */
- (NSInteger)getJoinedTeamCount:(NSArray<NSNumber *> *)teamTypes;

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
 *  @param queryOption 查询参数
 *  @param success 成功回调
 *  @param failure 失败回调
 */
- (void)getTeamJoinActionInfoList:(V2NIMTeamJoinActionInfoQueryOption *)option
                          success:(nullable V2NIMTeamJoinActionInfoResultCallback)success
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

/// 是否在群中，YES 在群组中，NO 不在群组中
@property(nonatomic,assign,readonly) BOOL inTeam;

/// 聊天是否被禁言，YES 被禁言，NO 未禁言
@property(nonatomic,assign,readonly) BOOL chatBanned;

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

@end

/// 修改自己的群成员信息参数
@interface V2NIMUpdateSelfMemberInfoParams : NSObject

/// 群组昵称
@property(nullable,nonatomic,copy) NSString *teamNick;

/// 服务端扩展字段
@property(nullable,nonatomic,copy) NSString *serverExtension;

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

/// 入群操作信息
@interface V2NIMTeamJoinActionInfo : NSObject

/// 入群操作类型
@property(nonatomic,assign,readonly) V2NIMTeamJoinActionType actionType;

/// 群组id
@property(nonatomic,copy,readonly) NSString *teamId;

/// 群组类型
@property(nonatomic,assign,readonly) V2NIMTeamType teamType;

/// 操作账号id
@property(nonatomic,copy,readonly) NSString *operatorAccountId;

/// 附言
@property(nonatomic,copy,readonly) NSString *postscript;

/// 时间戳
@property(nonatomic,assign,readonly) NSTimeInterval timestamp;

/// 操作状态
@property(nonatomic,assign,readonly) V2NIMTeamJoinActionStatus actionStatus;

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

NS_ASSUME_NONNULL_END
