//
// Created by chenjili on 2022/6/21.
// Copyright (c) 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatInviteApplyHistoryRecord.h"

NS_ASSUME_NONNULL_BEGIN

@interface NIMQChatInviteApplyDataUserInfo : NSObject <NSCopying>
@property (nullable, nonatomic, copy, readonly) NSString *accid;
@property (nonatomic, assign, readonly) NIMQChatInviteApplyInfoStatusTag status;
@property (nullable, nonatomic, copy, readonly) NSString *updateMsg;
@property (nonatomic, assign, readonly) NSTimeInterval updateTime;
@end

@protocol NIMQChatInviteApplyData <NSObject>
/**
* 申请邀请类型
*/
@property(nonatomic, assign, readonly) NIMQChatInviteApplyInfoTypeTag type;

/**
 * 字典形式的数据
 */
@property(nullable, nonatomic, copy, readonly) NSDictionary *dataDict;
@end

@protocol NIMQChatInviteApplyDataApply <NIMQChatInviteApplyData>
@property(nullable, nonatomic, copy, readonly) NSString *applyMsg;
@property(nullable, nonatomic, copy, readonly) NSString *updateAccid;
@property(nullable, nonatomic, copy, readonly) NSString *updateMsg;
@end

@protocol NIMQChatInviteApplyDataInvite <NIMQChatInviteApplyData>
@property(nullable, nonatomic, copy, readonly) NSString *inviteMsg;
@property(nullable, nonatomic, copy, readonly) NSArray<NIMQChatInviteApplyDataUserInfo *> *inviteUsers;
@end

@protocol NIMQChatInviteApplyDataInviteAck <NIMQChatInviteApplyData>
@property(nullable, nonatomic, copy, readonly) NSString *inviteMsg;
@property(nullable, nonatomic, copy, readonly) NSString *updateMsg;
@end

@protocol NIMQChatInviteApplyDataInviteCode <NIMQChatInviteApplyData>
@property(nullable, nonatomic, copy, readonly) NSString *inviteMsg;
@property(nullable, nonatomic, copy, readonly) NSString *inviteCode;
@property(nonatomic, assign, readonly) NSInteger inviteUserCount;
@end

@protocol NIMQChatInviteApplyDataInviteJoinByCode <NIMQChatInviteApplyData>
@property(nullable, nonatomic, copy, readonly) NSString *updateMsg;
@property(nullable, nonatomic, copy, readonly) NSString *inviteCode;
@end

NS_ASSUME_NONNULL_END
