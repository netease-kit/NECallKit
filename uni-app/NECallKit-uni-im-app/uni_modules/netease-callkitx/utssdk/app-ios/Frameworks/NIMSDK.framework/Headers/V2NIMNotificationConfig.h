//
//  V2NIMNotificationConfig.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/30.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 通知相关配置
@interface V2NIMNotificationConfig : NSObject

/// 是否需要存离线通知
/// true：需要 false：不需要，只有在线用户会收到
@property(nonatomic,assign,readwrite) BOOL offlineEnabled;
/// 是否需要计通知未读
/// 与会话未读无关
/// true：需要
/// false：不需要
@property(nonatomic,assign,readwrite) BOOL unreadEnabled;

@end

NS_ASSUME_NONNULL_END
