//
//  NIMQChatSendSystemNotificationResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatSystemNotification;
@class NIMQChatInviteApplyHistoryRecord;

NS_ASSUME_NONNULL_BEGIN

/**
 *  查询我的申请邀请记录的回调类型
 */
@interface NIMQChatGetInviteApplyHistorySelfResult : NSObject <NSCopying>
/**
 * 记录数组
 */
@property (nullable, nonatomic, copy) NSArray<NIMQChatInviteApplyHistoryRecord *> *records;
@end


NS_ASSUME_NONNULL_END
