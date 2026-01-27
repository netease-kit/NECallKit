//
//  V2NIMBroadcastNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 全员广播通知
@interface V2NIMBroadcastNotification : NSObject
/// 广播通知ID
@property(nonatomic,assign,readonly) NSUInteger id;
/// 广播通知发送者账号
@property(nonatomic,strong,readonly) NSString *senderId;
/// 广播通知时间戳
@property(nonatomic,assign,readonly) NSTimeInterval timestamp;
/// 广播通知内容
@property(nonatomic,strong,readonly) NSString *content;
@end

NS_ASSUME_NONNULL_END
