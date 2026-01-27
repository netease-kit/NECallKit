//
//  V2NIMNotificationPushConfig.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 通知推送相关配置
@interface V2NIMNotificationPushConfig : NSObject
/// 是否需要推送通知。true：需要, false：不需要
@property(nonatomic,assign,readwrite) BOOL pushEnabled;
/// 是否需要推送通知发送者昵称。true：需要, false：不需要
@property(nonatomic,assign,readwrite) BOOL pushNickEnabled;
/// 推送文案
@property(nonatomic,strong,readwrite) NSString *pushContent;
/// 推送数据
@property(nonatomic,strong,readwrite) NSString *pushPayload;
/// 忽略用户通知提醒相关设置，只通知类型有效
@property(nonatomic,assign,readwrite) BOOL forcePush;
/// 强制推送文案，只通知类型有效
@property(nonatomic,strong,readwrite) NSString *forcePushContent;
/// 强制推送目标账号列表，只通知类型有效
@property(nonatomic,strong,readwrite) NSArray *forcePushAccountIds;

@end

NS_ASSUME_NONNULL_END
