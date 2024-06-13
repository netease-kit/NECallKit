//
//  V2NIMMessagePinnedNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"

@class V2NIMMessagePin;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessagePinNotification : NSObject
/// 被Pin的消息关键信息
@property (nullable,nonatomic,strong, readonly) V2NIMMessagePin *pin;
/// 消息PIN状态
@property (nonatomic,assign, readonly) V2NIMMessagePinState pinState;
@end

NS_ASSUME_NONNULL_END
