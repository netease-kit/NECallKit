//
//  V2NIMThreadMessageListResult.h
//  NIMLib
//
//  Created by chenjili on 2024/5/6.
//  Copyright © 2024 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@class V2NIMMessage;

NS_ASSUME_NONNULL_BEGIN
@interface V2NIMThreadMessageListResult: NSObject
/// 根消息
@property (nonatomic,readonly,strong) V2NIMMessage *message;
/// 获取thread聊天里最后一条消息的时间戳
@property (nonatomic,readonly,assign) NSTimeInterval timestamp;
/// 获取thread聊天里的总回复数，thread消息不计入总数
@property (nonatomic,readonly,assign) NSInteger replyCount;
/// 消息回复列表
@property (nonatomic,readonly,strong) NSArray<V2NIMMessage *> *replyList;

@end

NS_ASSUME_NONNULL_END
