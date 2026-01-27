//
//  V2NIMModifyMessageResult.h
//  NIMSDK
//
//  Created by 陈吉力 on 2024/7/16.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMClientAntispamResult.h"

@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMModifyMessageResult: NSObject
/// 修改成功后的消息体
@property (nonatomic,readonly,strong,nullable) V2NIMMessage *message;
/// 如果此错误码为非200，表示修改消息失败（比如触发了云端反垃圾），此时修改成功后的消息体返回为null
@property (nonatomic,assign) NSInteger errorCode;
/// 云端反垃圾返回的结果
@property (nonatomic,readonly,copy,nullable) NSString *antispamResult;
/// 客户端本地反垃圾结果
@property (nonatomic,readonly,strong,nullable) V2NIMClientAntispamResult *clientAntispamResult;

@end

NS_ASSUME_NONNULL_END
