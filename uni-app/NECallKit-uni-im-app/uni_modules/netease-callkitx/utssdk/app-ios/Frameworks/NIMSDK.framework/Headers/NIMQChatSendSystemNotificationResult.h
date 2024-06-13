//
//  NIMQChatSendSystemNotificationResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NIMQChatSystemNotification;

NS_ASSUME_NONNULL_BEGIN

/**
 *  发送自定义系统通知的回调类型
 */
@interface NIMQChatSendSystemNotificationResult : NSObject
/**
 * 系统通知
 */
@property (nullable, nonatomic, copy) NIMQChatSystemNotification *systemNotification;
@end


NS_ASSUME_NONNULL_END
