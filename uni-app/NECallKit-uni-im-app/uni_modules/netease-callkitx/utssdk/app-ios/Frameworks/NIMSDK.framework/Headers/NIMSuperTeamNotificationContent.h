//
//  NIMSuperTeamNotificationContent.h
//  NIMSDK
//
//  Copyright © 2019 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMNotificationContent.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  群操作类型
 */
typedef NS_ENUM(NSInteger, NIMSuperTeamOperationType){
    /**
     *  邀请成员
     */
    NIMSuperTeamOperationTypeInvite          = 401,
    /**
     *  移除成员
     */
    NIMSuperTeamOperationTypeKick            = 402,
    /**
     *  离开群
     */
    NIMSuperTeamOperationTypeLeave           = 403,
    /**
     *  更新群信息
     */
    NIMSuperTeamOperationTypeUpdate          = 404,
    /**
     *  解散群
     */
    NIMSuperTeamOperationTypeDismiss         = 405,
    /**
     *  群主转移群主身份
     */
    NIMSuperTeamOperationTypeTransferOwner   = 406,
    /**
     *  添加管理员
     */
    NIMSuperTeamOperationTypeAddManager      = 407,
    /**
     *  移除管理员
     */
    NIMSuperTeamOperationTypeRemoveManager   = 408,
    
    /**
     *  群内禁言/解禁
     */
    NIMSuperTeamOperationTypeMute            = 409,
    
    /**
     *  申请成功进群
     */
    NIMSuperTeamOperationTypeApplyPass       = 410,
    
    /**
     *  接受邀请进群
     */
    NIMSuperTeamOperationTypeAcceptInvitation = 411,
};

/**
 *  群信息更新字段
 */
typedef NS_ENUM(NSInteger, NIMSuperTeamUpdateTag){
    /**
     *  群名
     */
    NIMSuperTeamUpdateTagName            = 3,
    /**
     *  群简介
     */
    NIMSuperTeamUpdateTagIntro           = 14,
    /**
     *  群公告
     */
    NIMSuperTeamUpdateTagAnouncement     = 15,
    /**
     *  群验证方式
     */
    NIMSuperTeamUpdateTagJoinMode        = 16,
    /**
     *  客户端自定义拓展字段
     */
    NIMSuperTeamUpdateTagClientCustom    = 18,
    
    /**
     *  服务器自定义拓展字段
     *  @discussion SDK 无法直接修改这个字段, 请调用服务器接口
     */
    NIMSuperTeamUpdateTagServerCustom    = 19,
    
    /**
     *  头像
     */
    NIMSuperTeamUpdateTagAvatar          = 20,
    
    /**
     *  被邀请模式
     */
    NIMSuperTeamUpdateTagBeInviteMode    = 21,
    
    /**
     *  群全体禁言
     *  @discussion SDK 无法直接修改这个字段, 请调用服务器接口
     */
    NIMSuperTeamUpdateTagMuteMode       = 101,

    /**
     * 对某些资料内容另外的反垃圾的业务ID
     */
    NIMSuperTeamUpdateTagAntispamBusinessId = 102,
};

/**
 * 超大群通知内容
 */
@interface NIMSuperTeamNotificationContent : NIMNotificationContent
/**
 *  操作发起者ID
 */
@property (nullable,nonatomic,copy,readonly)     NSString    *sourceID;

/**
 *  操作类型
 */
@property (nonatomic,assign,readonly)   NIMSuperTeamOperationType  operationType;

/**
 *  被操作者ID列表
 */
@property (nullable,nonatomic,copy,readonly)   NSArray<NSString *> *targetIDs;

/**
 *  群通知下发的自定义扩展信息
 */
@property (nullable,nonatomic,readonly)   NSString *notifyExt;

/**
 *  额外信息
 *  @discussion 群更新时 attachment 为 NIMUpdateTeamInfoAttachment，
 *              禁言时 attachment 为  NIMMuteTeamMemberAttachment
 */
@property (nullable,nonatomic,strong,readonly)   id attachment;
@end

/**
 *  更新群信息的额外信息
 */
@interface NIMUpdateSuperTeamInfoAttachment : NSObject

/**
 *  群内修改的信息键值对
 *  @discussion NSNumebr 取值范围为 NIMSuperTeamUpdateTag 枚举类型
 */
@property (nullable,nonatomic,copy,readonly)   NSDictionary<NSNumber *,NSString *>    *values;
@end

/**
 *  禁言通知的额外信息
 */
@interface NIMMuteSuperTeamMemberAttachment : NSObject

/**
 *  是否被禁言
 *  @discussion YES 为禁言，NO 为 解除禁言
 */
@property (nonatomic,assign,readonly)   BOOL    flag;

@end

NS_ASSUME_NONNULL_END
