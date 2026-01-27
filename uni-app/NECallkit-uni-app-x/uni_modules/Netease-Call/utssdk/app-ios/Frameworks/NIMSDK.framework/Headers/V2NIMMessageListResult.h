//
//  V2NIMMessageListResult.h
//  NIMSDK
//
//  Created by Netease on 2025/2/24.
//  Copyright © 2025 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMMessageListResult : NSObject
/// 查询的消息列表
/// 可能为空， 比如查询的消息都被过滤的情况下，列表为空，可以继续查询下一次
@property(nonatomic, strong, readonly, nullable)NSArray<V2NIMMessage *> *messages;

/// 下次查询的锚点消息
///  如果该字段为空，则表示无消息返回
@property(nonatomic, strong, readonly, nullable)V2NIMMessage* anchorMessage;
@end

NS_ASSUME_NONNULL_END
