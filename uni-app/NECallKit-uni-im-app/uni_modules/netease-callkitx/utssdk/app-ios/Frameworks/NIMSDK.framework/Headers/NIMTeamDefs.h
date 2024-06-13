//
//  NIMTeamDefs.h
//  NIMLib
//
//  Created by Netease.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#ifndef NIMLib_NIMTeamDefs_h
#define NIMLib_NIMTeamDefs_h

@class NIMTeam;
@class NIMTeamMember;

/**
 *  群类型
 */
typedef NS_ENUM(NSInteger, NIMTeamType){
    /**
     *  普通群
     */
    NIMTeamTypeNormal       = 0,
    /**
     *  高级群
     */
    NIMTeamTypeAdvanced     = 1,
    /**
     *  超大群
     */
    NIMTeamTypeSuper        = 2,
};

/**
 *  群验证方式
 */
typedef NS_ENUM(NSInteger, NIMTeamJoinMode) {
    /**
     *  允许所有人加入
     */
    NIMTeamJoinModeNoAuth    = 0,
    /**
     *  需要验证
     */
    NIMTeamJoinModeNeedAuth  = 1,
    /**
     *  不允许任何人加入
     */
    NIMTeamJoinModeRejectAll = 2,
};

/**
 *  邀请模式
 */
typedef NS_ENUM(NSInteger, NIMTeamInviteMode) {
    /**
     *  只有管理员/群主可以邀请他人入群
     */
    NIMTeamInviteModeManager    = 0,
    /**
     *   所有人可以邀请其他人入群
     */
    NIMTeamInviteModeAll        = 1,
};




/**
 *  被邀请模式
 */
typedef NS_ENUM(NSInteger, NIMTeamBeInviteMode) {
    /**
     *  需要被邀请方同意
     */
    NIMTeamBeInviteModeNeedAuth    = 0,
    /**
     *   不需要被邀请方同意
     */
    NIMTeamBeInviteModeNoAuth  = 1,
};


/**
 *  群信息修改权限
 */
typedef NS_ENUM(NSInteger, NIMTeamUpdateInfoMode) {
    /**
     *  只有管理员/群主可以修改
     */
    NIMTeamUpdateInfoModeManager    = 0,
    /**
     *  所有人可以修改
     */
    NIMTeamUpdateInfoModeAll  = 1,
};


/**
 *  修改群客户端自定义字段权限
 */
typedef NS_ENUM(NSInteger, NIMTeamUpdateClientCustomMode) {
    /**
     *  只有管理员/群主可以修改
     */
    NIMTeamUpdateClientCustomModeManager    = 0,
    /**
     *  所有人可以修改
     */
    NIMTeamUpdateClientCustomModeAll  = 1,
};


/**
 *  申请入群状态
 */
typedef NS_ENUM(NSInteger, NIMTeamApplyStatus) {
    /**
     *  无效状态
     */
    NIMTeamApplyStatusInvalid,
    /**
     *  已经在群里
     */
    NIMTeamApplyStatusAlreadyInTeam,
    /**
     *  申请等待通过
     */
    NIMTeamApplyStatusWaitForPass,
    
};


/**
 *  群成员类型
 */
typedef NS_ENUM(NSInteger, NIMTeamMemberType){
    /**
     *  普通群员
     */
    NIMTeamMemberTypeNormal = 0,
    /**
     *  群拥有者
     */
    NIMTeamMemberTypeOwner = 1,
    /**
     *  群管理员
     */
    NIMTeamMemberTypeManager = 2,
    /**
     *  申请加入用户
     */
    NIMTeamMemberTypeApply   = 3,
};


/**
 *  群消息接受状态
 */
typedef NS_ENUM(NSInteger, NIMTeamNotifyState) {
    /**
     *  接受任何群消息通知
     */
    NIMTeamNotifyStateAll         = 0,
    /**
     *  不接受任何群消息通知
     */
    NIMTeamNotifyStateNone        = 1,
    /**
     *  只接受管理员的群消息通知(仅高级群支持，超大群不支持)
     */
    NIMTeamNotifyStateOnlyManager = 2,
    
};

/**
 *  群全体禁言模式
 */
typedef NS_ENUM(NSInteger, NIMTeamAllMuteMode){
    /**
     *  取消全员禁言
     */
    NIMTeamAllMuteModeCancel         = 0,
    /**
     *  全员禁言，不包括管理员
     */
    NIMTeamAllMuteModeMuteNormal     = 1,
    /**
     *  全员禁言，包括群主和管理员
     */
    NIMTeamAllMuteModeMuteAll        = 3,
};

/**
 *  通用的群组操作block
 *
 *  @param error 错误,如果成功则error为nil
 */
typedef void(^NIMTeamHandler)(NSError * __nullable error);

/**
 *  创建群组block
 *
 *  @param error   错误,如果成功则error为nil
 *  @param teamId  群组ID
 *  @param failedUserIds 邀请失败的群成员ID
 */
typedef void(^NIMTeamCreateHandler)(NSError * __nullable error, NSString * __nullable teamId, NSArray<NSString *> * __nullable failedUserIds);

/**
*  群查询 block
*
*  @param error   错误,如果成功则error为nil
*  @param teams 查询的群信息
*/
typedef void(^NIMTeamSearchHandler)(NSError * __nullable error, NSArray<NIMTeam *> * __nullable teams);

/**
 *  群成员获取 block
 *
 *  @param error   错误,如果成功则error为nil
 *  @param members 成功的群成员列表,内部为NIMTeamMember
 */
typedef void(^NIMTeamMemberHandler)(NSError * __nullable error, NSArray<NIMTeamMember *> * __nullable members);

/**
 *  拉取群信息Block
 *
 *  @param error 错误,如果成功则error为nil
 *  @param team  群信息
 */
typedef void(^NIMTeamFetchInfoHandler)(NSError * __nullable error, NIMTeam * __nullable team);

/**
 *  群申请block
 *
 *  @param error       错误,如果成功则error为nil
 *  @param applyStatus 群申请状态
 */
typedef void(^NIMTeamApplyHandler)(NSError * __nullable error, NIMTeamApplyStatus applyStatus);

/**
 *  邀请人Accids
 *
 *  @param error       错误,如果成功则error为nil
 *  @param inviters    群成员与邀请人关系
 */
typedef void(^NIMTeamFetchInviterAccidsHandler)(NSError * __nullable error, NSDictionary<NSString *, NSString *> * __nullable inviters);

/**
 *  拉取所有群信息Block
 *
 *  @param error 错误,如果成功则error为nil
 *  @param teams  群信息
 */
typedef void(^NIMTeamFetchTeamsHandler)(NSError * __nullable error, NSArray<NIMTeam *> * __nullable teams);
/**
 *  根据群ID列表批量获取群信息block
 *
 *  @param error         错误,如果成功则error为nil
 *  @param teams         获取成功的群组信息列表
 *  @param failedUserIds 获取失败的群ID列表
 */
typedef void(^NIMTeamFetchTeamInfoListHandler)(NSError * __nullable error, NSArray<NIMTeam *> * __nullable teams, NSArray<NSString *> * __nullable failedTeamIds);

#endif
