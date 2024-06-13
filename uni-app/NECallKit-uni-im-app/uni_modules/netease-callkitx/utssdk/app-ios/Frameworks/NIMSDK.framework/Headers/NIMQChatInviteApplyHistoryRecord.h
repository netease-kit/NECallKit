//
//  NIMQChatServerMember.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

@protocol NIMQChatInviteApplyData;

NS_ASSUME_NONNULL_BEGIN

/**
 * 申请邀请类型
 */
typedef NS_ENUM(NSInteger, NIMQChatInviteApplyInfoTypeTag) {
    /**
     * 申请（个人+服务器）
     */
    NIMQChatInviteApplyInfoTypeTagApply = 1,
    /**
     * 邀请（服务器）
     */
    NIMQChatInviteApplyInfoTypeTagInvite = 2,
    /**
     * 邀请ack（个人+服务器）
     */
    NIMQChatInviteApplyInfoTypeTagInviteAck = 3,
    /**
     * 邀请码（服务器）
     */
    NIMQChatInviteApplyInfoTypeTagInviteCode = 4,
    /**
     * 通过邀请码加入（个人+服务器）
     */
    NIMQChatInviteApplyInfoTypeTagInviteJoinByCode = 5,
};

typedef NS_ENUM(NSInteger, NIMQChatInviteApplyInfoStatusTag) {
    /**
     * 初始状态
     */
    NIMQChatInviteApplyInfoStatusTagInit = 0,
    /**
     * 同意
     */
    NIMQChatInviteApplyInfoStatusTagAgree = 1,
    /**
     * 拒绝
     */
    NIMQChatInviteApplyInfoStatusTagRefuse = 2,
    /**
     * 通过其他 申请/邀请 同意了
     */
    NIMQChatInviteApplyInfoStatusTagAgreeByInviteApply = 3,
    /**
     * 通过其他 申请/邀请 拒绝了
     */
    NIMQChatInviteApplyInfoStatusTagRefuseByInviteApply = 4,
    /**
     * 邀请/申请时自动加入
     */
    NIMQChatInviteApplyInfoStatusTagAutoJoinByInviteApply = 5,
    /**
     * 过期
     */
    NIMQChatInviteApplyInfoStatusTagExpired = 6,
};

@interface NIMQChatInviteApplyHistoryRecord : NSObject <NSCopying>

/**
 * accid
 */
@property(nullable, nonatomic, copy) NSString *accid;

/**
 * 申请邀请类型
 */
@property(nonatomic, assign) NIMQChatInviteApplyInfoTypeTag type;

/**
 * 关联的serverId
 */
@property(nonatomic, assign) unsigned long long serverId;

/**
 * 状态，0表示初始状态，1表示同意，2表示拒绝，3表示通过其他 申请/邀请 同意了，4表示通过其他 申请/邀请 拒绝了，5表示邀请/申请时自动加入，6表示过期
 */
@property(nonatomic, assign) NIMQChatInviteApplyInfoStatusTag status;

/**
 *  申请/邀请唯一标识
 */
@property(nonatomic, assign) long long requestId;

/**
 * 创建时间
 */
@property(nonatomic, assign) NSTimeInterval createTime;

/**
 * 更新时间
 */
@property(nonatomic, assign) NSTimeInterval updateTime;

/**
 * 过期时间
 */
@property(nonatomic, assign) NSTimeInterval expireTime;

/**
 * 结果数据
 */
@property(nullable, nonatomic, copy) id<NIMQChatInviteApplyData> data;

/**
 * 记录唯一标识
 */
@property(nonatomic, assign) long recordId;


@end

NS_ASSUME_NONNULL_END
