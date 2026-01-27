//
//  V2NIMMessagePin.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/31.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessageRefer;

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessagePin : NSObject
/// 被Pin的消息关键信息
@property (nullable,nonatomic,strong) V2NIMMessageRefer *messageRefer;
/// 操作者ID
@property (nonatomic,strong) NSString *operatorId;
/// 扩展字段，最大512字节
@property (nonatomic,strong) NSString *serverExtension;
/// 创建时间
@property (nonatomic,assign) NSTimeInterval createTime;
/// 更新时间
@property (nonatomic,assign) NSTimeInterval updateTime;
@end

NS_ASSUME_NONNULL_END
