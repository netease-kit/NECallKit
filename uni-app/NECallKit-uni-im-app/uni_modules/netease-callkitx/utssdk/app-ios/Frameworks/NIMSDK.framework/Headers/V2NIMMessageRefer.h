//
//  V2NIMMessageBrief.h
//  NIMSDK
//
//  Created by 齐洪茹 on 2023/8/14.
//  Copyright © 2023 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "V2NIMConversationEnum.h"

NS_ASSUME_NONNULL_BEGIN

@interface V2NIMMessageRefer : NSObject
/// 发送者账号
@property (nullable,nonatomic,strong) NSString *senderId;
/// 接收者账号
@property (nullable,nonatomic,strong) NSString *receiverId;
/// 客户端消息ID
@property (nullable,nonatomic,strong) NSString *messageClientId;
/// 服务器消息ID
@property (nullable,nonatomic,strong) NSString *messageServerId;
/// 会话类型
@property (nonatomic,assign) V2NIMConversationType conversationType;
/// 会话 ID
@property (nullable,nonatomic,strong) NSString *conversationId;
/// 消息时间
@property (nonatomic,assign) NSTimeInterval createTime;

@end

NS_ASSUME_NONNULL_END
