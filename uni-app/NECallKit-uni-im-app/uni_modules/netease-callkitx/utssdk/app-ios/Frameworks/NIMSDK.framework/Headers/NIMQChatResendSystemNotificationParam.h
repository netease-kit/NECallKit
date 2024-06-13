//
//  NIMQChatSendSystemNotificationParam.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMGlobalDefs.h"
#import "NIMQChatSystemNotification.h"

NS_ASSUME_NONNULL_BEGIN

/**
 *  发送自定义系统通知的参数
 */
@interface NIMQChatResendSystemNotificationParam : NSObject
@property (nonnull, nonatomic, copy) NIMQChatSystemNotification *systemNotification;
@end

NS_ASSUME_NONNULL_END
