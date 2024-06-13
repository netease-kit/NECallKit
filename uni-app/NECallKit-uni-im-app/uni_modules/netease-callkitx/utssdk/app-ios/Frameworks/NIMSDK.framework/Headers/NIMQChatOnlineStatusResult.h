//
//  NIMQChatOnlineStatusResult.h
//  NIMSDK
//
//  Created by Netease.
//  Copyright © 2022 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NIMQChatDefs.h"

NS_ASSUME_NONNULL_BEGIN

/**
 * 圈组在线状态/登录状态的回调类型
 */
@interface NIMQChatOnlineStatusResult : NSObject
/**
 * 登录状态
 */
@property (nonatomic, assign) NIMQChatLoginStep loginStep;
@end

NS_ASSUME_NONNULL_END
