//
//  V2NIMMessageRevokeNotification.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMMessageEnum.h"

@class V2NIMMessageRefer;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageRevokeNotification : NSObject
/// 被撤回的消息摘要
@property (nullable,nonatomic,strong,readonly) V2NIMMessageRefer *messageRefer;
/// 扩展信息
@property (nullable,nonatomic,strong,readonly) NSString *serverExtension;
/// 消息撤回者账号
@property (nullable,nonatomic,strong,readonly) NSString *revokeAccountId;
/// 扩展信息
@property (nullable,nonatomic,strong,readonly) NSString *postscript;
/// 消息撤回类型
@property (nonatomic,assign,readonly) V2NIMMessageRevokeType revokeType;
/// 第三方回调传入的自定义扩展字段
@property (nonatomic,strong,readonly) NSString *callbackExtension;

@end

NS_ASSUME_NONNULL_END
